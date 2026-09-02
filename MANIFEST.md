# MANIFEST — Ordin 1.022/2026 (MO 724 bis), Anexe 1–8

Procedura de elaborare/modificare/aprobare a documentațiilor de amenajarea teritoriului și urbanism.
Anexele 1–5 sunt proceduri pe tip de plan; Anexa 6 = formulare; Anexa 7 = lista avizelor; Anexa 8 =
model caiet de sarcini. Procedurile citează frecvent **Legea nr. 169/2026** (Codul, repo `mo-661-corpus`).

## Anexe (procedură pe tip de documentație)
| Anexă | Pagini | Documentația |
|---|---|---|
| 1 | 3–53 | PATZ/I — Plan de Amenajare a Teritoriului Zonal / Intercomunitar |
| 2 | 54–110 | PATJ — Plan de Amenajare a Teritoriului Județean |
| 3 | 111–200 | PUG (+ PUG metropolitane) — Planuri Urbanistice Generale |
| 4 | 201–278 | PUZ — Planuri Urbanistice Zonale |
| 5 | 279–316 | PUD — Proiect Urbanistic de Detaliu |
| 8 | 348–409 | Model-cadru caiet de sarcini (achiziție servicii expertiză/elaborare PUG) |

Fiecare procedură (Anexe 1–5) e structurată pe **etape** (ex. „ETAPA 1. ELABORAREA STUDIILOR DE
FUNDAMENTARE") — caută „ETAPA" în textul ancorat pentru a naviga.

## Anexa 6 — Formulare (pp. 317–333)
Modele de **cereri** și de **avize** (fără coduri `F_` ca la MO 711 bis). Poziții aproximative:
| Pagina | Tip |
|---|---|
| 317 | FORMULAR (deschidere) |
| 318, 326, 330 | CERERE |
| 320, 323, 328, 332 | AVIZ (model) |
Formularele sunt 2D — pentru layout exact, randează pagina.

## Anexa 7 — Lista avizelor (pp. 334–347) — ⚠️ RENDER-ONLY
Stratul de text e corupt (font stricat). Este o **matrice** (instituții avizatoare × documentații ×
temei legal din Legea 169/2026). NU cita din textul ancorat pentru aceste pagini — **randează**:
`pdftoppm -r 200 "Ordin-1022-proceduri-formulare.pdf" -f 334 -l 347 /tmp/a7`.

## Constatări specifice
- MO real = **Nr. 724 bis** (nu 1022 — acela e numărul Ordinului).
- **Anexa 7 = text stricat (mojibake)** pe pp. 334–347; restul documentului extrage curat.
- Procedurile citează Legea 169/2026 — răspunsurile complete pot necesita și repo `mo-661-corpus`.
