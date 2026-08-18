# EU ETS and North African Imports: A Proposed Triple-Difference Design

Seminar paper for Panel Data Methods, MSc Economics, University of Cologne.

## Research question

Did increases in the effective EU ETS carbon cost raise EU imports of emission-intensive goods from North African partners, relative to less emission-intensive goods, over 2005 to 2021?

## Repository structure

```
.
├── CLAUDE.md           # Standing instructions for Claude Code
├── README.md
├── paper/
│   ├── main.tex        # Master document
│   ├── refs.bib        # Bibliography
│   └── sections/       # One .tex per section, \input into main.tex
│       ├── introduction.tex
│       ├── policy_background.tex
│       ├── literature_review.tex
│       ├── empirical_design.tex
│       ├── contribution.tex
│       └── conclusion.tex
├── proposal/
│   └── proposal.tex    # Research proposal (chair template layout)
└── figs/
    ├── UoC_Logo.png    # University logo for the title page
    └── make_figs.R     # EUA price figure (needs an Ember CSV; see below)
```

## Optional price figure

`figs/make_figs.R` draws the EUA price series with the proposed sample window
marked. It is the only part of the repository that reads external data, and it
performs no estimation. Download the CSV export from
<https://ember-energy.org/data/carbon-price-viewer/> into `figs/`, then:

```bash
cd figs
Rscript make_figs.R
```

This writes `figs/eua_price.pdf`. The paper picks the file up automatically on
the next compile and omits the figure entirely if it is absent, so `paper/`
compiles either way.

## Compilation

```bash
cd paper
latexmk -pdf main.tex
```

Requires a LaTeX distribution with `natbib`, `booktabs`, `tikz`, `tabularx`, and standard packages.

## Scope

This is a methodological and literature paper. It proposes and defends an empirical design; it does not execute it. No data is downloaded, processed, or estimated in this repository.
