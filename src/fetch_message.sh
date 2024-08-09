#!/bin/bash

# Constants
readonly DEFAULT_DAYS_AGO=7
readonly DEFAULT_USER="yohei.saito"

# Functions
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

adjust_date() {
  local date=$1
  local adjustment=$2
  if [[ "$OSTYPE" == "darwin"* ]]; then
    date -v"${adjustment}"d -jf "%Y-%m-%d" "${date}" +%Y-%m-%d
  else
    date -d "${date} ${adjustment} day" +%Y-%m-%d
  fi
}

get_default_date() {
  local days_ago=$1
  if [[ "$OSTYPE" == "darwin"* ]]; then
    date -v-"${days_ago}"d +%Y-%m-%d
  else
    date -d "${days_ago} days ago" +%Y-%m-%d
  fi
}

# Main function
main() {
  local before_date after_date user

  # Parse arguments
  while getopts "b:a:u:" opt; do
    case $opt in
      b) before_date="$OPTARG" ;;
      a) after_date="$OPTARG" ;;
      u) user="$OPTARG" ;;
      *) err "Invalid option -$OPTARG"; exit 1 ;;
    esac
  done

  # Set default values
  before_date=${before_date:-$(get_default_date 0)}
  after_date=${after_date:-$(get_default_date $DEFAULT_DAYS_AGO)}
  user=${user:-$DEFAULT_USER}

  # Adjust dates
  local adjust_before_date adjust_after_date
  adjust_before_date=$(adjust_date "$before_date" "+1")
  adjust_after_date=$(adjust_date "$after_date" "-1")

  # Construct URL
  local url_base query url
  url_base="https://slack.com/api/search.messages?"
  query="query=from%3A%40${user}%20before%3A${adjust_before_date}%20after%3A${adjust_after_date}"
  url="${url_base}${query}&sort=timestamp&pretty=1&page=2"

  # Validate token
  if [[ -z "$SLACK_USER_TOKEN" ]]; then
    err "Error: SLACK_USER_TOKEN environment variable is not set."
    exit 1
  fi

  # Execute API call
  curl -X GET "${url}" -H "Authorization: Bearer ${SLACK_USER_TOKEN}"
}

# Execute main function
main "$@"
