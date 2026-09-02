# `ralph/` — bucla automată de prelucrare a tabelelor

Prelucrează tabelele unui capitol **câte unul, în sesiuni cu context proaspăt**, cu două porți de
verificare. Numele vine de la tehnica „Ralph" (o buclă care rulează același prompt la nesfârșit,
cu starea pe disc în loc de memorie).

**Face doar Pasul 2 din `PROCEDURA.md`** (tabelele). Pașii 3–6 — figurile, `MANIFEST.md`,
`TEST-ACURATETE.md`, integrarea — rămân pentru o sesiune lungă. Vezi „De ce hibrid".

---

## Folosire

```bash
./ralph/bootstrap.sh 06 305 324      # Pașii 0-1: inventar + text; verifică limitele
# completează manual titlul din corpus/cap-06.md
./ralph/loop.sh      06 305 324      # Pasul 2: un tabel per iterație, până termină
```

### Anexe: variabila `PREFIX`

Toate cele șase scripturi (`bootstrap.sh`, `next-task.sh`, `loop.sh`, `gate.sh`, `verify.sh`,
`PROMPT.md`) construiesc căile din **`PREFIX`**, cu valoarea implicită `cap`. Pentru anexe:

```bash
PREFIX=anexa ./ralph/bootstrap.sh 08 534 542   # → corpus/anexa-08.md, corpus/tables/anexa-08/
PREFIX=anexa ./ralph/loop.sh      08 534 542
```

`loop.sh` **exportă** `PREFIX`, deci `gate.sh` și `verify.sh` îl moștenesc; dacă rulezi porțile
manual, exportă-l tu. Numerele de tabel cu trei cifre sunt în regulă: `printf "T%02d.md" 148`
dă `T148.md` (`%02d` este o lățime **minimă**, nu una fixă).

