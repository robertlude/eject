defmodule Eject.ExUnit.AST do
  @function_metadata        [context: Elixir, import: Kernel]
  @function_header_metadata [context: Elixir]
  @module_metadata          [context: Elixir, import: Kernel]

  def function({name, arity, return}) do
    args = create_args arity

    {
      :def,
      @function_metadata,
      [
        function_header(name, args),
        [do: return]
      ]
    }
  end

  def module(name, body) do
    {
      :defmodule,
      @module_metadata,
      [
        {:__aliases__, [alias: false], [name]},
        [do: block(body)]
      ]
    }
  end

  def block(ast = {:__block__, _, _}), do: ast
  def block([ast]),                    do: ast
  def block(asts) when is_list(asts),  do: {:__block__, [], asts}

  def function_header(name, args) do
    {
      name,
      @function_header_metadata,
      transform_args(args),
    }
  end

  defp create_args(0) do
    []
  end
  defp create_args(count) do
    for index <- 1..count, do: String.to_atom "arg#{index}"
  end

  defp transform_args(args) do
    Enum.map args,
             fn arg -> {arg, [], Elixir} end
  end
end
