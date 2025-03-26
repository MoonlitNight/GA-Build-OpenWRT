#!/bin/bash

# Validate input parameters
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_directory> <output_directory>"
  exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"

mkdir -p "$OUTPUT_DIR" || { echo "Error: Failed to create output directory: $OUTPUT_DIR"; exit 1; }

find "$INPUT_DIR" -type f -name "*.img.gz" -print0 | while IFS= read -r -d '' gz_file; do
  base_name=$(basename "$gz_file" .img.gz)
  tmp_img="/tmp/${base_name}.img"
  qcow2_file="${OUTPUT_DIR}/${base_name}.qcow2"
  tar_file="${OUTPUT_DIR}/${base_name}.tar.gz"

  echo "Processing: $gz_file"

  # ----------------------------------------------------------------------
  # Step 1: Decompress .img.gz using gunzip
  # ----------------------------------------------------------------------
  gunzip -c "$gz_file" > "$tmp_img"
  exit_code=$?

  # Accept exit codes 0 (success) or 2 (warning)
  if ! { [ "$exit_code" -eq 0 ] || [ "$exit_code" -eq 2 ]; }; then
    echo "[ERROR] Decompression failed: $gz_file (Exit code: $exit_code)"
    echo "Possible reasons: Critical corruption, permission denied, or disk full"
    rm -f "$tmp_img" 2>/dev/null
    continue
  elif [ "$exit_code" -eq 2 ]; then
    echo "[WARNING] Decompression completed with warnings: $gz_file (Exit code: $exit_code)"
  fi

  # ----------------------------------------------------------------------
  # Step 2: Convert to qcow2 format
  # ----------------------------------------------------------------------
  if ! qemu-img convert -f raw -O qcow2 "$tmp_img" "$qcow2_file"; then
    echo "[ERROR] Conversion failed: $gz_file (Exit code: $?)"
    echo "Possible reasons: Invalid image format or disk space issues"
    rm -f "$tmp_img" "$qcow2_file" 2>/dev/null
    continue
  fi

  # ----------------------------------------------------------------------
  # Step 2.5: Verify the integrity of the converted qcow2 file
  # ----------------------------------------------------------------------
  if ! qemu-img check "$qcow2_file" > /dev/null 2>&1; then
    echo "[ERROR] Integrity check failed: $qcow2_file"
    rm -f "$tmp_img" "$qcow2_file"
    continue
  fi

  # ----------------------------------------------------------------------
  # Step 3: Create individual tar.gz package
  # ----------------------------------------------------------------------
  if ! tar -czf "$tar_file" -C "$OUTPUT_DIR" "${base_name}.qcow2"; then
    echo "[ERROR] Packaging failed: $qcow2_file (Exit code: $?)"
    rm -f "$tar_file" 2>/dev/null
  else
    rm -f "$tmp_img" "$qcow2_file"
    echo "[SUCCESS] Generated: $tar_file"
  fi
done

echo "Processing completed! Output directory: $OUTPUT_DIR"