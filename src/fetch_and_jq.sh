#!/bin/bash
#
# fetch message from slack and jq.
# output: {text, datetime}

while getopts "b:a:u:d:" opt; do
  case $opt in
    b) before_date="$OPTARG" ;;
    a) after_date="$OPTARG" ;;
    u) user="$OPTARG" ;;
    d) direction="$OPTARG" ;;
    *) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

# Construct the command with the parsed arguments
cmd="bash src/fetch_message.sh"
[[ -n "$user" ]] && cmd+=" -u $user"
[[ -n "$before_date" ]] && cmd+=" -b $before_date"
[[ -n "$after_date" ]] && cmd+=" -a $after_date"
[[ -n "$direction" ]] && cmd+=" -d $direction"

# Execute the command and pipe to jq
eval "$cmd" | jq -f src/slack_message_filter.jq
