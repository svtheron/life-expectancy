# CLAUDE.md — GitHub Repo Cleanup

## Purpose
Convert a messy project folder into a clean, professional GitHub repository ready to upload. The output should look like the work of a careful, professional analyst — not a student dump.

---

## Languages
- R (`.R`, `.Rmd`, `.qmd`)
- Stata (`.do`, `.ado`)
- LaTeX (`.tex`) if present
- No Python — do not add or suggest Python alternatives

---

## Output Goals

Every completed repo must have:

1. **README.md** — see standard below
2. **.gitignore** — appropriate for the languages present
3. **Clean folder structure** — see standard below
4. **Commented code** — minimal only (see below)

The repo should be self-contained and make sense to a professional reviewer who has no prior context.

---

## README Standard

Every README must include the following sections, in this order:

### Project Title
Short, descriptive. No student numbers, no course codes.

### Overview
2–4 sentences. What the project does, what question it addresses or what task it performs, and what tools/languages it uses. Professional and neutral — no academic context, no university names, no course references.

### Structure
A brief description of the folder layout and what each folder/file contains.

### Data
State clearly that data is not included in the repository. Describe what the data is (source, type, structure) so a reader understands what would be needed to reproduce the analysis. If data is publicly available, provide the source or URL.

### Requirements
List software and key packages/libraries needed to run the code. Include version numbers only if known.

### Usage
Brief instructions for how to run the code. Entry point first (e.g. "Run `main.R` to reproduce all results").

---

## Folder Structure

Use the following structure as the target. Adapt as needed based on the actual project contents — do not force structure that doesn't fit.

```
repo-name/
├── README.md
├── .gitignore
├── scripts/          # All code files, numbered in run order if sequential
├── output/           # Figures, tables, results — include if present and clean
└── docs/             # Optional: notes, references, methodology writeups
```

- Number scripts in run order: `01_clean.R`, `02_analysis.R`, etc.
- Use lowercase, hyphenated filenames — no spaces, no student numbers
- Rename any file whose name is a student number, course code, or otherwise uninformative

---

## Code Commenting

**Minimal** — only comment where the code is non-obvious.

- Do not add comments that just restate what the code does (e.g. `# load data` above `read.csv(...)`)
- Do add comments where: a non-standard method is used, a parameter choice needs justification, or a step would confuse a reader unfamiliar with the domain
- Add a short header block at the top of each script: title, purpose (one line), inputs, outputs

Header format (R):
```r
# ============================================================
# Title:   Descriptive title
# Purpose: One-line description of what this script does
# Inputs:  List input files or objects
# Outputs: List output files or objects
# ============================================================
```

Header format (Stata):
```stata
* ============================================================
* Title:   Descriptive title
* Purpose: One-line description of what this script does
* Inputs:  List input files or objects
* Outputs: List output files or objects
* ============================================================
```

---

## Data Handling

- **Exclude all data files** from the repo (`.csv`, `.dta`, `.xlsx`, `.rds`, `.RData`, etc.)
- Add them to `.gitignore`
- Reference the data clearly in the README under the Data section
- If a `data/` folder exists, remove its contents but you may keep the folder with a `.gitkeep` and a note in the README

---

## .gitignore

Generate a `.gitignore` appropriate to the languages present. Always include:

```
# Data
*.csv
*.dta
*.xlsx
*.xls
*.rds
*.RData
*.sav

# R
.Rhistory
.RData
.Rproj.user/
*.Rproj

# Stata
*.log
*.smcl
*.stswp

# OS
.DS_Store
Thumbs.db

# LaTeX (if present)
*.aux
*.log
*.out
*.synctex.gz
*.toc
*.fls
*.fdb_latexmk
```

---

## Junk and Scratch Files

Remove or exclude the following:
- Files named `test`, `scratch`, `temp`, `old`, `copy`, `backup`, or similar
- Duplicate scripts (keep the most recent clean version)
- Empty files
- Auto-generated output files that can be reproduced by running the code

If unsure whether to delete a file, move it to a `_archive/` folder and add that folder to `.gitignore`. Do not delete anything permanently.

---

## Tone and Style

- README prose should be professional, neutral, and concise
- No first-person language in READMEs
- No marketing language
- No academic context (no university names, course names, assignment references)
- Write as if the audience is a professional reviewer or potential employer

---

## Checklist Before Finishing

Before handing back, confirm:
- [ ] README.md present and complete
- [ ] .gitignore present and covers data + OS files
- [ ] All scripts have header blocks
- [ ] All files have informative names (no student numbers, no `test123`)
- [ ] No data files present in the repo
- [ ] Folder structure is clean and logical
- [ ] README Data section describes the excluded data clearly
