defmodule ExMaxBotTest do
  use ExUnit.Case, async: true

  # Модуль мока для HTTP клиента
  defmodule HTTPClientMock do
    @success_bot_info %{
      "user_id" => 123,
      "first_name" => "John",
      "last_name" => "Dow",
      "username" => "john_dow",
      "is_bot" => true,
      "last_activity_time" => 1_753_889_215
    }

    @success_updates %{
      "marker" => 123,
      "updates" => [
        %{
          "type" => "message_created",
          "timestamp" => 1_753_889_215,
          "message" => %{
            "recipient" => %{
              "chat_id" => nil,
              "chat_type" => "enum",
              "user_id" => 123
            },
            "body" => %{
              "mid" => "qazsdxc",
              "seq" => 1,
              "text" => "test message",
              "attachments" => nil
            }
          }
        }
      ]
    }

    @success_message_send %{
                 "message" => %{
                   "recipient" => %{
                     "chat_id" => nil,
                     "chat_type" => "enum",
                     "user_id" => 123
                   },
                   "body" => %{
                     "mid" => "qazsdxc",
                     "seq" => 1,
                     "text" => "test message",
                     "attachments" => nil
                   }
                 }
               }

    # Единая функция для обработки всех GET запросов
    def get(url, _headers, _opts \\ []) do
      if url =~ ~r/access_token=test_token/ do
        cond do
          # Проверка для получения информации о боте
          url =~ ~r/\/bots\/me/ ->
            {:ok, %{status_code: 200, body: Jason.encode!(@success_bot_info)}}

          # Проверка для получения обновлений с marker=0
          url =~ ~r/\/updates(.+)marker=0/ ->
            {:ok, %{status_code: 200, body: Jason.encode!(@success_updates)}}

          # Проверка для получения обновлений с marker=1000
          url =~ ~r/\/updates(.+)marker=1000/ ->
            {:ok, %{status_code: 204}}

          # Обработка неизвестных URL
          true ->
            IO.puts("Unexpected URL: #{url}")
            {:error, :not_found}
        end
      else
        {:error, :forbidden}
      end
    end

    # Функция для POST запросов (оставлена без изменений)
    def post("https://botapi.max.ru/messages/send?access_token=test_token", body, _headers) do
      case Jason.decode!(body) do
        %{"user_id" => "user_123", "text" => _} ->
          {:ok,
           %{
             status_code: 200,
             body:
               Jason.encode!(@success_message_send)
           }}

        _ ->
          {:ok, %{status_code: 404, body: ""}}
      end
    end
  end

  @test_token "test_token"

  describe "get_bot_info/1" do
    test "возвращает информацию о боте" do
      assert {:ok, info} = ExMaxBot.get_bot_info(@test_token, HTTPClientMock)
      assert info["user_id"] == 123
      assert info["first_name"] == "John"
      assert info["last_name"] == "Dow"
      assert info["username"] == "john_dow"
      assert info["is_bot"] == true
      assert info["last_activity_time"] == 1_753_889_215
    end
  end

  describe "get_updates/2" do
    test "получает обновления через long polling" do
      assert {:ok, data} =
               ExMaxBot.get_updates(@test_token, [timeout: 5, marker: 0], HTTPClientMock)

      assert data["marker"] == 123
      assert [update | _] = data["updates"]
      assert update["type"] == "message_created"
      assert get_in(update, ["message", "body", "text"]) == "test message"
    end

    test "возвращает пустой список при таймауте" do
      assert {:ok, data} =
               ExMaxBot.get_updates(@test_token, [timeout: 1, marker: 1000], HTTPClientMock)

      assert data["updates"] == []
      assert data["marker"] == 1000
    end
  end

  describe "send_message/3" do
    test "успешная отправка сообщения" do
      assert {:ok, response} =
               ExMaxBot.send_message(@test_token, "user_123", "Привет!", HTTPClientMock)

      assert get_in(response, ["message", "body", "text"]) == "test message"
    end

    test "ошибка при неверном user_id" do
      assert {:error, "HTTP error 404"} =
               ExMaxBot.send_message(@test_token, "invalid_user", "Текст", HTTPClientMock)
    end
  end
end
