defmodule Eject.ExUnit do
  defmacro __using__(_) do
    quote do
      import Eject.ExUnit
    end
  end

  defmacro fake_dep(key, do: body) do
    IO.inspect key,  label: "key"
    IO.inspect body, label: "body"

    module_name = key
                  |> Atom.to_string
                  |> Macro.camelize
                  |> String.to_atom

    module_ast = {
      :defmodule,
      [
        context: Elixir,
        import:  Kernel
      ],
      [
        {
          :__aliases__,
          [alias: false],
          [module_name]
        },
        [do: body]
      ]
    }

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
end
