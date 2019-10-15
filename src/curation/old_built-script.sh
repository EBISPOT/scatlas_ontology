#!/bin/sh


#curl https://raw.githubusercontent.com/EBISPOT/efo/master/src/ontology/efo-edit.owl > ./mirror/efo.owl

curl https://www.ebi.ac.uk/ols/ontologies/efo/download > ./mirror/efo.owl

curl https://www.ebi.ac.uk/ols/ontologies/cl/download > ./mirror/cl.owl

curl https://www.ebi.ac.uk/ols/ontologies/chebi/download > ./mirror/chebi.owl

curl https://www.ebi.ac.uk/ols/ontologies/uberon/download > ./mirror/uberon.owl

curl https://www.ebi.ac.uk/ols/ontologies/po/download > ./mirror/po.owl

curl https://www.ebi.ac.uk/ols/ontologies/NCBITaxon/download > ./mirror/NCBITaxon.owl

curl https://www.ebi.ac.uk/ols/ontologies/eo/download > ./mirror/eo.owl

curl https://www.ebi.ac.uk/ols/ontologies/fbbt/download > ./mirror/fbbt.owl

curl https://www.ebi.ac.uk/ols/ontologies/wbls/download > ./mirror/fbbt.owl

robot template --template ./terms/ontologyterms.tsv --prefix "EFO: http://www.ebi.ac.uk/efo/EFO_" --prefix "BTO: http://purl.obolibrary.org/obo/BTO_" --prefix "CHEBI: http://purl.obolibrary.org/obo/CHEBI_" --prefix "CLO: http://purl.obolibrary.org/obo/CLO_" --prefix "CL: http://purl.obolibrary.org/obo/CL_" --prefix "EO: http://purl.obolibrary.org/obo/EO_" --prefix "FBbt: http://purl.obolibrary.org/obo/FBbt_" --prefix "FMA: http://purl.obolibrary.org/obo/FMA_" --prefix "GO: http://purl.obolibrary.org/obo/GO_" --prefix "HANCESTRO: http://purl.obolibrary.org/obo/HANCESTRO_" --prefix "HP: http://purl.obolibrary.org/obo/HP_" --prefix "NCBITaxon: http://purl.obolibrary.org/obo/NCBITaxon_" --prefix "NCIT: http://purl.obolibrary.org/obo/NCIT_" --prefix "OBI: http://purl.obolibrary.org/obo/OBI_" --prefix "PATO: http://purl.obolibrary.org/obo/PATO_" --prefix "PO: http://purl.obolibrary.org/obo/PO_" --prefix "TO: http://purl.obolibrary.org/obo/TO_" --prefix "UBERON: http://purl.obolibrary.org/obo/UBERON_" --prefix "UO: http://purl.obolibrary.org/obo/UO_" --prefix "WBls: http://purl.obolibrary.org/obo/WBls_" --prefix "Orphanet: http://www.orpha.net/ORDO/Orphanet_" \
query -q ../sparql/construct.sparql ./imports/terms_tagged.owl

robot merge -i ./mirror/efo.owl -i ./build/terms_tagged.owl -o ./build/efo_tagged.owl

robot extract -m BOT -i ./build/efo_tagged.owl -T ./terms/ontologyterms.csv --annotate-with-source true -o ./build/efo_slim.owl


robot extract -m BOT -i ./mirror/chebi.owl -T ./terms/CHEBI_terms.txt --annotate-with-source true -o ./build/chebi_slim.owl

robot extract -m BOT -i ./mirror/cl.owl -T ./terms/CL_terms.txt --annotate-with-source true -o ./build/cl_slim.owl

robot extract -m BOT -i ./mirror/eo.owl -T ./terms/EO_terms.txt --annotate-with-source true -o ./build/eo_slim.owl

robot extract -m BOT -i ./mirror/fbbt.owl -T ./terms/FBbt_terms.txt --annotate-with-source true -o ./build/fbbt_slim.owl