⚠️ **`bootstrap.sh` refuză intervalele care ating materia finală** (pp. 677–700: „REFERINȚE
LEGISLATIVE", „Lista tabele", „Lista figuri"). „Lista tabele" enumeră toate cele 174 de titluri
de tabel și ar umple `INVENTAR.tsv` cu 173 de numere false. Anexa 10 se termină la **p. 667**,
Anexa 11 la **p. 676**.

Bucla **comite local** și **nu face push** — push-ul rămâne decizie umană, după ce cineva se uită
la ce a produs.

**Rulează într-un worktree izolat**, nu în clona principală:

```bash
git worktree add /tmp/ralph-c6 -b ralph/cap-06
cd /tmp/ralph-c6 && ./ralph/loop.sh 06 305 324
# după verificare:
cd - && git merge --no-ff ralph/cap-06
```

Copiii rulează cu `--dangerously-skip-permissions`, nesupravegheați. Worktree-ul limitează raza de
acțiune la un director throwaway.

**Pornește-o astfel încât să fii notificat la terminare.** `nohup ... &` nu anunță pe nimeni; o
buclă care moare în tăcere arată identic cu una care lucrează.

---

## Fișiere

| Fișier | Rol |
|---|---|
| `bootstrap.sh` | Pașii 0-1: `INVENTAR.tsv` + `INVENTAR-FIGURI.tsv` + `corpus/<PREFIX>-NN.md`; verifică limitele bucății |
| `next-task.sh` | **Scriptul alege tabelul, nu modelul** (altfel face întâi tabelele ușoare) |
| `PROMPT.md` | Promptul fix, cu `{{NR}}`/`{{PAG}}` substituite per iterație |
| `gate.sh` | Poarta 1 — mecanică, instant: 7 verificări asupra *faptelor* |
| `verify.sh` + `verify-prompt.md` | Poarta 2 — un `claude -p` separat care compară *conținutul* cu imaginea |
| `loop.sh` | Driverul |
| `check-grile.py` | Verificarea de grilă, rulabilă peste tot corpusul (nu doar un fișier) |

Jurnale: `/tmp/ralph/audit-capNN.txt` (audit, **în afara depozitului** — vezi mai jos),
`/tmp/ralph/capNN/iterN/` (randările fiecărei iterații), `/tmp/ralph/verify/` (rapoartele
verificatorului).

---

## Cele două porți

**`gate.sh`** — mecanic, instant. Verifică: fișierul e singurul tabel nou · antetul
`<!-- verificat pe … -->` există, cu DPI ≥ 200 și pagini în intervalul capitolului · **paginile
pretinse au fost efectiv randate** · fiecare rând al grilei are numărul de celule al antetului ·
marcajele din grilă sunt definite în note · fără scăpări de limbă engleză · titlul conține numărul.

Verificarea cea mai importantă este a treia: **corelează ce pretinde agentul cu ce a făcut.**
Antetul devine o afirmație falsificabilă. Nu poate demonstra că agentul s-a *uitat* la imagine, dar
mută fabricarea din „calea de minimă rezistență" în „efort deliberat".

**`verify.sh`** — un `claude -p` separat, ~100 s. Primește **doar** randările proprii (nu decupajele
scriitorului, pe care el le-a ales) și markdown-ul, și e instruit să caute nepotriviri, nu să
confirme. Raportează MISMATCH și când **nu poate** verifica o celulă: incertitudinea nu e „OK".

Testat în ambele sensuri: MATCH pe transcrierea corectă; MISMATCH cu celula localizată exact pe o
copie cu un singur indice inversat (`C5Sₐ` → `C5S₂₀₀`); MATCH pe un tabel întins pe două pagini, cu
antet repetat și coloană îmbinată (`T47`).

---

## Ce NU prinde nicio poartă

- **Erorile de contextualizare** — că un tabel e doar o ramură a articolului său
  (`CONSTATARI.md` B4), că lipsește o trimitere, că domeniul de aplicare e descris greșit.
  Verificatorul compară grila și notele cu imaginea; atât.
- **Figurile.** Nu există grilă, număr de celule sau antet de verificat. Un index de figuri ar trece
  orice. Anexa 10 (~300 de titluri, probabil 600+ planșe) **nu** poate fi prelucrată așa.
- **Sinteza.** Vezi mai jos.

---

## De ce hibrid

Cele mai valoroase constatări din Capitolul 3 — „`T69` = `T78` = `T82` celulă cu celulă", „`(+)` are
șase comportamente diferite", tabelele comparative `T43`/`T44` — au ieșit fiindcă **un singur context
a văzut toate cele 49 de tabele deodată**. O buclă cu context proaspăt per tabel nu poate structural
să producă așa ceva. Îți dă transcrieri; nu-ți dă harta.

La fel la Capitolul 5: toate cele patru constatări importante (nota (a) care normează o categorie
fără coloană, tensiunea cu `Art. 5.5.4.`, `Art. 5.5.5.` alin. (3), concursul cu sălile aglomerate)
sunt **contextuale** — niciuna n-ar fi fost prinsă de vreo poartă.

**Arhitectura: bucla face Pasul 2, apoi o sesiune lungă citește tabelele produse și scrie
`MANIFEST.md` + `TEST-ACURATETE.md` + integrarea.**

---

## Lecții plătite (nu le reintroduce)

**Jurnalul unei bucle nu are voie să stea în ce resetează bucla.** Prima versiune făcea
`git add -A` (care înghițea `driver.txt`) și `git checkout -- .` la respingere — deci rollback-ul
ștergea exact motivul eșecului. Acum auditul scrie în `/tmp/ralph/`, iar commit-ul și rollback-ul
ating doar `corpus/`.

**O eroare de infrastructură nu e un eșec de calitate.** `API Error: 529 Overloaded` consuma din
bugetul de 3 încercări și oprea bucla exact când nu trebuia. Acum `verify.sh` reîncearcă la
429/500/502/503/529 și întoarce cod **2**, pe care bucla îl tratează separat: aruncă munca
neverificată, dar nu penalizează tabelul.

**Un antet legitim poate declara mai multe valori DPI** („@ 300 DPI pentru grilă și @ 200 DPI pentru
note"). Poarta verifică **minimul**, nu presupune o singură valoare.

**`sed` nu poate insera linii noi într-un `s|||`.** Lista de imagini a verificatorului e multi-linie;
substituția se face cu `python3`.

**Un regex fără spațiu opțional pierde tabele în tăcere.** Prima versiune căuta
`^\s*Tabelul [0-9]+[:–-]`, deci rata `Tabelul 148 - Număr de niveluri…` (`CONSTATARI.md` A5).
Forma corectă, folosită acum și la tabele și la figuri, este `^\s*Tabelul [0-9]+ ?[:–-]`.
Un tabel absent din `INVENTAR.tsv` nu produce niciun eșec — bucla pur și simplu nu-l prelucrează.

**Absența unui verdict se tratează ca eșec, nu ca succes.** Dacă `verify.sh` nu întoarce
`VERDICT: MATCH`, iterația se aruncă. Un `|| true` acolo ar lăsa tabele neverificate în corpus.

---

## Cost

~50–60k tokeni per tabel (scriitor + verificator), ~4 minute. Mai mult decât o sesiune lungă —
promptul se recitește la fiecare iterație. Ce cumperi: fără degradare de context, fiecare tabel
verificat de două ori, rulează nesupravegheat, și **fără plafon de context** — singurul mod în care
Anexa 10 poate fi atinsă.
