#!/usr/bin/env bash
# Bucla. Rulează din rădăcina depozitului denisa.
#   ./ralph/loop.sh 05 301 304                    # capitol, prima pagină, ultima pagină
#   PREFIX=anexa ./ralph/loop.sh 09 543 547       # anexă
set -uo pipefail
CAP="${1:?}"; P_MIN="${2:?}"; P_MAX="${3:?}"
PREFIX="${PREFIX:-cap}"; export PREFIX   # exportat: gate.sh și verify.sh îl citesc
MAX_ITER="${MAX_ITER:-60}"; FAILS=0; MAX_FAILS=3
AUDIT="/tmp/ralph/audit-$PREFIX$CAP.txt"; mkdir -p /tmp/ralph   # în AFARA depozitului

for ((i=1; i<=MAX_ITER; i++)); do
  TASK=$(./ralph/next-task.sh "$CAP") || { echo "═══ TERMINAT: nu mai sunt tabele de prelucrat"; break; }
  NR=${TASK% *}; PAG=${TASK#* }

  # fiecare iterație primește un director de randare PROPRIU și GOL —
  # aceasta e sursa dovezii pentru poarta 3
  RD="/tmp/ralph/$PREFIX$CAP/iter$i"; rm -rf "$RD"; mkdir -p "$RD"

  echo "═══ iterația $i · Tabelul $NR (p. $PAG) ═══"

  # CONTEXT PROASPĂT. Modelul nu știe nimic despre iterația anterioară;
  # tot ce trebuie să știe e pe disc.
  if [ "$PREFIX" = "anexa" ]; then BUCATA="Anexa $((10#$CAP))"; else BUCATA="Capitolul $((10#$CAP))"; fi
  sed -e "s|{{CAP}}|$CAP|g" -e "s|{{NR}}|$NR|g" -e "s|{{PAG}}|$PAG|g" \
      -e "s|{{PREFIX}}|$PREFIX|g" -e "s|{{BUCATA}}|$BUCATA|g" \
      -e "s|{{RENDER_DIR}}|$RD|g" -e "s|{{P_MIN}}|$P_MIN|g" -e "s|{{P_MAX}}|$P_MAX|g" \
      ralph/PROMPT.md \
    | claude -p --dangerously-skip-permissions >> "ralph/log-$PREFIX$CAP.txt" 2>&1

  # Poarta scrie și în jurnalul de audit, care trăiește ÎN AFARA depozitului —
  # altfel rollback-ul de mai jos i-ar șterge exact motivul eșecului.
  # DOUĂ porți, în ordinea costului:
  #   gate.sh   — mecanic, instant, verifică FAPTELE (a randat ce pretinde? grila e consecventă?)
  #   verify.sh — un claude -p separat, ~100s, verifică CONȚINUTUL față de imagine
  # A doua rulează doar dacă prima trece — n-are rost să plătim verificarea semantică
  # pentru o iterație care oricum e respinsă mecanic.
  ./ralph/gate.sh "$CAP" "$NR" "$RD" "$P_MIN" "$P_MAX" 2>&1 | tee -a "$AUDIT"
  GATE=${PIPESTATUS[0]}
  VERIFY=1
  if [ "$GATE" -eq 0 ]; then
    ./ralph/verify.sh "$CAP" "$NR" "$PAG" 2>&1 | tee -a "$AUDIT"
    VERIFY=${PIPESTATUS[0]}
  fi

  if [ "$GATE" -eq 0 ] && [ "$VERIFY" -eq 0 ]; then
    git add corpus/                  # DOAR corpus/ — nu înghiți jurnalele buclei
    git commit -q -m "$BUCATA: Tabelul $NR verificat (ralph, iterația $i)"
    FAILS=0
  elif [ "$VERIFY" -eq 2 ]; then
    # Infrastructură, nu calitate. Aruncăm munca (nu e verificată) dar NU penalizăm
    # tabelul: pauză lungă și reîncercăm același tabel, fără să consumăm din MAX_FAILS.
    echo "  ↳ eșec TRANZITOR — pauză 5 min, reîncerc același tabel" | tee -a "$AUDIT"
    git checkout -- corpus/ 2>/dev/null; git clean -fdq corpus/
    sleep 300
  else
    echo "  ↳ iterație respinsă, se aruncă" | tee -a "$AUDIT"
    git checkout -- corpus/ 2>/dev/null; git clean -fdq corpus/
    FAILS=$((FAILS+1))
    if [ "$FAILS" -ge "$MAX_FAILS" ]; then
      echo "═══ OPRIT: $MAX_FAILS eșecuri consecutive la Tabelul $NR — cere om"; exit 1
    fi
  fi
done

# NU se face push automat. Bucla comite LOCAL; push-ul e acțiune spre exterior
# și rămâne o decizie umană, după ce cineva se uită la ce a produs.
echo "═══ commit-uri locale gata. Verifică apoi: git log --oneline; git push origin main"