robot extract -m BOT -i ./mirror/NCBITaxon.owl -T ./terms/NCBITaxon_terms.txt --annotate-with-source true -o ./build/NCBITaxon_slim.owl

robot extract -m BOT -i ./mirror/po.owl -T ./terms/po_terms.txt --annotate-with-source true -o ./build/po_slim.owl

robot extract -m BOT -i ./mirror/uberon.owl -T ./terms/uberon_terms.txt --annotate-with-source true -o ./build/uberon_slim.owl

robot merge -i ./build/uberon_slim.owl -i ./build/po_slim.owl -i ./build/NCBITaxon_slim.owl  -i ./build/eo_slim.owl -i ./build/cl_slim.owl  -i ./build/chebi_slim.owl  -i ./build/efo_slim.owl -o ./build/scatlas.owl


robot merge -i ./build/scatlas.owl -i ./build/terms_tagged.owl -o ./build/scatlas_tagged.owl



robot merge -i ./build/chebi_slim.owl  -i ./build/efo_slim.owl -o ./building/scatlas.owl

robot query --input ./building/scatlas.owl  --update ../sparql/update.sparql --output ./building/scatlas1.owl

robot template --merge-before --input ./building/scatlas1.owl --template ./templates/template.csv --output ./building/scatlas2.owl

robot rename --input ./building/scatlas2.owl  --prefix-mappings ./templates/partial-rename.tsv --output ./building/scatlas3.owl

robot template --merge-before --input ./building/scatlas3.owl --template ./templates/template.csv --output ./building/scatlas4.owl

#### robot query --input ./building/scatlas4.owl  --update ../sparql/update.sparql --output ./building/scatlas5.owl

###Working with the CHEBI and merging it into EFO :
# 1. Create the BOT extraction of slim from CHEBI using the ontologyterms.csv
# 2. To rename the entity - role(CHEBI_50906) as the efo role "Role"
# 3. to merge the efo_slim with chebi_slim
# 4. to use template to make the subatomic particle a subClassOf material MaterialEntity

robot extract -m BOT -i ./mirror/chebi.owl -T ./terms/ontologyterms.csv --annotate-with-source true -o ./building/chebi_slim.owl

robot rename --input ./building/chebi_slim.owl --mappings ./templates/renamecopy.tsv --output ./building/chebi_efo.owl

robot merge -i ./build/efo_slim.owl -i ./building/chebi_efo.owl -o ./building/efo_chebi.owl

robot template --merge-before --template ./templates/template_chebi.csv --prefix "CHEBI: http://purl.obolibrary.org/obo/CHEBI_" --prefix "snap: http://www.ifomis.org/bfo/1.1/snap#"  -i ./building/efo_chebi.owl -o ./building/efo_chebi_slim.owl

# To put the subatomic class as the subClassOf material entity in EFO


###Working with the cl and merging it into EFO slim :
# 1. Create the BOT extraction of slim from CL using the ontologyterms.csv
# 2. To rename the entity - role(CHEBI_50906) as the efo role "Role"
# 3. to merge the efo_slim with chebi_slim
# 4. to use template to make the subatomic particle a subClassOf material MaterialEntity

robot extract -m BOT -i ./mirror/cl.owl -T ./terms/CL_terms.txt --annotate-with-source true -o ./building/cl_slim.owl

robot remove --input ./building/cl_slim.owl --term Nothing  --term UBERON:0000000 --term SO:0000110 --term CHEBI_36342 --term UBERON:0001062 --term BFO:0000002 --term BFO:0000003 --term BFO:0000000 --term CHEBI:50906 --term NCBITaxon:1 --select "self descendants" --signature true --output ./building/cl_slim.owl

robot merge -i ./building/cl_slim.owl -i ./building/efo_chebi_slim.owl -o ./building/efo_chebi_cl_slim.owl




###Working with the eo and merging it into EFO slim :
# 1. Create the BOT extraction of slim from eo using the ontologyterms.csv
# 2. To rename the entity - role(CHEBI_50906) as the efo role "Role"
# 3. to merge the efo_slim with chebi_slim
# 4. to use template to make the subatomic particle a subClassOf material MaterialEntity

