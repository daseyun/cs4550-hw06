defmodule Bulls.GameServer do
  use GenServer

  alias Bulls.BackupAgent
  alias Bulls.Game

  # public interface

  def reg(name) do
    {:via, Registry, {Bulls.GameReg, name}}
  end

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker
    }
    Bulls.GameSup.start_child(spec)
  end

  def start_link(name) do
    game = BackupAgent.get(name) || Game.new(name)
    GenServer.start_link(
      __MODULE__,
      game,
      name: reg(name)
    )
  end

  def reset(name) do
    GenServer.call(reg(name), {:reset, name})
  end

  def guess(name, letter) do
    GenServer.call(reg(name), {:guess, name, letter})
  end

  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end

  def addPlayer(name, player) do
    GenServer.call(reg(name), {:addPlayer, name, player})
  end

  def changePlayerType(name, player, playerType) do
    GenServer.call(reg(name), {:changePlayerType, name, player, playerType})
  end

  def playerIsReady(name, player, playerType) do
    GenServer.call(reg(name), {:playerIsReady, name, player, playerType})
  end
  # implementation

  def init(game) do
    Process.send_after(self(), :pook, 10_000)
    {:ok, game}
  end

  def handle_call({:reset, name}, _from, game) do
    game = Game.new(name)
    BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:guess, name, attempt}, _from, game) do
    st = BackupAgent.get(name)
    errorMessage = GameUtil.getErrorMessages(st.guesses, attempt)
    cond do
      errorMessage != nil ->
        {:reply, {:ok, Game.view(st, errorMessage)}}

      st.gameState != :IN_PROGRESS ->
        {:reply, {:error, "game is over"}}

      true -> game = Game.guess(game, attempt)
        BackupAgent.put(name, game)
        {:reply, game, game}
      end
  end

  def handle_call({:addPlayer, name, user}, _from, game) do
    game = Game.addPlayer(game, user)
    BackupAgent.put(name, game);
    {:reply, game, game}
  end

  def handle_call({:changePlayerType, name, user, playerType}, _from, game) do
    game = Game.changePlayerType(game, user, playerType)
    BackupAgent.put(name, game);
    {:reply, game, game}
  end

  def handle_call({:playerIsReady, name, user, playerType}, _from, game) do
    game = Game.playerIsReady(game, user, playerType)
    BackupAgent.put(name, game);
    {:reply, game, game}
  end

  def handle_call({:peek, _name}, _from, game) do
    {:reply, game, game}
  end

  def handle_info(:pook, game) do
    IO.inspect([ :game, game])
    BullsWeb.Endpoint.broadcast!(
      "game:" <> game.gameName, # FIXED: Game name is in state
      "view",
      Game.view(game, ""))
    {:noreply, game}
  end
end
