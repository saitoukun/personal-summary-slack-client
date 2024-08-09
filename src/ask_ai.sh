#!/bin/bash

# OpenAI APIキーを環境変数から取得
API_KEY="${OPENAI_API_KEY}"

# APIキーが設定されているか確認
if [ -z "$API_KEY" ]; then
    echo "エラー: OPENAI_API_KEY 環境変数が設定されていません。" >&2
    exit 1
fi

# モデルを設定
MODEL="gpt-3.5-turbo"

# メッセージ履歴を保存する一時ファイル
HISTORY_FILE=$(mktemp)

# 終了時に一時ファイルを削除
trap "rm -f $HISTORY_FILE" EXIT

# 使用方法の確認
if [ $# -ne 1 ]; then
    echo "使用方法: $0 <プロンプトファイル>" >&2
    echo "JSONデータはパイプで渡すか、ファイルからリダイレクトしてください。" >&2
    exit 1
fi

PROMPT_FILE="$1"

# APIリクエストを送信する関数
send_request() {
    local prompt="$1"
    local messages=$(cat "$HISTORY_FILE")

    # 新しいメッセージを追加
    echo "$messages" | jq '. += [{"role": "user", "content": '"$(jq -Rs . <<<"$prompt")"'}]' > "$HISTORY_FILE"

    # APIリクエストを送信
    response=$(curl -s https://api.openai.com/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $API_KEY" \
      -d '{
        "model": "'"$MODEL"'",
        "messages": '"$(cat $HISTORY_FILE)"'
      }')

    # レスポンスから回答を抽出
    answer=$(echo "$response" | jq -r '.choices[0].message.content')

    # 回答をメッセージ履歴に追加
    echo "$messages" | jq '. += [{"role": "user", "content": '"$(jq -Rs . <<<"$prompt")"'}, {"role": "assistant", "content": '"$(jq -Rs . <<<"$answer")"'}]' > "$HISTORY_FILE"

    echo "$answer"
}

# 初期メッセージ履歴を作成
echo '[]' > "$HISTORY_FILE"

# プロンプトファイルを処理
if [ -f "$PROMPT_FILE" ]; then
    initial_prompt=$(<"$PROMPT_FILE")
    send_request "$initial_prompt" > /dev/null
else
    echo "エラー: $PROMPT_FILE が見つかりません。" >&2
    exit 1
fi

# 標準入力からJSONデータを読み取る
json_content=$(cat)

# JSONデータが空でないか確認
if [ -z "$json_content" ]; then
    echo "エラー: JSONデータが提供されていません。" >&2
    exit 1
fi

# JSONデータの有効性を確認
if ! echo "$json_content" | jq . >/dev/null 2>&1; then
    echo "エラー: 無効なJSONデータです。" >&2
    exit 1
fi

json_prompt="以下のJSONデータを処理してください：$json_content"
send_request "$json_prompt"