robot extract -m BOT -i ./mirror/eo.owl -T ./terms/EO_terms.txt --annotate-with-source true -o ./building/eo_slim.owl

robot rename --input ./building/eo_slim.owl --mappings ./templates/renamecopy.tsv --output ./building/eo_slim.owl

robot merge -i  ./building/efo_chebi_cl_slim.owl -i ./building/eo_slim.owl -o ./building/efo_chebi_cl_eo_slim.owl

robot template --merge-before --template ./templates/template_chebi.csv --prefix "EO: http://purl.obolibrary.org/obo/EO_" --prefix "CHEBI: http://purl.obolibrary.org/obo/CHEBI_" --prefix "snap: http://www.ifomis.org/bfo/1.1/snap#"  -i ./building/efo_chebi_cl_eo_slim.owl -o ./building/fo_chebi_slim.owl



###Working with the fbbt and merging it into EFO slim :
# 1. Create the BOT extraction of slim from eo using the ontologyterms.csv
# 2. To rename the entity - role(CHEBI_50906) as the efo role "Role"
# 3. to merge the efo_slim with chebi_slim
# 4. to use template to make the subatomic particle a subClassOf material MaterialEntity

robot extract -m BOT -i ./mirror/fbbt.owl -T ./terms/FBbt_terms.txt --annotate-with-source true -o ./building/fbbt_slim.owl

robot merge -i  ./building/efo_chebi_cl_eo_slim.owl -i ./building/fbbt_slim.owl -o ./building/efo_chebi_fbbt_slim.owl




###Working with the NCBITaxon and merging it into EFO slim :
# 1. Create the BOT extraction of slim from eo using the ontologyterms.csv
# 2. To rename the entity - role(CHEBI_50906) as the efo role "Role"
# 3. to merge the efo_slim with chebi_slim
# 4. to use template to make the subatomic particle a subClassOf material MaterialEntity

robot extract -m BOT -i ./mirror/NCBITaxon.owl -T ./terms/NCBITaxon_terms.txt --annotate-with-source true -o ./building/ncbitaxon_slim.owl

robot merge -i  ./building/efo_chebi_cl_eo_slim.owl -i ./building/ncbitaxon_slim.owl -o ./building/efo_chebi_fbbt_ncb_slim.owl

robot reason --input ./building/efo_chebi_fbbt_ncb_slim.owl   --axiom-generators "SubClass DisjointClasses" --output ./building/reasoned_gen_slim.owl


robot remove -i ./imports/all_merge.owl  --term FBbt:00007006 --term FBbt:00004208 --term SO:0000110 --term CARO:0000003 --term CARO:0000006 --term CARO:0000000 --term UBERON:0000105 --term UBERON:0000000 --term BFO:0000015 --term NCBITaxon:1 --term BFO:0000002 --term NCBITaxon:131567 --term BFO:0000015 --term EO:0007359 --term CARO:0030000 --term BFO:0000002  --term BFO:0000003 --term BFO:0000004 --term BFO:0000141 --term BFO:0000040 --term GO:0005623 --term BFO:0000030 --term FBbt:10000000  --term FBbt:00007016 --term CHEBI:50906  -o ./imports/all_import_merge.owl



robot template --merge-before --template ./imports/chebi_sub.csv  --prefix "EFO: http://www.ebi.ac.uk/efo/EFO_" --prefix "UBERON: http://purl.obolibrary.org/obo/UBERON_" --prefix "GO: http://purl.obolibrary.org/obo/GO_" --prefix "CARO: http://purl.obolibrary.org/obo/CARO_" --prefix "UBERON: http://purl.obolibrary.org/obo/UBERON_" --prefix "FBbt: http://purl.obolibrary.org/obo/FBbt_" --prefix "CHEBI: http://purl.obolibrary.org/obo/CHEBI_" --prefix "snap: http://www.ifomis.org/bfo/1.1/snap#"  -i  ./imports/all_import_merge.owl -o ./imports/template.owl



