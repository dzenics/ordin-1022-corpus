Ești într-o buclă automată. Ai context PROASPĂT — nu-ți amintești nimic din iterația
anterioară, și nu ai nevoie: tot ce trebuie să știi e pe disc.

Ai UN SINGUR lucru de făcut în această iterație, apoi ieși.

## Sarcina

Prelucrează **Tabelul {{NR}}** din {{BUCATA}} (începe pe pagina {{PAG}}).
Nu prelucra alt tabel. Nu „mai faci unul cât ești aici".

## Citește întâi (obligatoriu, în ordine)

1. `PROCEDURA.md` — Pasul 2 (tabelele). Execut-o, nu improviza.
2. `CONSTATARI.md` — capcanele deja descoperite. Te scutesc să le redescoperi.
3. `sabloane/TABEL.md` — structura fișierului. Copiaz-o, nu inventa alta.
4. `corpus/{{PREFIX}}-{{CAP}}.md`, blocul `[p. {{PAG}}]` și vecinii — pentru scheletul
   textual și pentru articolul care invocă tabelul.

## Randează în {{RENDER_DIR}} — NU în altă parte

    pdftoppm -f <p> -l <p> -r 200 -png "Ordin-1022-proceduri-formulare.pdf" {{RENDER_DIR}}/p

Randează **toate** paginile pe care le vei cita în antet. O poartă automată verifică
după iterație că paginile pretinse în antet au fost efectiv randate aici. Dacă
pretinzi o pagină pe care n-ai randat-o, iterația se aruncă și munca ta se pierde.

Regula DPI (`PROCEDURA.md` 2c): la calificative stivuite — `(A1 sau A2-s1,d0)`,
`(*) (min B-s2,d0)`, valori în paranteze — randează la **300 DPI** și decupează banda
rândului. La 150 DPI, 2 din 12 rânduri au ieșit greșit la `Tabelul 2`.

## Întinderea reală

Tabelele trec peste saltul de pagină. Randează {{PAG}}, apoi {{PAG}}+1, +2… până nu
mai vezi corp de tabel **sau note**. Patru forme, toate întâlnite:
titlu singur pe o pagină · antet repetat pe a doua · antet nerepetat · note revărsate
singure. Nu presupune întinderea — confirm-o.

Paginile valide sunt {{P_MIN}}–{{P_MAX}}. Orice pagină citată în afara lor = iterație respinsă.

## Scrie

Un singur fișier: `corpus/tables/{{PREFIX}}-{{CAP}}/T{{NR}}.md`, după `sabloane/TABEL.md`.
Antet obligatoriu pe rândul 2:

    <!-- verificat pe pp. <lista> @ <DPI> (<ce anume a fost mărit>) -->

Notele se transcriu **verbatim, integral**. Ele conțin excepțiile obligatorii.
Dacă un marcaj apare în grilă (`*`, `(+)`, `-`, `#`) dar documentul **nu îl definește**,
scrie explicit că nu e definit — nu îl completa prin analogie.

Totul în română, inclusiv comentariile proprii. Textul normativ rămâne verbatim.

## Verificarea ta, înainte de a termina

Numără coloanele de valori din antet și verifică numărul de celule al **fiecărui** rând
față de el. Un rând cu alt număr de celule = citire greșită → decupează din nou.
Aceasta prinde majoritatea erorilor înainte să ajungă în corpus.

## NU face

- nu edita `STARE.md`, `INDEX.md`, `MANIFEST.md` — se fac la final, de o singură dată;
- nu face commit — bucla comite după ce trece poarta;
- nu prelucra alt tabel;
- nu raporta „gata" dacă n-ai randat efectiv paginile.

Dacă ceva te împiedică să termini, **scrie ce și de ce în `ralph/BLOCAJE.md`** și ieși.
Un tabel lipsă e recuperabil. Un tabel plauzibil și greșit nu e.
