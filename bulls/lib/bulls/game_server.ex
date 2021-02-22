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
    game = BackupAgent.get(name) || Game.new
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

  # implementation

  def init(game) do
    Process.send_after(self(), :pook, 10_000)
    {:ok, game}
  end

  def handle_call({:reset, name}, _from, game) do
    game = Game.new()
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

  def handle_call({:peek, _name}, _from, game) do
    {:reply, game, game}
  end

  def handle_info(:pook, game) do
    game = Game.guess(game, "q") # TODO: what is this
    BullsWeb.Endpoint.broadcast!(
      "game:1", # FIXME: Game name should be in state
      "view",
      Game.view(game, ""))
    {:noreply, game}
  end
end
