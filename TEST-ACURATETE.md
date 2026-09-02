# Test de acuratețe — Ordin 1.022/2026 (MO 724 bis)

1. **Ce conține documentul?** → Anexele nr. 1–8 la Ordinul MDLPA nr. 1.022/2026 (Procedura de
   elaborare/modificare/aprobare a documentațiilor de amenajarea teritoriului și urbanism +
   formulare + lista avizelor), pp. 3–409. Sursă: SUMAR p.1. **PASS**
2. **Ce tratează Anexa nr. 1?** → Elaborarea, modificarea/actualizarea și aprobarea PATZ/I (Plan de
   Amenajarea Teritoriului Zonal/Intercomunitar), p.3. **PASS**
3. **Câte anexe și unde încep?** → 8: pp. 3, 54, 111, 201, 279, 317, 334, 348. **PASS**
4. **(control negativ) Conține modelele formularelor pentru autorizarea CONSTRUIRII (`F_CU_01`)?**
   → NU; acelea sunt în MO 711 bis / Ordinul 975/2026 (repo `mo-711bis-corpus`). **PASS**
5. **Care e numărul real al Monitorului Oficial?** → Nr. 724 bis/28.VIII.2026 (nu 1022 — acela e nr.
   Ordinului). **PASS**

**Risc rezidual:** testul e minimal pentru 407 pagini; titlurile Anexelor 2–5,7–8 și indexul de
formulare nu sunt completate. Extinde pe conținutul fiecărei anexe.

## Adăugat la deep pass (titluri anexe verificate pe pagină)
6. **Ce documentație tratează fiecare anexă 1–5?** → A1 PATZ/I (p.3), A2 PATJ (p.54), A3 PUG +
   metropolitane (p.111), A4 PUZ (p.201), A5 PUD (p.279). Verificat pe pagina de start. **PASS**
7. **Unde e lista avizelor și modelul de caiet de sarcini?** → Anexa 7 „Lista avizelor" (pp. 334–347),
   Anexa 8 „Model-cadru de caiet de sarcini" pentru PUG (pp. 348–409). **PASS**
8. **Poți cita textul Anexei 7 din corpusul ancorat?** → NU — stratul de text e corupt (font stricat)
   pe pp. 334–347; trebuie randate paginile și citite vizual. **PASS (constatare)**
9. **(control negativ) Găsești aici modelul formularului de autorizare a construirii (`F_CU_01`)?**
   → NU; acela e în MO 711 bis / Ordinul 975/2026 (`mo-711bis-corpus`). Aici sunt documentații de
   amenajare/urbanism (PATZ/PATJ/PUG/PUZ/PUD). **PASS**
