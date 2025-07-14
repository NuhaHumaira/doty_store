#!/bin/bash

echo "[" > store.json
first=true

for dir in app/*/; do
  id=$(basename "$dir")
  name=$(echo "$id" | sed -e 's/^./\U&/' -e 's/-/ /g')
  avatar_file=$(find "$dir" -iregex ".*\.\(jpg\|jpeg\|png\)" | head -n 1)
  ipk_file=$(find "$dir" -name "*.ipk" | head -n 1)

  [ -z "$ipk_file" ] && continue

  filename=$(basename "$ipk_file")

  # Parse package and version
  if [[ "$filename" == *_*_* ]]; then
    package=$(echo "$filename" | cut -d_ -f1)
    version=$(echo "$filename" | cut -d_ -f2)
  else
    base=$(basename "$filename" .ipk)
    package=$(echo "$base" | sed -E 's/(.*)-[^-]+$/\1/')
    version=$(echo "$base" | sed -E 's/.*-([^-]+)$/\1/')
  fi

  # Add "v" prefix to version if missing
  if [[ ! "$version" =~ ^v ]]; then
    version="v$version"
  fi

  avatar_url="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main/${avatar_file}"
  ipk_url="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main/${ipk_file}"

  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> store.json
  fi

  cat <<EOF >> store.json
{
  "id": "$id",
  "name": "$name",
  "package": "$package",
  "version": "$version",
  "avatar": "$avatar_url",
  "url": "$ipk_url"
}
EOF

done

echo "]" >> store.json
