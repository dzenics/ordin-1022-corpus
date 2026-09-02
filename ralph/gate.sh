#!/usr/bin/env bash
# POARTA. Rulează DUPĂ iterație, ÎNAINTE de commit. exit != 0 => iterația se aruncă.
# Rolul ei: să facă fabricarea mai costisitoare decât munca reală.
set -uo pipefail
CAP="${1:?}"; NR="${2:?}"; RENDER_DIR="${3:?}"; P_MIN="${4:?}"; P_MAX="${5:?}"
PREFIX="${PREFIX:-cap}"
F=$(printf "corpus/tables/%s-%s/T%02d.md" "$PREFIX" "$CAP" "$NR")
fail() { echo "GATE FAIL [$NR]: $*" >&2; exit 1; }

# ── 1. fișierul există și e singurul tabel nou ───────────────────────────────
[ -f "$F" ] || fail "nu s-a creat $F"
NEW=$(git status --porcelain | grep -cE '^\?\? corpus/tables/'"$PREFIX"'-'"$CAP"'/T[0-9]+\.md$' || true)
[ "$NEW" -eq 1 ] || fail "s-au creat $NEW fișiere de tabel, se aștepta exact 1"
git status --porcelain | grep -qE '^ D|^D ' && fail "iterația a șters fișiere"

# ── 2. antetul de verificare: prezent, DPI >= 200, pagini în intervalul cap. ──
HDR=$(grep -m1 '^<!-- verificat pe' "$F") || fail "lipsește antetul <!-- verificat pe ... -->"
# Un antet legitim poate declara MAI MULTE valori DPI, de ex.
#   „verificat pe p. 265 @ 300 DPI (grila) și p. 266 @ 200 DPI (notele)".
# Cerem ca ORICARE dintre ele să fie >= 200, deci verificăm minimul.
DPI_ALL=$(grep -oE '@ *[0-9]+ *DPI' <<<"$HDR" | grep -oE '[0-9]+')
[ -n "$DPI_ALL" ] || fail "antetul nu declară DPI"
DPI=$(printf '%s\n' $DPI_ALL | sort -n | head -1)      # minimul declarat
[ "$DPI" -ge 200 ] || fail "cel mai mic DPI declarat este $DPI < 200 (CONSTATARI A2)"
CLAIMED=$(grep -oE 'pp?\. *[0-9]+([ ,–-]+[0-9]+)*' <<<"$HDR" | grep -oE '[0-9]+' | sort -un)
[ -n "$CLAIMED" ] || fail "antetul nu declară pagini"
for p in $CLAIMED; do
  [ "$p" -ge "$P_MIN" ] && [ "$p" -le "$P_MAX" ] || fail "pagina $p e în afara bucății ($P_MIN-$P_MAX)"
done

# ── 3. DOVADA RANDĂRII — cea mai importantă verificare ───────────────────────
# Corelează ce PRETINDE agentul cu ce a FĂCUT. Fără asta, un tabel plauzibil
# și complet inventat trece toate celelalte verificări.
RENDERED=$(ls "$RENDER_DIR" 2>/dev/null | grep -oE '[0-9]+' | sort -un || true)
[ -n "$RENDERED" ] || fail "nu s-a randat NICIO pagină — tabelul nu a fost citit vizual"
for p in $CLAIMED; do
  grep -qx "$p" <<<"$RENDERED" || fail "pretinde verificare pe p.$p dar nu a randat-o"
done

# ── 4. invariant de grilă: toate rândurile unui tabel au același număr de celule
python3 - "$F" <<'PY' || fail "număr inconsecvent de celule într-o grilă markdown"
import re,sys
lines=open(sys.argv[1],encoding='utf-8').read().split('\n')
blk=[];bad=[]
def flush(b,start):
    if len(b)<3: return
    n=[len(re.sub(r'\\\|','',l).split('|')) for l in b]
    hdr=n[0]
    for i,c in enumerate(n[1:],1):
        if c!=hdr: bad.append(f"linia {start+i+1}: {c} celule vs {hdr} în antet")
for i,l in enumerate(lines):
    if l.lstrip().startswith('|'):
        if not blk: st=i
        blk.append(l.strip())
    else:
        flush(blk,st if blk else 0); blk=[]
flush(blk,st if blk else 0)
if bad: print('\n'.join(bad[:5]),file=sys.stderr); sys.exit(1)
PY

# ── 5. marcaj folosit în grilă => trebuie definit (sau declarat nedefinit) ────
BODY=$(sed -n '/^## Conținut/,/^## Referin/p' "$F")
for m in '(+)' '\*\*' '(\*)' '#'; do
  if grep -qF -- "$m" <<<"$BODY"; then
    # ATENȚIE: acceptă și „Note", nu doar „Notă"/„Nota" — `sabloane/TABEL.md` prescrie
    # titlul „## Note Tabelul N (p. …, verbatim)". Forma veche, `not[ăa]`, respingea
    # exact fișierele scrise după șablon și trecea numai pe cele care întâmplător
    # foloseau „nota (a)" în proză. (Bug real, prins la Tabelul 168.)
    grep -qiE 'not[ăae].*(Tabelul|verbatim)|nu (î|i)și define|nu este definit' "$F" \
      || fail "marcajul '$m' apare în grilă dar nu există secțiune de note (CONSTATARI C)"
    break
  fi
done

# ── 6. limbă: corpusul e integral în română (directivă proprietar) ───────────
LEAK=$(grep -oiE '\b(the|and|with|values|sprinklered|marked|such materials|building)\b' "$F" | head -3 || true)
[ -z "$LEAK" ] || fail "scăpare de limbă engleză: $(tr '\n' ' ' <<<"$LEAK")"

# ── 7. titlul conține numărul tabelului ──────────────────────────────────────
head -1 "$F" | grep -qE "Tabelul $NR\b" || fail "titlul nu conține 'Tabelul $NR'"

echo "GATE OK [$NR] — $DPI DPI, pagini: $(tr '\n' ' ' <<<"$CLAIMED")"
