defmodule Eject.ExUnit do
  defmacro __using__(_) do
    quote do
      import Eject.ExUnit
    end
  end

  defmacro defdep(key, functions_asts) do
    IO.inspect key,            label: "key"
    IO.inspect functions_asts, label: "functions_asts"

    functions = Enum.map functions_asts,
                         fn {_, _, definition} -> List.to_tuple definition end

    IO.inspect functions, label: "functions"

    module_name = key
                  |> Atom.to_string
                  |> Macro.camelize
                  |> String.to_atom

    full_module_name = Module.concat __MODULE__,
                                     module_name

    function_asts = Enum.map functions,
                             &Eject.ExUnit.AST.function/1

    IO.inspect function_asts, label: "function_asts"

    module_ast = Eject.ExUnit.AST.module module_name,
                                         function_asts

    quote do
      unquote module_ast

      setup context do
        deps = Map.get context,
                       :deps,
                       %{}

        mailbox = if Map.has_key?(context, :mailbox),
                     do:   Map[:mailbox],
                     else: Eject.ExUnit.Mailbox.create()

        full_module_name = Module.concat __MODULE__,
                                         unquote(module_name)

        new_deps = Map.merge deps,
                   %{unquote(key) => unquote(full_module_name)}

        [deps: new_deps]
      end
    end
  end
end
