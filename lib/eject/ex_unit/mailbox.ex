defmodule Eject.ExUnit.Mailbox do
  use Agent

  def create() do
    {:ok, pid} = Agent.start_link fn -> [] end

    pid
  end

  def put(mailbox, message) do
    Agent.update mailbox,
                 fn messages -> [message | messages] end
  end

  def contains?(mailbox, target_message) do
    Agent.get mailbox,
              fn messages ->
                :not_found != Enum.find messages,
                                        :not_found,
                                        &(&1 == target_message)
              end
  end
end
