defmodule Bulls.Game do
  alias Bulls.GameUtil

  # start a new game state
  def new(gname)do
    %{
      secret: random_secret(4),
      guesses: Map.new(),
      gameState: :IN_PROGRESS,
      errorMessage: nil,
      players: Map.new(),
      observers: Map.new(), # list?
      members: Map.new(), # list of allll players pre setup
      gameName: gname
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
      members: st.members # => {:players => , :observers=> }
    }
  end

  # add the user to this
  def addPlayer(st, user) do
    IO.inspect([:addPlayer, st, user])
    l = length(Map.keys(st.members)) + 1
    %{st | members: Map.put(st.members, l, user)}
  end

  # make guess. calculate bnc and return new game state.
  def guess(st, attempt) do
    l = length(Map.keys(st.guesses)) + 1
    secret = st.secret
    bnc = GameUtil.determineBullsAndCows(secret, attempt)
    gameState = gameOver?(st.guesses, bnc)
    %{st | guesses: Map.put(st.guesses, l, [attempt, bnc]), gameState: gameState}
  end

  # check if game is over.
  def gameOver?(guesses, bnc) do
    m_size = Kernel.map_size(guesses)

    cond do
      ((bnc == "4A0B") && (m_size <= 7)) -> :WIN
      ((bnc != "4A0B") && (m_size >= 7)) -> :LOSE
      true  -> :IN_PROGRESS
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
