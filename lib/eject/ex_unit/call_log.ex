defmodule Eject.ExUnit.CallLog do
  @moduledoc """
  A specialized container for storing and retriving function calls
  """

  use Agent

  @type message() :: {atom(), tuple()}
  @type t()       :: pid()

  @doc """
  Creates a CallLog process
  """
  @spec start_link() :: {:ok, t()}
  def start_link, do: Agent.start_link fn -> [] end

  @doc """
  Stores a function call

  ## Example

      iex> {:ok, call_log} = CallLog.start_link
      ...> CallLog.record call_log, :some_function, {:some, :args}
      :ok

  """
  @spec record(
    call_log      :: t(),
    function_name :: atom(),
    function_args :: tuple()
  ) :: :ok
  def record(call_log, function_name, function_args) do
    Agent.update call_log,
                 fn state -> state ++ [{function_name, function_args}] end
  end

  @doc """
  Retrieves all stored messages in the order they were received

  ## Example

      iex> {:ok, call_log} = CallLog.start_link
      ...> CallLog.record call_log, :some_function, {:some, :args}
      ...> CallLog.record call_log, :another_function, {:even, :more, :args}
      ...> CallLog.all call_log
      [
        some_function:    {:some, :args},
        another_function: {:even, :more, :args},
      ]

  """
  @spec all(call_log :: t()) :: [message()]
  def all(call_log) do
    Agent.get call_log,
              fn state -> state end
  end
end
