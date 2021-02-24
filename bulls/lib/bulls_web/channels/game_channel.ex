defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel

  alias Bulls.Game
  alias Bulls.GameServer
  alias Bulls.GameUtil

  @impl true
  def join("game:" <> name, payload, socket) do
    if authorized?(payload) do
      GameServer.start(name)
      socket = socket
        |> assign(:name, name)
        |> assign(:user, "")
      game = GameServer.peek(name)
      view = Game.view(game, "")
      {:ok, view, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client

   @impl true
  def handle_in("login", %{"userName" => user}, socket) do
    socket = assign(socket, :user, user)
    view = socket.assigns[:name] # gamename
    # |> GameServer.peek()
    # TODO add player to game state under players or observers
    name = socket.assigns[:name]
    |> GameServer.addPlayer(user)
    |> Game.view(user)
    # IO.inspect(view)
    broadcast(socket, "view", name)
    {:reply, {:ok, name}, socket}
  end

  # update user's playertype / broadcast.
  @impl true
  def handle_in("changePlayerType", %{"userName" => user, "playerType" => playerType}, socket) do
    socket = assign(socket, :user, user)
    name = socket.assigns[:name] # gamename
    game = socket.assigns[:name]
    |> GameServer.changePlayerType(user, playerType)
    |> Game.view(user)

    IO.inspect([:change, user, playerType, game])
    broadcast(socket, "view", game)
    {:reply, {:ok, game}, socket}


  end

  # update user's playertype / isReady status / broadcast.
  @impl true
  def handle_in("ready", %{"userName" => user, "playerType" => playerType}, socket) do
    socket = assign(socket, :user, user)
    name = socket.assigns[:name] # gamename
    game = socket.assigns[:name]
    |> GameServer.playerIsReady(user, playerType)
    |> Game.view(user)
    IO.inspect([:ready, user, playerType, game])
    broadcast(socket, "view", game)
    {:reply, {:ok, game}, socket}


  end

  @impl true
  def handle_in("guess", attempt, socket) do
    user = socket.assigns[:user]
    name = socket.assigns[:name]
    |> GameServer.guess(attempt)
    |> Game.view(user)

    broadcast(socket, "view", name)
    {:reply, {:ok, name}, socket}
  end

  @impl true
  def handle_in("reset", _, socket) do
    user = socket.assigns[:user]
    name = socket.assigns[:name] #game name
    |> GameServer.reset()
    |> Game.view(user)
    broadcast(socket, "view", name)
    {:reply, {:ok, name}, socket}
  end

  intercept ["view"]

  @impl true
  def handle_out("view", msg, socket) do
    # IO.inspect([:hout, msg])
    user = socket.assigns[:user]
    msg = %{msg | userName: user}
    push(socket, "view", msg)
    IO.inspect([:hout, msg, socket])
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
