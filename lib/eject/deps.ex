defmodule Eject.Deps do
  defstruct dynamic: [],
            static:  %{}

  def process(deps = %__MODULE__{}, values = %{}) do
    Enum.reduce deps.dynamic,
                Map.merge(deps.static, values),
                &check_dynamic/2
  end

  defp check_dynamic({key, function}, deps) do
    Map.put_new_lazy(deps, key, function)
  end
end
