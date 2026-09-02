#!/usr/bin/env python3
"""Verifică invariantul de grilă peste orice set de fișiere de tabel.

Fiecare rând al unui tabel markdown trebuie să aibă același număr de celule ca
antetul lui. Un rând cu alt număr = citire greșită a grilei (PROCEDURA.md 2d).

Este aceeași verificare pe care o face `gate.sh` pentru un singur fișier, dar
rulabilă peste tot corpusul — util după o trecere manuală sau înainte de a
declara un capitol gata.

    ./ralph/check-grile.py 'corpus/tables/cap-*/T*.md'
    ./ralph/check-grile.py 'corpus/tables/cap-04/T9*.md'

Cod de ieșire: 0 = toate consecvente, 1 = cel puțin un fișier cu probleme.
"""
import glob
import re
import sys


def blocks(lines):
    """Grupează liniile consecutive care încep cu '|' în blocuri de tabel."""
    blk, start = [], 0
    for i, line in enumerate(lines):
        if line.lstrip().startswith('|'):
            if not blk:
                start = i
            blk.append(line.strip())
        elif blk:
            yield start, blk
            blk = []
    if blk:
        yield start, blk


def check(path):
    """Întoarce lista de probleme găsite în fișier."""
    problems = []
    lines = open(path, encoding='utf-8').read().split('\n')
    for start, blk in blocks(lines):
        if len(blk) < 3:           # antet + separator + cel puțin un rând
            continue
        # `\|` este un pipe escapat în interiorul unei celule, nu un separator
        counts = [len(re.sub(r'\\\|', '', b).split('|')) for b in blk]
        header = counts[0]
        for offset, c in enumerate(counts[1:], 1):
            if c != header:
                problems.append(
                    f"  linia {start + offset + 1}: {c} celule, antetul are {header}")
    return problems


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    files = sorted(f for pat in sys.argv[1:] for f in glob.glob(pat))
    if not files:
        print("niciun fișier găsit pentru tiparul dat", file=sys.stderr)
        return 2

    bad = 0
    for path in files:
        problems = check(path)
        if problems:
            bad += 1
            print(f"{path}:")
            print('\n'.join(problems[:5]))
            if len(problems) > 5:
                print(f"  … și încă {len(problems) - 5}")

    print(f"\n{len(files)} fișiere verificate, {bad} cu grile inconsecvente")
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
