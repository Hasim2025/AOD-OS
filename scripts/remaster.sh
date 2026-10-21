#!/usr/bin/env bash
set -euo pipefail

BASE_ISO='work/android-x86_64-9.0-r2.iso'
OUT_ISO='dist/AOD-OS-v1.0-x86_64.iso'

[[ -s "$BASE_ISO" ]] || { echo "Missing $BASE_ISO" >&2; exit 1; }
mkdir -p dist work/configs

cat > work/AOD-OS-INFO.txt <<'INFO'
AOD OS v1.0
============= 
This is a remastered Android-x86 9.0-r2 bootable ISO.
Underlying Android system, kernel and drivers come from Android-x86.
This release changes the ISO volume label and, where accessible,
boot-menu display text. It is NOT a full Android source rebuild.
Original project: https://www.android-x86.org/
License obligations of all upstream components still apply.
INFO

# Preserve original boot files. Change only readable menu text when present.
map_options=()
for iso_path in \
  /isolinux/isolinux.cfg \
  /EFI/BOOT/grub.cfg \
  /boot/grub/grub.cfg \
  /grub/grub.cfg; do
  safe_name="${iso_path//\//_}"
  local_file="work/configs/${safe_name}"
  if xorriso -osirrox on -indev "$BASE_ISO" -extract "$iso_path" "$local_file" >/dev/null 2>&1; then
    if grep -Eq 'Android-x86|Android x86' "$local_file"; then
      sed -i -e 's/Android-x86/AOD OS/g' -e 's/Android x86/AOD OS/g' "$local_file"
      map_options+=( -map "$local_file" "$iso_path" )
      echo "Customized boot-menu text: $iso_path"
    else
      echo "No Android-x86 display text in $iso_path; leaving unchanged."
    fi
  fi
done

# Replay the original ISO's BIOS/UEFI boot instructions while creating output.
xorriso \
  -indev "$BASE_ISO" \
  -outdev "$OUT_ISO" \
  -map work/AOD-OS-INFO.txt /AOD-OS-INFO.txt \
  "${map_options[@]}" \
  -volid AOD_OS_V1 \
  -boot_image any replay \
  -commit \
  -end

[[ -s "$OUT_ISO" ]] || { echo 'No output ISO was produced.' >&2; exit 1; }
echo "ISO created: $OUT_ISO"