robot rename --input ./imports/template.owl --mappings ./imports/full-rename.tsv --add-prefix "BFO: http://purl.obolibrary.org/obo/" --add-prefix "snap: http://www.ifomis.org/bfo/1.1/" --output ./imports/all_merges.owl



robot extract -m BOT -i ./imports/all_merges.owl  -T ./terms/ontologyterms.csv --annotate-with-source true -o ./imports/all_mges.owl


###Working with the po and merging it into EFO slim :
# 1. Create the BOT extraction of slim from eo using the ontologyterms.csv
# 2. To rename the entity - role(CHEBI_50906) as the efo role "Role"
# 3. to merge the efo_slim with chebi_slim
# 4. to use template to make the subatomic particle a subClassOf material MaterialEntity

robot extract -m BOT -i ./mirror/po.owl -T ./terms/PO_terms.txt --annotate-with-source true -o ./building/po_slim.owl


robot merge -i  ./building/efo_chebi_cl_eo_slim.owl -i ./building/po_slim.owl -o ./building/po_cbmerge.owl



robot reason --input ./building/po_cbmerge.owl   --axiom-generators "SubClass DisjointClasses" --output ./building/po_cbmge.owl

$(ROBOT) reason --input ./building/po_cbmerge.owl  --reasoner ELK  remove --select imports --trim false remove -T ./terms/ontologyterms.csv --select complement --select object-properties --trim true  relax  reduce -r ELK  filter -T  ./terms/ontologyterms.csv  --trim true --preserve-structure false  --output ./building/scat.owl



###Working with the uberon and merging it into EFO slim :
# 1. Create the BOT extraction of slim from eo using the ontologyterms.csv
# 2. To rename the entity - role(CHEBI_50906) as the efo role "Role"
# 3. to merge the efo_slim with chebi_slim
# 4. to use template to make the subatomic particle a subClassOf material MaterialEntity


robot extract -m BOT -i ./mirror/uberon.owl -T ./terms/UBERON_terms.txt --annotate-with-source true -o ./building/uberon_slim.owl


robot merge -i ./building/po_cbmerge.owl  -i ./building/uberon_slim.owl -o ./building/ube_cbmerge.owl


robot reason --input ./building/ube_cbmerge.owl   --axiom-generators "SubClass DisjointClasses" --output ./building/po_cbmge.owl









robot template --ancestors --input ./mirror/efo.owl  --template ./templates/template_chebi.csv  --output ./building/chebi_efo4.owl
robot template --merge-before --template ./templates/template_chebi.csv --prefix "CHEBI: http://purl.obolibrary.org/obo/CHEBI_" --prefix "SNAP: http://www.ifomis.org/bfo/1.1/snap"  -i ./build/efo_slim.owl -o ./building/chebi_efo4.owl
robot rename --input ./building/chebi_efo4.owl --mappings ./templates/renamecopy.tsv --output ./building/chebi_efo22.owl
robot merge -i ./building/chebi_efo22.owl -i ./building/chebi_efo.owl -o ./building/chebi-efofull.owl
robot query --input ./build/scatlas_tagged.owl  --update ../sparql/update.sparql --output ./build/scatlas.owl
robot template --merge-before --input ./build/scatlas.owl --template ./templates/template.csv --output ./build/scatlas2.owl
robot rename --input ./build/scatlas2.owl  --prefix-mappings ./templates/partial-rename.tsv --output ./build/scatlas3.owl
robot template --merge-before --input ./building/scatlas3.owl --template ./templates/template.csv --output ./build/scatlas4.owl
$(ROBOT) reason --input ./build/scatlas2.owl  --reasoner ELK  remove --select imports --trim false remove -T ./terms/ontologyterms.csv --select complement --select object-properties --trim true  relax  reduce -r ELK  filter -T  ./terms/ontologyterms.csv  --trim true --preserve-structure false  --output scat.owl
###The mapping to EFO Using the robot map
robot query --input ./build/cl.owl --query $(SPARQLDIR)/inSubsets.sparql $@
