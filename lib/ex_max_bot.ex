defmodule ExMaxBot do
  @moduledoc """
  Библиотека для работы с JSON-API мессенджера MAX
  """

  @api_base_url "https://botapi.max.ru/"
  @default_http_client HTTPoison

  @headers [{"Content-Type", "application/json"}]

  @spec get_bot_info(binary()) :: {:error, binary()} | {:ok, any()}
  @doc """
  Возвращает информацию о текущем боте по токену доступа
  """
  def get_bot_info(token, http_client \\ @default_http_client) do
    uri =
      @api_base_url
      |> apply_path("bots/me")
      |> apply_query(%{access_token: token})
      |> to_string()

    case http_client.get(uri, @headers) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %{status_code: status}} ->
        {:error, "HTTP error #{status}"}

      {:error, reason} ->
        {:error, inspect(reason)}
    end
  end

  @spec get_updates(binary(), keyword()) :: {:error, binary()} | {:ok, any()}
  @doc """
  Получает обновления через long polling
  """
  def get_updates(token, opts \\ [], http_client \\ @default_http_client) do
    timeout = Keyword.get(opts, :timeout, 25)
    marker = Keyword.get(opts, :marker, 0)

    uri =
      @api_base_url
      |> apply_path("/updates")
      |> apply_query(%{access_token: token, marker: marker})
      |> to_string()

    case http_client.get(uri, @headers, recv_timeout: (timeout + 5) * 1000) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %{status_code: 204}} ->
        {:ok, %{"marker" => marker, "updates" => []}}

      {:ok, %{status_code: status}} ->
        {:error, "HTTP error #{status}"}

      {:error, reason} ->
        {:error, inspect(reason)}
    end
  end

  @spec send_message(binary(), integer(), binary()) :: {:error, binary()} | {:ok, any()}
  @doc """
  Отправляет сообщение пользователю
  """
  def send_message(token, user_id, text, http_client \\ @default_http_client) do
    uri =
      @api_base_url
      |> apply_path("messages/send")
      |> apply_query(%{access_token: token})
      |> to_string()

    payload = Jason.encode!(%{user_id: user_id, text: text})

    case http_client.post(uri, payload, @headers) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %{status_code: status}} ->
        {:error, "HTTP error #{status}"}

      {:error, reason} ->
        {:error, inspect(reason)}
    end
  end

  defp apply_path(url, path) do
    [url, path]
    |> Path.join()
    |> URI.parse()
  end

  defp apply_query(uri, query_map) do
    %{uri | query: URI.encode_query(query_map)}
  end
end
