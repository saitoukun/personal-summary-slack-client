# personal-summary-slack-client

## Overview

![bg contain](./resources/sample.png)

## Requirements

- jq

### Environment variables
```
export SLACK_USER_TOKEN=xoxp-your-token
export OPENAI_API_KEY=your-api-key
```

## Scripts

### fetch function

- `fetch_message.sh`: Fetch message from slack .
- `fetch_and_jq`: Fetch message and format.
- `fetch_from_and_to.sh` Fetch both type message from slack and format it.

#### Options
- `-u`: Specify the username (default: yohei.saito)
- `-b`: Specify the before date (default: today)
- `-a`: Specify the after date (default: 7 days ago)
- `-d`: Specify the direction ("from" or "to", default: "from")

#### Sample
```
# fetch raw messages
bash fetch_message.sh -u your.name -b 2024-08-02 -a 2024-07-29

# fetch and format it via jq
bash src/fetch_and_jq.sh -u your.name -b 2024-08-02 -a 2024-07-29 > output

fetch "from" and "to" message and format it via jq
src/fetch_from_and_to.sh -u your.name -b 2024-08-02 -a 2024-07-29
```

### src/ask_ai.sh 

- `ask_ai.sh`: Request OpenAI from input with prompt.

#### input

- prompt.txt contains instructions to AI
- JSON data should be passed through a pipe or redirected from a file.

#### Sample

```
bash src/ask_ai.sh src/prompt.txt > input.json
cat input.json | bash src/ask_ai.sh src/prompt.txt
```

### oneline

```
# make summary using only the 'from'
bash src/fetch_and_jq.sh -u your.name -b 2024-08-02 -a 2024-07-29 | bash src/ask_ai.sh src/prompt.txt

# make summary using the 'from' and 'to'
bash src/fetch_from_and_to.sh -u your.name -b 2024-08-02 -a 2024-07-29 | bash src/ask_ai.sh src/prompt.txt
```

## Architecture

```
sequenceDiagram
    Client ->> Slack: fetch messages
    Note right of Client: from, to
    Slack ->> Client: messages
		Client ->> OpenAI API: ask
		OpenAI API ->> Client: response
    Client ->> stdout: result

```
