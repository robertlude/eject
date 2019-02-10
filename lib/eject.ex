defmodule Eject do
  @moduledoc """
  Documentation for Eject.
  """

  defmacro __using__(_) do
    quote do
      import Eject

      @dependencies %Eject.Deps{}

      @before_compile Eject
    end
  end

  defmacro macro_test() do
    quote do
      IO.puts "Hello"
    end
  end

  defmacro dependency([{key, value}]) do
    quote do
      @dependencies %{@dependencies |
        static: Map.merge(
                  @dependencies.static,
                  %{unquote(key) => unquote(value)}
                )
      }
    end
  end

  defmacro dependency(key, do: generator) do
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

defmodule Test do
  use Eject

  dependency test1: "abc"
  dependency test2: 123
  dependency :test3, do: :rand.uniform(89) + 10

  def test(deps \\ %{}) do
    %{
      test1: test1,
      test2: test2,
      test3: test3,
    } = process_deps deps

    IO.inspect test1, label: "test1"
    IO.inspect test2, label: "test2"
    IO.inspect test3, label: "test3"

    :ok
  end
end

ExUnit.start
defmodule TestTest do
  use ExUnit.Case
  use Eject.ExUnit

  fake_dep :my_fake_deps do
    def test_fn(x), do: x * x
  end
end
