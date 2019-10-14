---
layout: ontology_detail
id: SCAtlas
title: Single Cell Atlas
jobs:
  - id: https://travis-ci.org/EBISPOT/SCAtlas
    type: travis-ci
build:
  checkout: git clone https://github.com/EBISPOT/SCAtlas.git
  system: git
  path: "."
contact:
  email: 
  label: 
  github: 
description: Single Cell Atlas is an ontology...
domain: stuff
homepage: https://github.com/EBISPOT/SCAtlas
products:
  - id: SCAtlas.owl
    name: "Single Cell Atlas main release in OWL format"
  - id: SCAtlas.obo
    name: "Single Cell Atlas additional release in OBO format"
  - id: SCAtlas.json
    name: "Single Cell Atlas additional release in OBOJSon format"
  - id: SCAtlas/SCAtlas-base.owl
    name: "Single Cell Atlas main release in OWL format"
  - id: SCAtlas/SCAtlas-base.obo
    name: "Single Cell Atlas additional release in OBO format"
  - id: SCAtlas/SCAtlas-base.json
    name: "Single Cell Atlas additional release in OBOJSon format"
dependencies:
- id: bto
- id: cl
- id: chebi
- id: go
- id: peco
- id: pato
- id: to
- id: po
- id: wbls
- id: ncit
- id: uberon
- id: uberon-bridge-to-fbbt
- id: ncbitaxon
- id: efo

tracker: https://github.com/EBISPOT/SCAtlas/issues
license:
  url: http://creativecommons.org/licenses/by/3.0/
  label: CC-BY
activity_status: active
---

Enter a detailed description of your ontology here. You can use arbitrary markdown and HTML.
You can also embed images too.

