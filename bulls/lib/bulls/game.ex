defmodule Bulls.Game do
  alias Bulls.GameUtil

  # start a new game state
  def new(gname) do
    %{
      secret: random_secret(4),
      timer: :NO_TIMER,
      guesses: Map.new(),
      gameState: :IN_SETUP,
      errorMessage: nil,
      players: Map.new(),
      # list?
      observers: Map.new(),
      # list of allll players pre setup
      playerMap: Map.new(),
      gameName: gname,
      turnNumber: 1
    }
  end

  # return view state.
  def view(st, name, errorMessage \\ nil) do
    IO.inspect([:st, st])
    %{
      guesses: st.guesses,
      errorMessage: errorMessage,
      gameState: st.gameState,
      players: st.players,
      observers: st.observers,
      userName: name,
      gameName: st.gameName,
      # => { username => [playerType, isReady] }
      playerMap: st.playerMap,
      turnNumber: st.turnNumber
    }
  end

  # add the user to this
  def addPlayer(st, user) do
    l = length(Map.keys(st.playerMap)) + 1
    %{st | playerMap: Map.put(st.playerMap, user, ["Observer", false])}
  end

  # update the user's playertype
  def changePlayerType(st, user, playerType) do
    %{st | playerMap: Map.put(st.playerMap, user, [playerType, false])}
  end

  # update the user's playertype and marks as ready
  def playerIsReady(st, user, playerType) do
    # check all Player type members are ready, if so change the game state

    ret = %{st | playerMap: Map.put(st.playerMap, user, [playerType, true])}
    if readyToStart?(ret.playerMap) do
      ref = Process.send_after(self(), :turn, 10000, []);
      %{st | gameState: :IN_PROGRESS, timer: ref}
    else
      ret
    end
    # IO.inspect([:join, ret, readyToStart?(ret.playerMap)])
    # ret
  end

  # returns true if game is ready to start
  def readyToStart?(playerMap) do
    function = fn mapping, [a, b] ->
      {user, list} = mapping

      cond do
        hd(list) == "Player" -> [a + 1, b && (hd (tl list))]
        true -> [a, b]
      end
    end

    [numPlayers, ready] = Enum.reduce(playerMap, [0, true], function)
    numPlayers > 0 && ready
  end

  # make guess. calculate bnc and return new game state.
  def guess(st, attempt, userName) do
    l = length(Map.keys(st.guesses)) + 1
    bnc = GameUtil.determineBullsAndCows(st.secret, attempt)
    gameState = gameOver?(st.guesses, bnc)

    gst = %{st | guesses: Map.put(st.guesses, l, [attempt, bnc, userName, st.turnNumber]), gameState: gameState}

    cond do
      allPlayersMadeGuess?(gst) ->
        # also kill timer process and make a new one
        ref = Process.send_after(self(), :turn, 10000, []);
        Process.cancel_timer(gst.timer, [])
        %{gst | turnNumber: gst.turnNumber + 1, timer: ref}
      true -> gst
    end
    # %{st | guesses: Map.put(st.guesses, l, [attempt, bnc, userName, st.turnNumber]), gameState: gameState}
  end

  # boolean
  def allPlayersMadeGuess?(st) do
    function = fn mapping, number ->
      {guess, guessInfo} = mapping
      [_, _, _, turn] = guessInfo
      cond do
        turn == st.turnNumber -> number + 1
        true -> number
      end
    end
    func2 = fn mapping, num ->
      {username, info} = mapping
      if (hd info) == "Player" do
        num + 1
      else
        num
      end
    end
    numTurnGuesses = Enum.reduce(st.guesses, 0, function)
    numPlayers = Enum.reduce(st.playerMap, 0, func2)
    numPlayers <= numTurnGuesses
    # check if
  end


  # check if game is over.
  def gameOver?(guesses, bnc) do
    m_size = Kernel.map_size(guesses)

    cond do
      bnc == "4A0B" -> :WIN
      true -> :IN_PROGRESS
    end
  end

  #  generate a random number of 4 digits
  #  cannot start with 0
  #  each digits must be unique
  def random_secret(len) do
    possibleNums = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    # gen first number
    randNumber = Enum.random(possibleNums)
    ret = to_string(randNumber)

    # delete number from possibleNums
    possibleNums = List.delete(possibleNums, randNumber)
    possibleNums = possibleNums ++ [0]
    # loop
    random_secret(len - 1, ret, possibleNums)
  end

  def random_secret(len, ret, possibleNums) do
    if len == 0 do
      # random_secret(:end, ret)
      ret
    else
      randNumber = Enum.random(possibleNums)
      ret = ret <> to_string(randNumber)
      possibleNums = List.delete(possibleNums, randNumber)
      random_secret(len - 1, ret, possibleNums)
    end
  end
end
