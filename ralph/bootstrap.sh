#!/usr/bin/env bash
# Pașii 0 și 1 din PROCEDURA.md, automatizați. Rulează ÎNAINTE de loop.sh.
#   ./ralph/bootstrap.sh 06 305 324               # capitol (implicit)
#   PREFIX=anexa ./ralph/bootstrap.sh 09 543 547  # anexă
#
# Produce:
#   corpus/tables/<PREFIX>-NN/INVENTAR.tsv   — "<nr_tabel>\t<pagina_start>", intrarea buclei
#   corpus/<PREFIX>-NN.md                    — text curent ancorat pe pagini
# și VERIFICĂ limitele reale ale bucății, care în cuprins sunt sistematic decalate.
set -euo pipefail
CAP="${1:?folosire: [PREFIX=cap|anexa] bootstrap.sh <NN> <prima_pagina> <ultima_pagina>}"
A="${2:?}"; B="${3:?}"
PREFIX="${PREFIX:-cap}"      # `cap` pentru capitole, `anexa` pentru anexe
PDF="Ordin-1022-proceduri-formulare.pdf"
DIR="corpus/tables/$PREFIX-$CAP"; mkdir -p "$DIR"

# ── VERIFICAREA LIMITELOR ────────────────────────────────────────────────────
# Măsurat de 4 ori pe acest document, greșit de 4 ori în cuprins: capitolele încep
# ȘI se termină la MIJLOCUL paginii. Cap. 3 = 191-258 (nu 257), Cap. 4 = 258-301
# (nu 300), Cap. 5 = 301-305 (nu 304). Verifică, nu presupune.
echo "── verificarea limitelor (CONSTATARI.md § E) ──"
for p in $((A-1)) "$A" "$B" $((B+1)); do
  hit=$(pdftotext -f "$p" -l "$p" -layout "$PDF" - 2>/dev/null \
        | grep -oE "^ *(CAPITOLUL|ANEXA) [0-9]+(\.[0-9]+)?" | head -1 || true)
  [ -n "$hit" ] && echo "  ⚠️  p.$p conține \"$hit\" — verifică dacă intervalul $A-$B e corect"
done
# 🚩 p. 677-700 NU sunt Anexa 10, ci materia finală (Referințe legislative, Lista
# tabele, Lista figuri). „Lista tabele" conține 174 de titluri de tabel și ar
# recolta tot atâtea numere false în INVENTAR.tsv. Refuzăm intervalul.
for p in $(seq "$A" "$B"); do
  # ATENȚIE: NU folosi `pdftotext | grep -q`. `grep -q` închide conducta la prima
  # potrivire, `pdftotext` primește SIGPIPE, iar `set -o pipefail` transformă
  # potrivirea în EȘEC — garda tăcea exact când trebuia să oprească. (Bug real.)
  TXT=$(pdftotext -f "$p" -l "$p" -layout "$PDF" - 2>/dev/null || true)
  if grep -qE "^ *(List[ăâa] (tabele|figuri)|REFERIN[ŢȚ]E LEGISLATIVE)" <<<"$TXT"; then
    echo "  🚩 p.$p aparține MATERIEI FINALE (referințe / lista tabelelor / lista figurilor)."
    echo "     Aceste pagini NU fac parte din nicio anexă și produc numere de tabel FALSE."
    echo "     Restrânge intervalul: Anexa 10 = 547-667, Anexa 11 = 667-676."
    exit 1
  fi
done
echo "  (fără avertismente = limitele par corecte; oricum confirmă vizual la p.$B)"
echo

# ── Pasul 0: maparea tabel → pagină ─────────────────────────────────────────
# ATENȚIE: titlurile folosesc atât ":" cât și "-" ȘI pot avea SPAȚIU înainte de
# separator — „Tabelul 148 - Număr de niveluri…" (CONSTATARI.md A5). Un regex
# fără ` ?` pierde tabelul în tăcere.
RE_TAB="^\s*Tabelul [0-9]+ ?[:–-]"
RE_FIG="^\s*Figura [0-9]+ ?[:–-]"
for p in $(seq "$A" "$B"); do
  for n in $(pdftotext -f "$p" -l "$p" -layout "$PDF" - 2>/dev/null \
             | grep -oE "$RE_TAB" | grep -oE "[0-9]+"); do
    printf "%s\t%s\n" "$n" "$p"
  done
done > "$DIR/INVENTAR.tsv"

# Inventarul figurilor: la anexe efortul real e la figuri, nu la tabele.
for p in $(seq "$A" "$B"); do
  for n in $(pdftotext -f "$p" -l "$p" -layout "$PDF" - 2>/dev/null \
             | grep -oE "$RE_FIG" | grep -oE "[0-9]+"); do
    printf "%s\t%s\n" "$n" "$p"
  done
done > "$DIR/INVENTAR-FIGURI.tsv"

NT=$(wc -l < "$DIR/INVENTAR.tsv")
NF=$(wc -l < "$DIR/INVENTAR-FIGURI.tsv")

# ── Pasul 1: text curent, ancorat pe pagini ─────────────────────────────────
OUT="corpus/$PREFIX-$CAP.md"
if [ "$PREFIX" = "anexa" ]; then TITLU="Anexa $((10#$CAP))"; else TITLU="Capitolul $((10#$CAP))"; fi
{ echo "# $TITLU"; echo;
  echo "> Sursă: \`$PDF\`, paginile tipărite/PDF **$A–$B**.";
  echo "> Text extras verbatim cu \`pdftotext -layout\`, câte un bloc pe pagină, cu ancora \`[p. N]\`.";
  echo "> **Tabelele din acest fișier NU sunt de încredere** — sunt extragere brută.";
  echo "> Transcrierile autoritative se află în \`$DIR/\`."; echo; } > "$OUT"
for p in $(seq "$A" "$B"); do
  { echo; echo "## [p. $p]"; echo; echo '```'; } >> "$OUT"
  pdftotext -f "$p" -l "$p" -layout "$PDF" - 2>/dev/null | sed -e 's/[[:space:]]*$//' >> "$OUT"
  echo '```' >> "$OUT"
done

echo "── inventar $TITLU ──"
echo "  pagini : $A–$B  ($((B-A+1)) pagini extrase în $OUT)"
echo "  tabele : $NT  →  $(cut -f1 "$DIR/INVENTAR.tsv" | tr '\n' ' ')"
echo "  figuri : $NF titluri numerotate  →  $(cut -f1 "$DIR/INVENTAR-FIGURI.tsv" | tr '\n' ' ')"
[ "$NF" -gt 0 ] && echo "  ⚠️  un TITLU de figură ≠ o PLANȘĂ: Figura 66 (Cap. 3) are 14 planșe."
echo
echo "Titlul din \`$OUT\` este generic — completează-l manual."
echo "Apoi: PREFIX=$PREFIX ./ralph/loop.sh $CAP $A $B"
