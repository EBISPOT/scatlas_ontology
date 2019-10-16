#!/bin/sh


#curl https://raw.githubusercontent.com/EBISPOT/efo/master/src/ontology/efo-edit.owl > ./mirror/efo.owl

robot template --template ./terms/ontologyterms.tsv --prefix "EFO: http://www.ebi.ac.uk/efo/EFO_" --prefix "BTO: http://purl.obolibrary.org/obo/BTO_" --prefix "CHEBI: http://purl.obolibrary.org/obo/CHEBI_" --prefix "CLO: http://purl.obolibrary.org/obo/CLO_" --prefix "CL: http://purl.obolibrary.org/obo/CL_" --prefix "EO: http://purl.obolibrary.org/obo/EO_" --prefix "FBbt: http://purl.obolibrary.org/obo/FBbt_" --prefix "FMA: http://purl.obolibrary.org/obo/FMA_" --prefix "GO: http://purl.obolibrary.org/obo/GO_" --prefix "HANCESTRO: http://purl.obolibrary.org/obo/HANCESTRO_" --prefix "HP: http://purl.obolibrary.org/obo/HP_" --prefix "NCBITaxon: http://purl.obolibrary.org/obo/NCBITaxon_" --prefix "NCIT: http://purl.obolibrary.org/obo/NCIT_" --prefix "OBI: http://purl.obolibrary.org/obo/OBI_" --prefix "PATO: http://purl.obolibrary.org/obo/PATO_" --prefix "PO: http://purl.obolibrary.org/obo/PO_" --prefix "TO: http://purl.obolibrary.org/obo/TO_" --prefix "UBERON: http://purl.obolibrary.org/obo/UBERON_" --prefix "UO: http://purl.obolibrary.org/obo/UO_" --prefix "WBls: http://purl.obolibrary.org/obo/WBls_" --prefix "Orphanet: http://www.orpha.net/ORDO/Orphanet_" \
query -q ../sparql/construct.sparql ./imports/terms_tagged.owl

robot merge -i ./mirror/efo.owl -i ./build/terms_tagged.owl -o ./build/efo_tagged.owl

robot query --input ./building/scatlas.owl  --update ../sparql/update.sparql --output ./building/scatlas1.owl

robot reason --input ./building/ube_cbmerge.owl   --axiom-generators "SubClass DisjointClasses" --output ./building/po_cbmge.owl
robot query --input ./build/scatlas_tagged.owl  --update ../sparql/update.sparql --output ./build/scatlas.owl

$(ROBOT) reason --input ./build/scatlas2.owl  --reasoner ELK  remove --select imports --trim false remove -T ./terms/ontologyterms.csv --select complement --select object-properties --trim true  relax  reduce -r ELK  filter -T  ./terms/ontologyterms.csv  --trim true --preserve-structure false  --output scat.owl
###The mapping to EFO Using the robot map
robot query --input ./build/cl.owl --query $(SPARQLDIR)/inSubsets.sparql $@
