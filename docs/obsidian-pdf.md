# Export a PDF from Obsidian

pandoc exports university notes from Obsidian to PDF handouts. The export runs two repo scripts. `obsidian-images-path` resolves image embeds, and `pandoc-ob-notes` builds the PDF and opens it in zathura.

## Prerequisites

- pandoc with `--pdf-engine=pdflatex`
- `zathura` (the viewer)
- `scripts` stowed, so `pandoc-ob-notes` and `obsidian-images-path` are on `$PATH` from `~/bin`

## 1. Set note metadata

The LaTeX template needs a title, author, and date:

```yaml
---
title: "Lab 3 report"
author: Pablo
date: 2026-06-19
---
```

## 2. Reference images as wikilinks

Images live in the `attachments` folder of the vault and are embedded Obsidian-style:

```md
![[setup-diagram.png|Network setup]]
```

## 3. Rewrite image embeds

`obsidian-images-path` (`scripts/bin/py/obsidian-images-path`) rewrites `![[...]]` image embeds into standard markdown and resolves each file by basename across the resource paths:

```bash
obsidian-images-path \
  --input note.md \
  --output note-export.md \
  --resource-path attachments \
  --relative-to .
```

It leaves unresolved embeds untouched and prints a warning for each one to stderr.

## 4. Export with pandoc

Run `pandoc-ob-notes` (`scripts/bin/sh/pandoc-ob-notes`) from the vault directory:

```bash
pandoc-ob-notes note-export.md
```

It validates the `.md` argument, then runs:

```bash
pandoc --resource-path="./" \
       --resource-path="attachments" \
       --resource-path="$HOME/.pandoc/resources" \
       --lua-filter="pdf.lua" \
       -o note-export-notes.pdf \
       --citeproc --template notes -t pdf --pdf-engine=pdflatex note-export.md
```

The script names the output `<input>-notes.pdf` and opens it in zathura.

## Filters and templates

| File | Purpose |
| ---- | ------- |
| `~/.pandoc/filters/pdf.lua` | It passes raw `\begin{...}` LaTeX blocks through to pdflatex untouched. Hand-written math in Obsidian notes stays LaTeX. |
| `~/.pandoc/filters/wikilink-filter.lua` (wired via `~/.pandoc/defaults.yml`) | It rewrites links with `.md` targets to `.pdf`, so Obsidian `[[note]]` links point at exported PDFs. |
| `~/.pandoc/templates/notes` | It is the LaTeX handout template that the export uses. |
| `~/.pandoc/templates/obsidian.typ` | It is the Typst template with `pagewide`, `landscape`, and `fullpage` helpers for typst-based exports. |

## Why this way

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `obsidian-images-path` (`scripts/bin/py/obsidian-images-path`) | It resolves each embedded image by basename across the `--resource-path` folders. | Obsidian exports otherwise depend on relative paths from the note to the attachment. | If a note sits at the wrong depth, its images go missing in the PDF. |
| `--resource-path=$HOME/.pandoc/resources` in `pandoc-ob-notes` | It lets pandoc resolve shared resources from one place. | CSL styles and shared files live outside the vault and are reused across exports. | If a machine lacks the path, citations or resources fail to resolve. |
| `pdf.lua` (`~/.pandoc/filters/pdf.lua`) | It returns raw TeX for `\begin{...}` math blocks. | Obsidian math syntax and raw LaTeX coexist in the same note, so hand-written blocks stay LaTeX. | If the filter is dropped, the markdown math parser mangles hand-written environments. |
