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

  defp combine_bodies(a, b) do
    body_a = normalize_body a
    body_b = normalize_body b

    {
      :__block__,
      [],
      body_a ++ body_b,
    }
  end

  defp normalize_body({:__block__, [], body})  when is_list(body), do: body
  defp normalize_body({:__block__, [], body}), do: [body]
  defp normalize_body(body)                    when is_list(body), do: body
  defp normalize_body(body),                   do: [body]

  def each_function(
    {
      :defmodule,
      module_metadata,
      [
        module_data,
        [do: module_body],
      ],
    },
    filter
  ) do
    normalized_module_body = normalize_body module_body

    new_module_body = process_each_function normalized_module_body,
                                            filter
  end

  defp process_each_function(function = {:def, _, _}, filter) do
    filter.(function)
  end
  defp process_each_function(asts, filter) when is_list(asts) do
    Enum.map asts, fn function -> process_each_function function, filter end
  end
end
