spelling_errors=""
for file in $(find ./source/posts/ -name '*.md'); do
  errors=$(cat $file | aspell list)
  while read -r line; do
    if ! grep -Fxqi "$line" spelling.txt; then
      spelling_errors="$spelling_errors$line\n"
    fi
    echo $spelling_errors
  done <<< "$errors"
  if [[ "$spelling_errors" != "" ]]; then
    echo "spelling errors in "$file
    printf "$spelling_errors"
    exit 1
  fi
done
