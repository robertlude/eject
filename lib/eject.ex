defmodule Eject do
  @moduledoc """
  Documentation for Eject.
  """

  # TODO delete me
  alias Eject.ExUnit.AST

  defmacro __using__(_) do
    quote do
      import Eject

      @dependencies %Eject.Deps{}

      @before_compile Eject
    end
  end

  defmacro macro_test() do
    body_ast = quote do
      IO.puts "this is a test"
      123
    end

    IO.inspect body_ast, label: "body_ast"

    function_ast = AST.function :prefix_test, body_ast

    IO.inspect function_ast, label: "function_ast"

    prefix_ast = quote do
      IO.puts "I'm about to say something..."
    end

    IO.inspect prefix_ast, label: "prefix_ast"

    final_ast = AST.prefix_function_code function_ast, prefix_ast

    IO.inspect final_ast, label: "final_ast"

    final_ast
  end

  defmacro defdep([{key, value}]) do
    quote do
      @dependencies %{@dependencies |
        static: Map.merge(
                  @dependencies.static,
                  %{unquote(key) => unquote(value)}
                )
      }
    end
  end

  defmacro defdep(key, do: generator) do
    function_name = String.to_atom "__dynamic_dependency_generator__#{key}__"

    quote do
      def unquote(Macro.var(function_name, Elixir)), do: unquote(generator)

      @dependencies %{@dependencies |
        dynamic: [unquote(key) | @dependencies.dynamic],
      }
    end
  end

  defmacro __before_compile__(_) do
    quote do
      defp process_deps(deps = %{}) do
        deps_with_static = Map.merge @dependencies.static, deps

        Enum.reduce @dependencies.dynamic,
                    deps_with_static,
                    fn key, deps ->
                      name_string = "__dynamic_dependency_generator__#{key}__"

                      name_atom = String.to_atom name_string

                      generator = :erlang.make_fun __MODULE__,
                                                   name_atom,
                                                   0

                      Map.put_new_lazy deps,
                                       key,
                                       generator
                    end
      end
    end
  end
end

defmodule Hello do
  def hello, do: "world"
end

defmodule Test do
  use Eject

  defdep test1: "abc"
  defdep test2: 123
  defdep :test3, do: :rand.uniform(89) + 10
  defdep hello: Hello

  macro_test()

  def test(deps \\ %{}) do
    %{
      hello: hello,
      test1: test1,
      test2: test2,
      test3: test3,
    } = process_deps deps

    IO.inspect test1,       label: "test1"
    IO.inspect test2,       label: "test2"
    IO.inspect test3,       label: "test3"
    IO.inspect hello.hello, label: "hello.hello"

    :ok
  end
end
