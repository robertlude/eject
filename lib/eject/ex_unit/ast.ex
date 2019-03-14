defmodule Eject.ExUnit.AST do
  @moduledoc """
  Provides a set of functions for manipulating ASTs
  """

  # TODO revisit this definition -- an AST type might actually be `any()`, but
  #      i should verify this
  @type t() :: any()

  @doc """
  Creates an AST for a module with a given name and body

  ## Example

      iex> AST.module MyModule, {:example, :body, :total, :nonsense}
      {
        :defmodule,
        [
          context: Elixir,
          import:  Kernel,
        ],
        [
          {
            :__aliases__,
            [alias: false],
            [MyModule],
          },
          [do: {:example, :body, :total, :nonsense}],
        ],
      }

  """
  @spec module(name :: atom(), body :: t()) :: t()
  def module name, body do
    {
      :defmodule,
      [
        context: Elixir,
        import:  Kernel
      ],
      [
        {
          :__aliases__,
          [alias: false],
          [name]
        },
        [do: body]
      ]
    }
  end

  @doc """
  Creates an AST for a function with a given name and body

  ## Example

      iex> AST.function :my_function, {:example, :body, :total, :nonsense}
      {
        :def,
        [
          context: Elixir,
          import:  Kernel,
        ],
        [
          {
            :my_function,
            [context: Elixir],
            Elixir,
          },
          [do: {:example, :body, :total, :nonsense}],
        ],
      }

  """
  @spec function(name :: atom(), body :: t()) :: t()
  def function name, body do
    {
      :def,
      [
        context: Elixir,
        import:  Kernel,
      ],
      [
        {
          name,
          [context: Elixir],
          Elixir,
        },
        [do: body]
      ]
    }
  end

  @doc """
  Creates an AST for a function which contains the code from an original
  function, but prepended with a provided body

  ## Example

      iex> my_function = quote do
      ...>   def my_function do
      ...>     :hello
      ...>   end
      ...> end
      ...> prefix_body = quote do
      ...>   IO.puts "i'm a prefix"
      ...> end
      ...> AST.prefix_function_code(
      ...>   my_function,
      ...>   prefix_body
      ...> )
      {
        :def,
        [
          context: Eject.ExUnit.ASTTest,
          import:  Kernel,
        ],
        [
          {
            :my_function,
            [context: Eject.ExUnit.ASTTest],
            Eject.ExUnit.ASTTest,
          },
          [
            do: {
              :__block__,
              [],
              [
                {
                  {
                    :.,
                    [],
                    [
                      {
                        :__aliases__,
                        [alias: false],
                        [:IO]
                      },
                      :puts
                    ]
                  },
                  [],
                  ["i'm a prefix"]
                },
                :hello,
              ],
            },
          ],
        ],
      }
  """
  @spec prefix_function_code(function :: t(), prefix_code :: t()) :: t()
  def prefix_function_code(
    {
      :def,
      def_metadata,
      [
        function_metadata,
        [do: function_body],
      ]
    },
    prefix_code
  ) do
    {
      :def,
      def_metadata,
      [
        function_metadata,
        [
          do: combine_bodies(
                normalize_body(prefix_code),
                normalize_body(function_body)
              ),
        ],
      ],
    }
  end

  @doc """
  Iterates over each function AST in a given module AST and calls the provided
  processing function for each one.
  """
  def each_function(
    {
      :defmodule,
      _module_metadata,
      [
        _module_data,
        [do: module_body],
      ],
    },
    processor
  ) do
    normalized_module_body = normalize_body module_body

    process_each_function normalized_module_body,
                          processor
  end

  @spec combine_bodies(a :: t(), b :: t()) :: t()
  defp combine_bodies(a, b) do
    body_a = normalize_body a
    body_b = normalize_body b

    {
      :__block__,
      [],
      body_a ++ body_b,
    }
  end

  @spec normalize_body(body :: t()) :: t()
  defp normalize_body({:__block__, [], body})  when is_list(body), do: body
  defp normalize_body({:__block__, [], body}), do: [body]
  defp normalize_body(body)                    when is_list(body), do: body
  defp normalize_body(body),                   do: [body]

  @spec process_each_function(function :: t(), processor :: function) :: any()
  defp process_each_function(function = {:def, _, _}, processor) do
    processor.(function)
  end
  defp process_each_function(asts, processor) when is_list(asts) do
    Enum.map asts, fn function -> process_each_function function, processor end
  end
end
