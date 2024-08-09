# personal-summary-slack-client

## Overview

- `fetch_message.sh`: Fetch message from slack 
- `fetch_and_jq`: Fetch message and format
- `ask_ai.sh`: Request OpenAI from input with prompt

## Requirements
```
export SLACK_USER_TOKEN=xoxp-your-token
export OPENAI_API_KEY=your-api-key
```

## How to use

### fetch
Sample
```
bash fetch_message.sh -u your.name -b 2024-08-02 -a 2024-07-29
bash src/fetch_and_jq.sh -u your.name -b 2024-08-02 -a 2024-07-29 > output
```

### src/ask_ai.sh 
```
bash src/ask_ai.sh src/prompt.txt > input.json
cat input.json | bash src/ask_ai.sh src/prompt.txt
```

### oneline
```
bash src/fetch_and_jq.sh -u your.name -b 2024-08-02 -a 2024-07-29 | bash src/ask_ai.sh src/prompt.txt
```
