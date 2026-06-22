---
title: "Workflow process to export PDF from Obsidian"
author:
  - Pablo Palazon
date: "2026-06-19"
---

# Workflow process to export PDF from Obsidian

Obsidian is a well-known tool to write documentation and taking notes. I usually use it to keep organised all
the documents and relevant files of all my projects and resources. At the moment of writing this document, I'm
studying at the university and I need a really quick way to produce reports with answers to exercises and
labs. As I'm already using Obsidian to keep all my notes, slides, screenshots, I would like to have all of
these under the same system. So, how can I generate a beautiful PDF from an Obsidian markdown file?.

## What's in my PDF?

The structure of my handouts are pretty simple:

- Title
- Author
- Date
- Heading
- Paragraphs
- Tables
- Code snippets
- Screenshots / images
- Diagrams
- Latex mathematical statements

It sounds like obvious, but you have to keep in mind when you need to export an integrated PDF. The most
problematic part are images and screenshots because you must control where you store them and how the tool
gets it.

## Exporting tools

The easiest way to export a PDF from a markdown file is using `pandoc` tool. It's excellent and the default
templates are really good, and you can choose between `Latex` and `Typst` to export the output PDF.

```mermaid
flowchart LR
  to --> do
```

!!! note

    TODO: Finish this article