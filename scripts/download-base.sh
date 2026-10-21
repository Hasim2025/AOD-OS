#!/usr/bin/env bash
set -euo pipefail

mkdir -p work
OUTPUT='work/android-x86_64-9.0-r2.iso'
EXPECTED_SHA1='1cc85b5ed7c830ff71aecf8405c7281a9c995aa0'
URLS=(
  'https://downloads.sourceforge.net/project/android-x86/Release%209.0/android-x86_64-9.0-r2.iso'
  'https://osdn.net/dl/android-x86/android-x86_64-9.0-r2.iso'
)

for url in "${URLS[@]}"; do
  echo "Trying official upstream release: $url"
  rm -f "$OUTPUT"
  if curl --fail --location --retry 4 --retry-delay 5 --connect-timeout 30 --max-time 900 \
      --user-agent 'Mozilla/5.0 AOD-OS-Builder/1.0' --output "$OUTPUT" "$url"; then
    actual="$(sha1sum "$OUTPUT" | awk '{print $1}')"
    if [[ "$actual" == "$EXPECTED_SHA1" ]]; then
      echo 'Official Android-x86 image checksum verified.'
      exit 0
    fi
    echo "Checksum did not match. Got: $actual" >&2
  else
    echo 'Download failed; trying next official host.' >&2
  fi
done

echo 'Could not fetch a verified Android-x86 image from the official mirrors.' >&2
exit 1
