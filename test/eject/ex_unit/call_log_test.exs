defmodule Eject.ExUnit.CallLogTest do
  use ExUnit.Case, async: true

  alias Eject.ExUnit.CallLog

  doctest CallLog

  # TODO rewrite this file with randomized inputs

  describe "record/3 and all/1" do
    test "records messages and retrieves all messages" do
      {:ok, call_log} = CallLog.start_link

      CallLog.record call_log,
                     :function_abc,
                     {}

      CallLog.record call_log,
                     :function_def,
                     {1, 2, 3}

      CallLog.record call_log,
                     :function_ghi,
                     {:a, :b}


      contents = CallLog.all call_log

      assert contents == [
                           {:function_abc, {}},
                           {:function_def, {1, 2, 3}},
                           {:function_ghi, {:a, :b}},
                         ]
    end
  end
end
