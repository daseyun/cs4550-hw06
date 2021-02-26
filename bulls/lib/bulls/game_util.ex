defmodule Bulls.GameUtil do
  # find bulls and cows and spit out string in format: "1A1B"
  # A: bulls -- correct number && position
  # B: cows -- correct number
  def determineBullsAndCows(secret, attempt) do
    secret_arr = String.graphemes(to_string(secret))
    attempt_arr = String.graphemes(to_string(attempt))
    zip_arr = Enum.zip(secret_arr, attempt_arr)

    # find bulls
    bulls_set =
      Enum.reduce(zip_arr, MapSet.new(), fn x, acc ->
        {a, b} = x

        if a == b do
          MapSet.put(acc, a)
        else
          acc
        end
      end)

    secret_set = MapSet.new(secret_arr)

    cows_count =
      Enum.reduce(attempt_arr, 0, fn x, acc ->
        if !MapSet.member?(bulls_set, x) && MapSet.member?(secret_set, x) do
          acc + 1
        else
          acc
        end
      end)

    to_string(MapSet.size(bulls_set)) <> "A" <> to_string(cows_count) <> "B"
  end

  def hideGuesses(st, userName) do
    turnGuesses = lastTurnGuesses(st)
    function = fn guess, state ->
      {guessNum, guessInfo} = guess
      [val, bnc, user, turn] = guessInfo
      if user != userName, do: %{state | guesses: Map.delete(state.guesses, guessNum)}, else: state
    end
    Enum.reduce(turnGuesses, st, function)
  end

  def lastTurnGuesses(st) do
    function = fn mapping, guesses ->
      {guessnum, guessInfo} = mapping
      [_, _, _, turn] = guessInfo

      if turn == st.turnNumber do
        [mapping | guesses]
      else
        guesses
      end
    end
    Enum.reduce(st.guesses, [], function)
  end

  def fillGuessesWithPass(st) do
    l = length(Map.keys(st.guesses)) + 1;
    notGuessed = notGuessedPlayers(st);

    function = fn user, [length, map] ->
      [length + 1, %{ map | guesses: Map.put(map.guesses, length, ["PASS", "0A0B", user, st.turnNumber])}]
    end
    [length, state] = Enum.reduce(notGuessed, [l, st], function)
    %{ state | turnNumber: state.turnNumber + 1 }
  end
  # Bulls.GameUtil.fillGuessesWithPass(st)

  defp notGuessedPlayers(st) do
    function = fn mapping, players ->
      {guess, guessInfo} = mapping
      [val, bscs, user, turn] = guessInfo
      cond do
        turn == st.turnNumber -> [ user | players ]
        true -> players
      end
    end
    guessed = Enum.reduce(st.guesses, [], function)
    func2 = fn mapping, players ->
      {username, info} = mapping
      if (hd info) == "Player" do
        [ username | players ]
      else
        players
      end
    end
    Enum.reduce(st.playerMap, [], func2) -- guessed;
  end


  # return error messages if input is invalid.
  def getErrorMessages(st, userName, attempt) do

    userGuesses = userGuesses(st.guesses, userName)

    cond do
      !isValidTurnAttempt(userGuesses, st.turnNumber) ->
        "invalid move. you must wait for everyone to go."
      !isAttemptProper?(attempt) ->
        "invalid number: cannot start with 0 and must have 4 unique digits."

      true ->
        nil
    end
  end

  defp userGuesses(guesses, username) do
     function = fn mapping, list ->
      {guess, guessInfo} = mapping
      [val, bscs, user, turn] = guessInfo
      cond do
        user == username -> [turn | list]
        true -> list
      end
    end
    Enum.reduce(guesses, [], function)
  end

  def isValidTurnAttempt(userTurns, turnNumber) do
    !Enum.any?(userTurns, fn(x) -> x == turnNumber end)
  end

  # check if attempt was already inputted before.
  defp isAlreadyAttempted?(guesses, attempt) do
    Enum.any?(guesses, fn {_k, v} ->
      attempt == hd(v)
    end)
  end

  # check if attempt is validstat 4 digits. all unique. no start with 0.
  defp isAttemptProper?(attempt) do
    digit1 = String.slice(attempt, 0..0)
    l = String.length(attempt)
    set_l = MapSet.size(MapSet.new(String.graphemes(attempt)))
    notAllInt = Enum.any?(String.graphemes(attempt), fn(x) -> Float.parse(x) == :error end)

    cond do
      attempt == "PASS" -> true
      digit1 == "0" -> false
      l != 4 -> false
      set_l != 4 -> false
      notAllInt -> false
      true -> true
    end
  end
end
