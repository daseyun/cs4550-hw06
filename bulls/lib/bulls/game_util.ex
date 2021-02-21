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

  # return error messages if input is invalid.
  def getErrorMessages(guesses, attempt) do
    cond do
      isAlreadyAttempted?(guesses, attempt) ->
        "number already guessed"

      !isAttemptProper?(attempt) ->
        "invalid number: cannot start with 0 and must have 4 unique digits."

      true ->
        nil
    end
  end

  # check if attempt was already inputted before.
  defp isAlreadyAttempted?(guesses, attempt) do
    Enum.any?(guesses, fn {_k, v} ->
      attempt == hd(v)
    end)
  end

  # check if attempt is valid: 4 digits. all unique. no start with 0.
  defp isAttemptProper?(attempt) do
    digit1 = String.slice(attempt, 0..0)
    l = String.length(attempt)
    set_l = MapSet.size(MapSet.new(String.graphemes(attempt)))
    notAllInt = Enum.any?(String.graphemes(attempt), fn(x) -> Float.parse(x) == :error end)

    cond do
      digit1 == "0" -> false
      l != 4 -> false
      set_l != 4 -> false
      notAllInt -> false
      true -> true
    end
  end
end
