defmodule Eject.ExUnit.AST do
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

  def prefix_function_code function_ast, prefix_code do
    {
      :def,
      def_metadata,
      [
        function_metadata,
        [do: function_body],
      ]
    } = function_ast

    {
      :def,
      def_metadata,
      [
        function_metadata,
        [
          do: [
            normalize_body(prefix_code),
            normalize_body(function_body),
          ]
        ]
      ],
    }
  end

  defp normalize_body({:__block__, [], body}), do: body
  defp normalize_body(body),                   do: body

  def each_function module_ast, filter do
    {
      :defmodule,
      module_metadata,
      [
        module_data,
        [do: module_body],
      ]
    } = module_ast

    new_module_body = process_each_function module_body, filter
  end

  defp process_each_function(function = {:def, _, _}, filter) do
    filter.(function)
  end
  defp process_each_function(asts, filter) when is_list(asts) do
    Enum.map asts, fn function -> process_each_function function, filter end
  end
end
