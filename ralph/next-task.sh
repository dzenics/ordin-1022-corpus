#!/usr/bin/env bash
# Alege DETERMINIST următoarea bucată de lucru. Modelul NU alege niciodată singur.
# Ieșire pe stdout: "<nr_tabel> <pagina_start>"  |  exit 1 dacă nu mai e nimic de făcut.
set -euo pipefail
CAP="${1:?folosire: [PREFIX=cap|anexa] next-task.sh <NN>}"
PREFIX="${PREFIX:-cap}"
DIR="corpus/tables/$PREFIX-$CAP"
INV="$DIR/INVENTAR.tsv"      # produs de bootstrap: "<nr_tabel>\t<pagina_start>"

[ -f "$INV" ] || { echo "FATAL: lipsește $INV — rulează întâi bootstrap (Pasul 0)" >&2; exit 2; }

while IFS=$'\t' read -r nr pag; do
  [ -n "$nr" ] || continue
  f=$(printf "%s/T%02d.md" "$DIR" "$nr")
  if [ ! -f "$f" ]; then echo "$nr $pag"; exit 0; fi
done < "$INV"

exit 1   # totul e făcut
