# Export a PDF from Obsidian

I keep university notes in Obsidian and export handouts to PDF with pandoc. The export runs two repo scripts: `obsidian-images-path` resolves image embeds, `pandoc-ob-notes` builds the PDF and opens it in zathura.

## Prerequisites

- pandoc with `--pdf-engine=pdflatex`
- `zathura` (the viewer)
- `scripts` stowed so `pandoc-ob-notes` and `obsidian-images-path` are on `$PATH` from `~/bin`

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

Images live in the vault's `attachments` folder and are embedded Obsidian-style:

```md
![[setup-diagram.png|Network setup]]
```

## 3. Rewrite image embeds

`obsidian-images-path` (`scripts/bin/py/obsidian-images-path`) rewrites `![[...]]` image embeds into standard markdown, resolving each file by basename across the resource paths:

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

The output file is named `<input>-notes.pdf` and is opened in zathura automatically.

## Filters and templates

| File | Purpose |
| ---- | ------- |
| `~/.pandoc/filters/pdf.lua` | Passes raw `\begin{...}` LaTeX blocks through to pdflatex untouched (hand-written math in Obsidian notes) |
| `~/.pandoc/filters/wikilink-filter.lua` (wired via `~/.pandoc/defaults.yml`) | Rewrites links with `.md` targets to `.pdf` so Obsidian `[[note]]` links point at exported PDFs |
| `~/.pandoc/templates/notes` | LaTeX handout template used by the export |
| `~/.pandoc/templates/obsidian.typ` | Typst template with `pagewide`, `landscape`, `fullpage` helpers for typst-based exports |

## Why this way

| Where | What | Why | Breaks if |
| ----- | ---- | --- | --------- |
| `obsidian-images-path` resolves images by basename across `--resource-path` | Finds each embedded image regardless of the note's folder | Obsidian exports would otherwise depend on relative paths from the note to the attachment | Images go missing in the PDF unless every note sits at the right depth |
| `--resource-path=$HOME/.pandoc/resources` | Lets pandoc resolve shared resources from one place | CSL styles and shared files live outside the vault and are reused across exports | Citations or resources fail to resolve on machines without the path |
| `pdf.lua` returns raw TeX for `\begin{...}` math | Hand-written LaTeX blocks stay LaTeX | Obsidian math syntax and raw LaTeX coexist in the same note | Hand-written environments get mangled by the markdown math parser |
| `wikilink-filter.lua` swaps `.md` → `.pdf` | Obsidian links become links to exported PDFs | Exported handouts should reference other exported handouts, not the vault sources | Links break when a target hasn't been exported |
