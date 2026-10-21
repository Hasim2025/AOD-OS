
#!/usr/bin/env bash
set -euo pipefail

mkdir -p work

OUTPUT='work/android-x86_64-9.0-r2.iso'

EXPECTED_SHA256='f7eb8fc56f29ad5432335dc054183acf086c539f3990f0b6e9ff58bd6df4604e'

URLS=(
  'https://ftp.jaist.ac.jp/pub/osdn.net/android-x86/71931/android-x86_64-9.0-r2.iso'
  'https://ftp.iij.ad.jp/pub/sourceforge.jp/android-x86/71931/android-x86_64-9.0-r2.iso'
  'https://sourceforge.net/projects/android-x86/files/Release%209.0/android-x86_64-9.0-r2.iso/download'
)

for url in "${URLS[@]}"; do
  echo "Downloading from: $url"
  rm -f "$OUTPUT"

  if curl --fail --location \
      --retry 2 --retry-delay 4 \
      --connect-timeout 25 \
      --max-time 1200 \
      --output "$OUTPUT" "$url"; then

    actual="$(sha256sum "$OUTPUT" | awk '{print $1}')"

    if [[ "$actual" == "$EXPECTED_SHA256" ]]; then
      echo "ISO download and verification successful!"
      exit 0
    fi

    echo "SHA-256 mismatch: $actual" >&2
  else
    echo "Download failed. Trying next mirror."
  fi
done

echo "Unable to download verified ISO." >&2
exit 1
