defmodule AzanRestApi.Router do
  # Bring Plug.Router module into scope
  use Plug.Router

  alias AzanRestApi.AzanCalculator

  # Attach the Logger to log incoming requests
  plug(Plug.Logger)

  # Tell Plug to match the incoming request with the defined endpoints
  plug(:match)

  # Once there is a match, parse the response body if the content-type
  # is application/json. The order is important here, as we only want to
  # parse the body if there is a matching route.(Using the Jayson parser)
  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  # Dispatch the connection to the matched handler
  plug(:dispatch)

  # Handler for GET request with "/" path
  get "/" do
    conn = fetch_query_params(conn)

    {latitude, _} = conn.params["latitude"] |> :string.to_float()
    {longitude, _} = conn.params["longitude"] |> :string.to_float()

    body = AzanCalculator.call(latitude, longitude) |> Jason.encode!()
    send_resp(conn, 200, body)
  end

  # Fallback handler when there was no match
  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
