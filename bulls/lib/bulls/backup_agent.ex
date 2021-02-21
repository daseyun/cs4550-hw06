# https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/08-server-state/notes.md#hangman-with-backup-agent
defmodule Bulls.BackupAgent do
  use Agent

  # This is basically just a global mutable map.

  def start_link(_args) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(name, val) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, name, val)
    end)
  end

  def get(name) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, name)
    end)
  end
end
