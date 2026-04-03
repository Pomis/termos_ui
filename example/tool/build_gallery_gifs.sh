#!/usr/bin/env bash
# Regenerate PNG frame sequences (goldens) and merge them into doc/gallery/*.gif.
# Requires: flutter, ffmpeg, bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${EXAMPLE_ROOT}"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg not found. Install it (e.g. brew install ffmpeg) and retry." >&2
  exit 1
fi

# Default GIF width matches 400 logical dp captures (override with GALLERY_GIF_WIDTH).
TARGET_WIDTH="${GALLERY_GIF_WIDTH:-400}"
EXCLUDED_IDS=("group" "scanlines")

export UPDATE_GALLERY=1
flutter test test/gallery_frame_export_test.dart --update-goldens

FRAMES_DIR="${EXAMPLE_ROOT}/test/goldens/export"
OUT_DIR="${EXAMPLE_ROOT}/doc/gallery"
mkdir -p "${OUT_DIR}"

# Opaque GIF pipeline: drop alpha, high-color palette, smoother dither, Lanczos scale.
vf_encode() {
  local scale_filter="scale=${TARGET_WIDTH}:-1:flags=lanczos+accurate_rnd+full_chroma_inp,format=rgb24"
  echo "${scale_filter},split[s0][s1];[s0]palettegen=max_colors=256:reserve_transparent=0:stats_mode=diff[p];[s1][p]paletteuse=dither=floyd_steinberg:diff_mode=rectangle:new=1"
}

for demo_dir in "${FRAMES_DIR}"/*/; do
  [[ -d "${demo_dir}" ]] || continue
  id="$(basename "${demo_dir}")"
  out_gif="${OUT_DIR}/${id}.gif"
  first_frame="${demo_dir}frame_000.png"
  second_frame="${demo_dir}frame_001.png"

  if [[ " ${EXCLUDED_IDS[*]} " == *" ${id} "* ]]; then
    rm -f "${out_gif}"
    echo "skip ${id}: excluded from README GIF export"
    continue
  fi

  if [[ ! -f "${first_frame}" ]]; then
    echo "skip ${id}: missing frame_000.png" >&2
    continue
  fi

  if [[ -f "${second_frame}" ]]; then
    # Match wall-clock ~28ms * frame_count for loader (~36 fps).
    anim_fps=36
    ffmpeg -y -framerate "${anim_fps}" -i "${demo_dir}frame_%03d.png" \
      -vf "$(vf_encode)" \
      -loop 0 \
      "${out_gif}"
  else
    ffmpeg -y -i "${first_frame}" \
      -vf "$(vf_encode)" \
      -loop 0 \
      "${out_gif}"
  fi
  echo "${out_gif}"
done

echo "Done. Commit updated GIFs under example/doc/gallery/ as needed."
