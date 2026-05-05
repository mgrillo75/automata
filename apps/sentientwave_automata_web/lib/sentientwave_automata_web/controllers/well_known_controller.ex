defmodule SentientwaveAutomataWeb.WellKnownController do
  use SentientwaveAutomataWeb, :controller

  alias SentientwaveAutomata.Settings

  def matrix_server(conn, _params) do
    conn = put_resp_header(conn, "access-control-allow-origin", "*")

    case Settings.federation_well_known() do
      {:ok, payload} ->
        json(conn, payload)

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "matrix federation discovery is unavailable", reason: to_string(reason)})
    end
  end
end
