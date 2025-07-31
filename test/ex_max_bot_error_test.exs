defmodule ExMaxBotErrorTest do
  use ExUnit.Case, async: true

  # Модуль мока для ошибок
  defmodule HTTPClientErrorMock do
    def get(_, _), do: {:error, :econnrefused}

    def get(_, _, _), do: {:error, :timeout}

    def post(_, _, _) do
      {:ok, %{status_code: 500, body: "Internal Server Error"}}
    end
  end

  @test_token "test_token"

  test "get_bot_info обрабатывает сетевые ошибки" do
    assert {:error, ":econnrefused"} = ExMaxBot.get_bot_info(@test_token, HTTPClientErrorMock)
  end

  test "get_updates обрабатывает таймауты" do
    assert {:error, ":timeout"} = ExMaxBot.get_updates(@test_token, [], HTTPClientErrorMock)
  end

  test "send_message обрабатывает 500 ошибку" do
    assert {:error, "HTTP error 500"} =
             ExMaxBot.send_message(@test_token, "user_123", "Текст", HTTPClientErrorMock)
  end
end
