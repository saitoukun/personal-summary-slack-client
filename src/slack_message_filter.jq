.messages.matches[]
| select(.channel.is_private == false)
| {
    text,
    datetime: (.ts | split(".") | .[0] | tonumber | strftime("%Y-%m-%d %H:%M:%S")),
    username,
    channel: .channel.name
  }
