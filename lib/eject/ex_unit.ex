defmodule Eject.ExUnit do
  alias __MODULE__.AST

  defmacro __using__(_) do
    quote do
      import Eject.ExUnit
    end
  end

  defmacro depmodule(key, do: body) do
    module_name = key
                  |> Atom.to_string
                  |> Macro.camelize
                  |> String.to_atom

    module_ast = AST.module module_name, body

    quote do
      unquote module_ast

      setup context do
        deps = Map.get context,
                       :deps,
                       %{}

        full_module_name = Module.concat __MODULE__,
                                         unquote(module_name)

        new_deps = Map.merge deps,
                             %{unquote(key) => full_module_name}

        [deps: new_deps]
      end
    end
  end

  defmacro depvalue([{key, value}]) do
    quote do
      setup context do
        deps = Map.get context,
                       :deps,
                       %{}

        new_deps = Map.merge deps,
                             %{unquote(key) => unquote(value)}

        [deps: new_deps]
      end
    end
  end
end
