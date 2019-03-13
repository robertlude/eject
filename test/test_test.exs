defmodule TestTest do
  use Eject.ExUnit
  use ExUnit.Case

  depvalue test1: "fake test1"
  depvalue test2: "fake test2"
  depvalue test3: "fake test3"

  depmodule :hello do
    def hello, do: "test"
  end

  test "test", %{deps: deps} do
    Test.test deps
  end
end
