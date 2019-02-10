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

  # defmacro dependency(key, do: generator) do
  #   quote do
  #     @dependencies %{@dependencies |
  #       dynamic: Map.merge(
  #         @dependencies.dynamic,
  #         %{unquote(key) => fn -> unquote(generator) end}
  #       )
  #     }
  #   end
  # end

  defmacro __before_compile__(_) do
    quote do
      defp process_deps(deps = %{}) do
        
        Eject.Deps.process @dependencies, deps
      end
    end
  end
end

defmodule Test do
  use Eject

  dependency test1: "abc"
  dependency test2: 123
  # dependency :test3, do: :rand.uniform(89) + 10

  def test(deps \\ %{}) do
    process_deps deps
  end
end
