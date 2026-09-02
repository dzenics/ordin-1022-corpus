#!/usr/bin/env bash
# Verificator adversarial: un claude -p SEPARAT care vede DOAR imaginea + markdown-ul
# și e întrebat ce nu se potrivește. Rulează ca poartă suplimentară, după gate.sh.
#   verify.sh <cap> <nr> <pagina_principala> [fisier_md]
# exit 0 = MATCH, exit 1 = MISMATCH sau verdict absent.
set -uo pipefail
CAP="${1:?}"; NR="${2:?}"; PAG="${3:?}"
PREFIX="${PREFIX:-cap}"
MD="${4:-$(printf 'corpus/tables/%s-%s/T%02d.md' "$PREFIX" "$CAP" "$NR")}"
PDF="Ordin-1022-proceduri-formulare.pdf"
VDIR="/tmp/ralph/verify/$PREFIX$CAP-T$NR"; rm -rf "$VDIR"; mkdir -p "$VDIR"

[ -f "$MD" ] || { echo "VERIFY FAIL [$NR]: lipsește $MD" >&2; exit 1; }

# Randare PROPRIE, independentă. Nu refolosim decupajele scriitorului — el le-a ales,
# și un decupaj prost ales poate ascunde exact celula greșită.
#
# Randăm TOATE paginile pe care transcrierea pretinde că le-a verificat, nu doar prima.
# Un tabel întins pe două pagini ar rămâne altfel verificat pe jumătate — exact cazul
# celor 14 tabele din Cap. 3 care trec peste saltul de pagină.
PAGES=$(grep -m1 '^<!-- verificat pe' "$MD" \
        | grep -oE 'pp?\. *[0-9]+([ ,–-]+[0-9]+)*' | grep -oE '[0-9]+' | sort -un)
PAGES=$(printf '%s\n%s\n' "$PAG" "$PAGES" | sort -un)
for p in $PAGES; do pdftoppm -f "$p" -l "$p" -r 300 -png "$PDF" "$VDIR/p$p" 2>/dev/null; done
IMG=$(ls "$VDIR"/p*.png 2>/dev/null | sed 's/^/  - /' | paste -sd'\n' -)
[ -n "$IMG" ] || { echo "VERIFY FAIL [$NR]: nu s-a putut randa nicio pagină" >&2; exit 1; }

OUT="$VDIR/raport.txt"
# Substituția NU se face cu sed: lista de imagini e multi-linie, iar sed nu poate
# insera linii noi într-un `s|||`. (Bug real, prins la prima rulare pe Cap. 4.)
IMG="$IMG" MD_ABS="$PWD/$MD" NR="$NR" python3 - ralph/verify-prompt.md > "$VDIR/prompt.txt" <<'PY'
import os,sys
t=open(sys.argv[1],encoding='utf-8').read()
for k,v in (('{{IMG}}','\n'+os.environ['IMG']+'\n'),
            ('{{MD}}',os.environ['MD_ABS']),
            ('{{NR}}',os.environ['NR'])):
    t=t.replace(k,v)
sys.stdout.write(t)
PY
# Erorile TRANZITORII de infrastructură (529 Overloaded, 429, rate limit, timeout) NU
# sunt semnale de calitate. Reîncercăm cu pauză crescătoare; dacă tot nu merge, ieșim
# cu cod 2, pe care bucla îl tratează separat — nu incrementează contorul de eșecuri.
for attempt in 1 2 3; do
  claude -p --dangerously-skip-permissions < "$VDIR/prompt.txt" > "$OUT" 2>&1
  if grep -qiE 'API Error: *(429|500|502|503|529)|Overloaded|rate.?limit|timed? ?out' "$OUT"; then
    echo "  ↳ eroare tranzitorie (încercarea $attempt/3), reîncerc..." >&2
    sleep $((attempt * 30)); continue
  fi
  break
done
if grep -qiE 'API Error: *(429|500|502|503|529)|Overloaded' "$OUT"; then
  echo "TRANZITOR [$NR]: infrastructura nu răspunde după 3 încercări — NU e eșec de calitate" >&2
  exit 2
fi

V=$(grep -oE '^VERDICT: *(MATCH|MISMATCH)' "$OUT" | tail -1 | grep -oE 'MATCH|MISMATCH')

case "$V" in
  MATCH)    echo "VERIFY OK [$NR] — verificator adversarial: MATCH"; exit 0 ;;
  MISMATCH) echo "VERIFY FAIL [$NR] — nepotriviri raportate:" >&2
            grep -vE '^VERDICT:' "$OUT" | grep -E ':' | tail -8 >&2
            echo "  raport complet: $OUT" >&2; exit 1 ;;
  *)        echo "VERIFY FAIL [$NR]: verificatorul nu a dat verdict (vezi $OUT)" >&2; exit 1 ;;
esac
