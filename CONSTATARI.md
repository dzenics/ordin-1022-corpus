# Constatări — Ordin 1.022/2026 (MO 724 bis)

- ⚠️ **Nepotrivire nume ↔ MO:** fișierul e „Ordinul 1022", dar MO este **Nr. 724 bis/28.VIII.2026**
  (conține anexele Ordinului 1.022/2026). Citează Ordinul 1.022/2026, iar la sursă MO 724 bis.
- **2 coloane** → extragere `pdftotext` FĂRĂ `-layout`.
- **Decalaj paginare 0** (verificat).
- **Conținut = proceduri (text) + formulare (2D).** Pentru layout-ul exact al formularelor, randează
  pagina; textul brut dă doar câmpurile în ordine.
- Fără tabele/figuri numerotate.
- Capcane general-valabile: `../denisa/CONSTATARI.md`.

## Adăugat la deep pass
- ⚠️ **Anexa 7 (pp. 334–347) — strat de text CORUPT.** Fontul folosit are maparea ToUnicode
  stricată, deci `pdftotext` produce „mojibake" (ex. `ƌƚ͘ϭϳĂůŝŶ͘;ϭͿĚŝŶ>ĞŐĞĂŶƌ͘ϭϲϵ` = „Art. 17 alin. (1)
  din Legea nr. 169"). Restul documentului (pp. 1–333, 348–409) extrage curat. Pentru Anexa 7
  (lista avizelor, o matrice), **textul ancorat NU e de încredere — randează paginile** și citește
  vizual. Semnătura garbajului: secvențe `ĚŝŶ` / `ƌƚ͘` / `ϭϲϵ` / `ĞŐĞĂ`.
- Titlurile Anexelor 1–8 confirmate pe pagină (INDEX.md / MANIFEST.md).
