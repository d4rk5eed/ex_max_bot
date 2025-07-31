# Messenger MAX API Client (Elixir)

[Русский](#messenger-max-api-клиент-elixir) | [English](#messenger-max-api-client-elixir-1)

---

## Messenger MAX API Клиент (Elixir)

Библиотека для работы с JSON-API мессенджера MAX на языке Elixir. Реализует основные методы для работы с ботом.

### Особенности

- Получение информации о боте
- Получение обновлений через long polling
- Отправка сообщений пользователям
- Полная поддержка обработки ошибок
- Конфигурируемые параметры запросов
- Подробные тесты с моками

### Установка

Добавьте зависимость в ваш `mix.exs`:

```elixir
def deps do
  [
    {:ex_max_bot, git: "https://github.com/d4rk5eed/ex_max_bot.git", tag: "v0.0.1"}
  ]
end
```

Затем выполните:
```bash
mix deps.get
```

### Использование

#### Инициализация

```elixir
token = "ВАШ_ТОКЕН_БОТА"
```

#### Получение информации о боте

```elixir
case ExMaxBot.get_bot_info(token) do
  {:ok, bot_info} ->
    IO.inspect(bot_info)
    # %{user_id: 2345}
  
  {:error, reason} ->
    IO.error("Ошибка: #{reason}")
end
```

#### Получение обновлений (long polling)

```elixir
# Получение обновлений с таймаутом 30 секунд и последней известной позицией
opts = [timeout: 30, marker: 0]

case ExMaxBot.get_updates(token, opts) do
  {:ok, %{"marker" => marker, "updates" => updates}} ->
    Enum.each(updates, fn update ->
      if update["type"] == "message_created" do
        IO.puts("Новое сообщение: #{update["text"]}")
      end
    end)
  
  {:error, reason} ->
    IO.error("Ошибка получения обновлений: #{reason}")
end
```

#### Отправка сообщения

```elixir
user_id = 12345 # можно получить через get_bot_info
message = "Привет! Это тестовое сообщение."

case ExMaxBot.send_message(token, user_id, message) do
  {:ok, %{"message" => msg}} ->
    IO.puts("Сообщение отправлено. ID: #{msg["body"]["mid"]}")
  
  {:error, reason} ->
    IO.error("Ошибка отправки: #{reason}")
end
```

### Тестирование

Библиотека включает полный набор тестов:

```bash
mix test
```

Тесты используют моки для эмуляции различных сценариев работы API:

- Успешные запросы
- Ошибочные ответы API
- Сетевые ошибки
- Специфические коды состояния (200, 204, 404, 500)

### Лицензия

Библиотека распространяется под лицензией MIT. См. файл [LICENSE](LICENSE) для получения подробной информации.

---

## Messenger MAX API Client (Elixir)

A client library for MAX messenger JSON API implemented in Elixir. Provides core functionality for bot integration.

### Features

- Get bot information
- Receive updates via long polling
- Send messages to users
- Comprehensive error handling
- Configurable request parameters
- Detailed tests with mocks

### Installation

Add the dependency to your `mix.exs`:

```elixir
def deps do
  [
    {:ex_max_bot, git: "https://github.com/d4rk5eed/ex_max_bot.git", tag: "v0.0.1"}
  ]
end
```

Then run:
```bash
mix deps.get
```

### Usage

#### Initialization

```elixir
token = "YOUR_BOT_ACCESS_TOKEN"
```

#### Get bot information

```elixir
case ExMaxBot.get_bot_info(token) do
  {:ok, bot_info} ->
    IO.inspect(bot_info)
    # %{user_id: 2345}
  
  {:error, reason} ->
    IO.error("Error: #{reason}")
end
```

#### Get updates (long polling)

```elixir
opts = [timeout: 30, marker: 0]

case ExMaxBot.get_updates(token, opts) do
  {:ok, %{"marker" => marker, "updates" => updates}} ->
    Enum.each(updates, fn update ->
      if update["type"] == "message_created" do
        IO.puts("New message: #{update["text"]}")
      end
    end)
  
  {:error, reason} ->
    IO.error("Error fetching updates: #{reason}")
end

```

#### Send message

```elixir
user_id = 12345
message = "Hello! This is a test message."

case ExMaxBot.send_message(token, user_id, message) do
  {:ok, %{"message_id" => msg_id}} ->
    IO.puts("Message sent. ID: #{msg_id}")
  
  {:error, reason} ->
    IO.error("Sending error: #{reason}")
end
```

### Testing

The library includes comprehensive tests:

```bash
mix test
```

Tests use mocks to simulate various API scenarios:

- Successful requests
- API error responses
- Network failures
- Specific status codes (200, 204, 404, 500)

### License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.