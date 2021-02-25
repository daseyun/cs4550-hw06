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
    broadcast(socket, "view", game)
    {:reply, {:ok, game}, socket}
  end

  @impl true
  def handle_in("guess", %{"guess" => attempt, "userName" => userName}, socket) do
    # user = socket.assigns[:user]
    name = socket.assigns[:name]
    # check if user has guessed in this turn
    # if not, allow the code below to pass
    # if so, toss an error telling them to wait
    oldGame = GameServer.peek(name)
    oldTurn = oldGame.turnNumber
    IO.inspect([:guessHandle, oldGame, oldTurn])

    name = socket.assigns[:name]
    |> GameServer.guess(attempt, userName)
    |> Game.view(userName)

    # if the turn is different, that means we killed the timer and moved on
    # therefore everyone can see eachother's guesses
    if !(oldTurn == name.turnNumber) do
      broadcast(socket, "view", name)
    end
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
    user = socket.assigns[:user]
    msg = %{msg | userName: user}
    push(socket, "view", msg)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
