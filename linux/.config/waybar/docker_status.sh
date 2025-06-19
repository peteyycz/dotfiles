#!/bin/bash

to_superscript() {
  local digits="$1"
  local sup=""
  for ((i=0; i<${#digits}; i++)); do
    case "${digits:$i:1}" in
      0) sup+="⁰" ;;
      1) sup+="¹" ;;
      2) sup+="²" ;;
      3) sup+="³" ;;
      4) sup+="⁴" ;;
      5) sup+="⁵" ;;
      6) sup+="⁶" ;;
      7) sup+="⁷" ;;
      8) sup+="⁸" ;;
      9) sup+="⁹" ;;
      *) sup+="${digits:$i:1}" ;;
    esac
  done
  echo "$sup"
}

count=$(docker ps -q | wc -l)
sup_count=$(to_superscript "$count")
images=$(docker ps --format '{{.Image}}' | sort | uniq)
if [ "$count" -eq 0 ]; then
  tooltip="No containers running"
else
  tooltip=$(echo "$images" | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')
fi
echo "{\"text\": \"$sup_count\", \"tooltip\": \"$tooltip\", \"class\": \"docker-running\"}"
