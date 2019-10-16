
## Customize Makefile settings for SCAtlas
##
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

../curation/scatlas_seed.txt: ../curation/scatlas_seed_table.tsv
	cat $< | cut -f3 -s | sort | awk '{$$1=$$1};1' | sed '/^\(http\)/!d' | tr \| \\n  | uniq > $@



seed.txt: ../curation/scatlas_seed.txt
	cp $< $@
	echo 'http://www.ebi.ac.uk/efo/EFO_0000001' >> $@


COMPONENT_FILES= $(patsubst %.owl, components/%.owl, $(notdir $(wildcard components/*.owl)))


all_components: $(COMPONENT_FILES)
	echo $(COMPONENT_FILES)


SCATLAS_KEEPRELATIONS= ../curation/scatlas_relations.txt


components_sparql = $(patsubst %, components/%_seed_extract.sparql, $(IMPORTS))
components_seeds = $(patsubst %, components/%_simple_seed.txt, $(IMPORTS))
.PHONY: prepare_components
prepare_components:
	touch $(components_sparql)   &&\
	touch $(components_seeds)


components/%_seed_extract.sparql: seed.txt
	sh ../scripts/generate_sparql_subclass_query.sh seed.txt $@


components/%_simple_seed.txt: imports/%_import.owl components/%_seed_extract.sparql seed.txt
	$(ROBOT) query --input $< --select components/$*_seed_extract.sparql $@.tmp && \
	cat seed.txt $@.tmp | sort | uniq > $@  && rm $@.tmp
	#sed -i '/BFO_0000001/d' $@
	#sed -i '/BFO_0000002/d' $@
	#sed -i '/BFO_0000003/d' $@
	#sed -i '/BTO_0000000/d' $@
	#sed -i '/UBERON_0000000/d' $@
	#sed -i '/Orphanet_183634/d' $@
	#sed -i '/Orphanet_208593/d' $@
	#sed -i '/orpha.*ObsoleteClass/d' $@




	#comm -2 -3 $@ ../curation/blacklist.txt > $@
  #cat ../curation/blacklist.txt | sort | uniq >  ../curation/blacklist.txt.tmp && mv ../curation/blacklist.txt.tmp  ../curation/blacklist.txt

components/%.owl: imports/%_import.owl components/%_simple_seed.txt $(SCATLAS_KEEPRELATIONS)
	$(ROBOT) merge --input $<  \
		reason --reasoner ELK  \
		remove --axioms disjoint --trim false --preserve-structure false \
		remove --term-file $(SCATLAS_KEEPRELATIONS) --select complement --select object-properties --trim true \
		relax \
		filter --term-file components/$*_simple_seed.txt --select "annotations ontology anonymous self" --trim true --signature true \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@
.PRECIOUS: components/%.owl

	#reduce -r ELK \

imports/fbbt_merged.owl: mirror/fbbt.owl mirror/uberon.owl mirror/uberon-bridge-to-fbbt.owl mirror/cl-bridge-to-fbbt.owl mirror/cl.owl
	$(ROBOT) 	merge $(patsubst %, -i %, $^) \
	remove --axioms disjoint  -o $@

imports/fbbt_import.owl: imports/fbbt_merged.owl imports/fbbt_terms_combined.txt
	@if [ $(IMP) = true ]; then $(ROBOT) extract -i $< -T imports/fbbt_terms_combined.txt --force true --method BOT \
		query --update ../sparql/inject-subset-declaration.ru \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: imports/fbbt_import.owl

components/subclasses.owl: ../template/subclass_terms.csv
	$(ROBOT) -vvv template --template $<  --prefix "EFO: http://www.ebi.ac.uk/efo/EFO_" --prefix "UBERON: http://purl.obolibrary.org/obo/UBERON_" --prefix "GO: http://purl.obolibrary.org/obo/GO_" --prefix "CARO: http://purl.obolibrary.org/obo/CARO_" --prefix "UBERON: http://purl.obolibrary.org/obo/UBERON_" --prefix "FBbt: http://purl.obolibrary.org/obo/FBbt_" --prefix "MONDO: http://purl.obolibrary.org/obo/MONDO_"  --prefix "NCIT: http://purl.obolibrary.org/obo/NCIT_" --prefix "CHEBI: http://purl.obolibrary.org/obo/CHEBI_" --prefix "Orphanet: http://www.orpha.net/ORDO/Orphanet_" --prefix "snap: http://www.ifomis.org/bfo/1.1/snap#" annotate --ontology-iri $(ONTBASE)/$@ -o $@




components/fbbt.owl: imports/fbbt_merged.owl components/fbbt_simple_seed.txt $(SCATLAS_KEEPRELATIONS)
	$(ROBOT) merge --input $<  \
		reason --reasoner ELK  \
		relax \
		remove --axioms equivalent \
		remove --axioms disjoint \
		remove --term-file $(SCATLAS_KEEPRELATIONS) --select complement --select object-properties --trim true \
		relax \
		filter --term-file components/fbbt_simple_seed.txt --select "annotations ontology anonymous self" --trim true --signature true \
		reduce -r ELK \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@
.PRECIOUS: components/%.owl

sca.owl:
	$(ROBOT) merge --input $(SRC) \
		remove -T curation/blacklist.txt \ 
		reason --reasoner ELK --equivalent-classes-allowed all \
		relax \
		reduce -r ELK \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@
