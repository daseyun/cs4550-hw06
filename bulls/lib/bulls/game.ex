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
      # list of allll players pre setup
      playerMap: Map.new(),
      gameName: gname,
      turnNumber: 1
    }
  end

  def new(gname, playerMap, timer) do
    if timer != :NO_TIMER, do: Process.cancel_timer(timer, [])

    %{
      secret: random_secret(4),
      timer: :NO_TIMER,
      guesses: Map.new(),
      gameState: :IN_SETUP,
      errorMessage: nil,
      # list of allll players pre setup
      playerMap: playerMap,
      gameName: gname,
      turnNumber: 1
    }
  end

  # return view state.
  def view(st, name, errorMessage \\ nil) do
    if errorMessage != nil do
      %{
        guesses: st.guesses,
        errorMessage: errorMessage,
        gameState: st.gameState,
        userName: name,
        gameName: st.gameName,
        playerMap: st.playerMap,
        turnNumber: st.turnNumber
      }
    else
      %{
        guesses: st.guesses,
        errorMessage: st.errorMessage,
        gameState: st.gameState,
        userName: name,
        gameName: st.gameName,
        playerMap: st.playerMap,
        turnNumber: st.turnNumber
      }
    end
  end

  # add the user to this
  def addPlayer(st, user) do
    %{st | playerMap: Map.put(st.playerMap, user, ["Observer", false, false, 0, 0])}
  end

  def leaveGame(st, user) do
    gst = %{st | playerMap: Map.delete(st.playerMap, user)}

    if map_size(gst.playerMap) == 0 do
      if gst.timer != :NO_TIMER, do: Process.cancel_timer(gst.timer, [])
      new(st.gameName)
    else
      gst
    end
  end

  # update the user's playertype
  def changePlayerType(st, user, playerType) do
    [_, _, wonLast, wins, losses] = st.playerMap[user]
    %{st | playerMap: Map.put(st.playerMap, user, [playerType, false, wonLast, wins, losses])}
  end

  # update the user's playertype and marks as ready
  def playerIsReady(st, user, playerType) do
    # check all Player type members are ready, if so change the game state
    [_, _, wonLast, wins, losses] = st.playerMap[user]

    ret = %{
      st
      | playerMap: Map.put(st.playerMap, user, [playerType, true, wonLast, wins, losses])
    }

    if readyToStart?(ret.playerMap) do
      ref = Process.send_after(self(), :turn, 30000, [])
      %{st | gameState: :IN_PROGRESS, timer: ref}
    else
      ret
    end
  end

  # returns true if game is ready to start
  def readyToStart?(playerMap) do
    function = fn mapping, [a, b] ->
      {_, list} = mapping

      cond do
        hd(list) == "Player" -> [a + 1, b && hd(tl(list))]
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

    gameState = gameOver?(st, bnc)

    gmst = %{
      st
      | guesses: Map.put(st.guesses, l, [attempt, bnc, userName, st.turnNumber]),
        gameState: gameState
    }

    cond do
      allPlayersMadeGuess?(gmst) ->
        # also kill timer process and make a new one

        if gmst.gameState == :WIN do
          gst = checkForWinners(gmst)
          if gst.timer != :NO_TIMER, do: Process.cancel_timer(gst.timer, [])
          gst
        else
          ref = Process.send_after(self(), :turn, 30000, [])
          if gmst.timer != :NO_TIMER, do: Process.cancel_timer(gmst.timer, [])
          %{gmst | turnNumber: gmst.turnNumber + 1, timer: ref}
        end

      true ->
        gmst
    end
  end

  def checkForWinners(st) do
    lastGuesses = GameUtil.lastTurnGuesses(st)

    function = fn mapping, state ->
      {_, guessInfo} = mapping
      [_, bnc, user, _] = guessInfo
      [type, _, _, wins, losses] = state.playerMap[user]

      if bnc == "4A0B" do
        %{
          state
          | playerMap: Map.put(state.playerMap, user, [type, false, true, wins + 1, losses])
        }
      else
        %{
          state
          | playerMap: Map.put(state.playerMap, user, [type, false, false, wins, losses + 1])
        }
      end
    end

    quickState = resetLastWinners(st.playerMap, st)
    newSt = Enum.reduce(lastGuesses, quickState, function)
    new(newSt.gameName, newSt.playerMap, newSt.timer)
  end

  def resetLastWinners(playerMap, st) do
    func2 = fn mapping, state ->
      {user, userInfo} = mapping
      [type, _, _, wins, losses] = userInfo

      if type == "Observer",
        do: %{
          state
          | playerMap: Map.put(state.playerMap, user, [type, false, false, wins, losses])
        },
        else: state
    end

    Enum.reduce(playerMap, st, func2)
  end

  # boolean
  def allPlayersMadeGuess?(st) do
    func1 = fn mapping, userlist ->
      {_, guessInfo} = mapping
      [_, _, user, turn] = guessInfo

      cond do
        turn == st.turnNumber && !Enum.member?(userlist, user) -> [user | userlist]
        true -> userlist
      end
    end

    func2 = fn mapping, num ->
      {_, info} = mapping
      if hd(info) == "Player", do: num + 1, else: num
    end

    numTurnGuesses = length(Enum.reduce(st.guesses, [], func1))
    numPlayers = Enum.reduce(st.playerMap, 0, func2)
    numPlayers <= numTurnGuesses
  end

  # check if game is over.
  def gameOver?(state, bnc) do
    guesses = state.guesses
    m_size = Kernel.map_size(guesses)

    cond do
      # state.gameState == :WIN -> :WIN
      bnc == "4A0B" -> :WIN
      true -> state.gameState
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
