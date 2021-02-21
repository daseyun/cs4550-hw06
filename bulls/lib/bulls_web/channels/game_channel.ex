defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel

  alias Bulls.Game
  alias Bulls.BackupAgent
  alias Bulls.GameUtil

  @impl true
  def join("game:" <> name, payload, socket) do
    if authorized?(payload) do
      game = BackupAgent.get(name) || Game.new()

      socket =
        socket
        |> assign(:game, game)
        |> assign(:name, name)

      BackupAgent.put(name, game)
      {:ok, Game.view(game), socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("guess", payload, socket) do
    name = socket.assigns[:name]

    # check if game is over
    st = BackupAgent.get(name)
    errorMessage = GameUtil.getErrorMessages(st.guesses, payload)

    cond do
      errorMessage != nil ->
        {:reply, {:ok, Game.view(st, errorMessage)}, socket}

      st.gameState != :IN_PROGRESS ->
        {:reply, {:error, "game is over"}, socket}

      true ->
        game = Game.guess(socket.assigns[:game], payload)
        socket = assign(socket, :game, game)
        BackupAgent.put(name, game)
        {:reply, {:ok, Game.view(game)}, socket}
    end
  end

  @impl true
  def handle_in("reset", _, socket) do
    name = socket.assigns[:name]
    game = Game.new()
    BackupAgent.put(name, game)
    socket = assign(socket, :game, game)
    view = Game.view(game)
    {:reply, {:ok, view}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
