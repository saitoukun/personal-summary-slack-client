#!bin/bash
#
# fetch message "from" and "to"

while getopts "b:a:u:d:" opt; do
  case $opt in
    b) before_date="$OPTARG" ;;
    a) after_date="$OPTARG" ;;
    u) user="$OPTARG" ;;
    *) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

# fetch "from"
cmd="bash src/fetch_message.sh"
[[ -n "$user" ]] && cmd+=" -u $user"
[[ -n "$before_date" ]] && cmd+=" -b $before_date"
[[ -n "$after_date" ]] && cmd+=" -a $after_date"
cmd+=" -d from"

# Execute the command and pipe to jq
eval "$cmd" | jq -f src/slack_message_filter.jq

# fetch "to"
cmd2="bash src/fetch_message.sh"
[[ -n "$user" ]] && cmd2+=" -u $user"
[[ -n "$before_date" ]] && cmd2+=" -b $before_date"
[[ -n "$after_date" ]] && cmd2+=" -a $after_date"
cmd2+=" -d to"

# Execute the command and pipe to jq
eval "$cmd2" | jq -f src/slack_message_filter.jq