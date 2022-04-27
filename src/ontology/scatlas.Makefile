RG = relation-graph

.PHONY: update_zooma_seed

update_zooma_seed:
	echo 'Pulling new Zooma seed'
	wget -O ../curation/scatlas_seed_table.tsv https://raw.githubusercontent.com/ebi-gene-expression-group/curated-metadata/master/zoomage_report.CURATED.tsv

../curation/scatlas_seed.txt: ../curation/scatlas_seed_table.tsv
	cat $< | cut -f3 -s | sed 's/\r//' | awk '{$$1=$$1};1' | sed '/^\(http\)/!d' | tr \| \\n  | sort | uniq > $@

$(TMPDIR)/seed.txt: ../curation/scatlas_seed.txt
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


components/%_seed_extract.sparql: $(TMPDIR)/seed.txt
	sh ../scripts/generate_sparql_subclass_query.sh $(TMPDIR)/seed.txt $@


components/%_simple_seed.txt: imports/%_import.owl components/%_seed_extract.sparql $(TMPDIR)/seed.txt $(SCATLAS_KEEPRELATIONS)
	$(ROBOT) query --input $< --query components/$*_seed_extract.sparql $@.tmp.txt && \
	cat $(TMPDIR)/seed.txt $(SCATLAS_KEEPRELATIONS) $@.tmp.txt | sort | uniq > $@  && rm $@.tmp.txt
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

$(TMPDIR)/%_relation_graph.ofn: imports/%_import.owl $(TMPDIR)/seed.txt $(SCRIPTSDIR)/prune_convert.dl
	$(RG) --ontology-file $< --properties-file $(SCATLAS_KEEPRELATIONS) --output-file $(TMPDIR)/$*-materialize-direct.nt
	cp $(TMPDIR)/seed.txt $(TMPDIR)/term.tmp.facts
	sed -e 's/^/</' -e 's/$$/>/' <$(TMPDIR)/term.tmp.facts >$(TMPDIR)/term.facts && rm $(TMPDIR)/term.tmp.facts
	sed 's/ /\t/' <$(TMPDIR)/$*-materialize-direct.nt | sed 's/ /\t/' | sed 's/ \.$$//' >$(TMPDIR)/rdf.facts
	riot --output=ntriples imports/$*_import.owl | sed 's/ /\t/' | sed 's/ /\t/' | sed 's/ \.$$//' >$(TMPDIR)/ontrdf.facts
	souffle --fact-dir=$(TMPDIR) --compile $(SCRIPTSDIR)/prune_convert.dl
	sed -e '1s/^/Ontology(<http:\/\/purl.obolibrary.org\/obo\/$*-extended.owl>\n/' -e '$$s/$$/)/' <ofn.csv >$@ && rm ofn.csv 
.PRECIOUS: $(TMPDIR)/%_relation_graph.ofn

components/%.owl: imports/%_import.owl components/%_simple_seed.txt $(SCATLAS_KEEPRELATIONS) $(TMPDIR)/%_relation_graph.ofn
	$(ROBOT) merge --input $< -i $(TMPDIR)/$*_relation_graph.ofn \
		reason --reasoner ELK  \
		remove --axioms disjoint --trim false --preserve-structure false \
		remove --term-file $(SCATLAS_KEEPRELATIONS) --select complement --select object-properties --trim true \
		relax \
		filter --term-file components/$*_simple_seed.txt --select "annotations ontology anonymous self" --trim true --signature true \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@
.PRECIOUS: components/%.owl

	#reduce -r ELK \

imports/fbbt_merged.owl: mirror/fbbt.owl mirror/uberon.owl mirror/uberon-bridge-to-fbbt.owl mirror/cl-bridge-to-fbbt.owl mirror/cl.owl
	if [ $(IMP) = true ]; then $(ROBOT) merge $(patsubst %, -i %, $^) \
	  remove --axioms disjoint  -o $@; fi

imports/fbbt_import.owl: imports/fbbt_merged.owl imports/fbbt_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) extract -i $< -T imports/fbbt_terms_combined.txt --force true --method BOT \
		query --update ../sparql/inject-subset-declaration.ru \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: imports/fbbt_import.owl

components/subclasses.owl: ../template/subclass_terms.csv
	$(ROBOT) -vvv template --template $<  --prefix "EFO: http://www.ebi.ac.uk/efo/EFO_" --prefix "RS: http://purl.obolibrary.org/obo/RS_" --prefix "UBERON: http://purl.obolibrary.org/obo/UBERON_" --prefix "GO: http://purl.obolibrary.org/obo/GO_" --prefix "CARO: http://purl.obolibrary.org/obo/CARO_" --prefix "UBERON: http://purl.obolibrary.org/obo/UBERON_" --prefix "FBbt: http://purl.obolibrary.org/obo/FBbt_" --prefix "MONDO: http://purl.obolibrary.org/obo/MONDO_"  --prefix "NCIT: http://purl.obolibrary.org/obo/NCIT_" --prefix "CHEBI: http://purl.obolibrary.org/obo/CHEBI_" --prefix "Orphanet: http://www.orpha.net/ORDO/Orphanet_" --prefix "snap: http://www.ifomis.org/bfo/1.1/snap#" annotate --ontology-iri $(ONTBASE)/$@ -o $@


components/fbbt.owl: imports/fbbt_import.owl components/fbbt_simple_seed.txt $(SCATLAS_KEEPRELATIONS) $(TMPDIR)/fbbt_relation_graph.ofn
	if [ $(IMP) = true ]; then $(ROBOT) merge --input $< -i $(TMPDIR)/fbbt_relation_graph.ofn reason --reasoner ELK relax \
    remove --axioms equivalent \
    remove --axioms disjoint \
    remove --term-file $(SCATLAS_KEEPRELATIONS) --select complement --select object-properties --trim true \
    relax \
    filter --term-file components/fbbt_simple_seed.txt --select "annotations ontology anonymous self" --trim true --signature true \
    reduce -r ELK \
    annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: components/%.owl


components/omit.owl: imports/omit_import.owl components/omit_simple_seed.txt $(SCATLAS_KEEPRELATIONS)
	if [ $(IMP) = true ]; then $(ROBOT) merge --input $< relax remove --axioms disjoint reason --reasoner ELK \
		remove --axioms equivalent \
		remove --term-file $(SCATLAS_KEEPRELATIONS) --select complement --select object-properties --trim true \
		relax \
		filter --term-file components/fbbt_simple_seed.txt --select "annotations ontology anonymous self" --trim true --signature true \
		reduce -r ELK \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: components/%.owl

$(ONT)-full.owl: $(SRC) components/subclasses.owl ../curation/blacklist.txt
	$(ROBOT) merge --input $(SRC) -i components/subclasses.owl \
		remove --axioms equivalent --trim false \
		remove --term-file ../curation/blacklist.txt \
		reason --reasoner ELK --equivalent-classes-allowed all \
		relax \
		reduce -r ELK \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@


imports/omit_import.owl:
	touch $@
	echo "OMIT is currently broken and should not be regenerated. see also https://github.com/OmniSearch/omit/issues/8"

imports/omit_import.obo:
	touch $@
	echo "OMIT is currently broken and should not be regenerated. see also https://github.com/OmniSearch/omit/issues/8"


../curation/retrieved_seed.txt: $(ONT)-full.owl  ../sparql/seed_class.sparql
	$(ROBOT) query -i $(ONT)-full.owl --query ../sparql/seed_class.sparql $@.tmp
	cat $@.tmp | sed 's/\r//' | sort | awk '{$$1=$$1};1' | sed '/^\(http\)/!d' | tr \| \\n  | sort | uniq > $@

#sca.owl to be added as dependent
../curation/curated_but_not_retrieved.txt: ../curation/retrieved_seed.txt ../curation/scatlas_seed.txt
	comm -13  ../curation/retrieved_seed.txt ../curation/scatlas_seed.txt > $@

../curation/curated_and_retrieved.txt: ../curation/curated_but_not_retrieved.txt ../curation/scatlas_seed.txt
	comm -13  ../curation/curated_but_not_retrieved.txt ../curation/scatlas_seed.txt > $@


all_diffs: ../curation/retrieved_seed.txt ../curation/curated_but_not_retrieved.txt ../curation/curated_and_retrieved.txt


# Manual import of the VFB drivers ontology
mirror/vfb_drivers.trigger: $(SRC)

mirror/vfb_drivers.owl: mirror/vfb_drivers.trigger
	if [ $(MIR) = true ]; then \
		wget -O mirror/vfb_drivers.owl \
			http://virtualflybrain.org/data/VFB/OWL/vfb_drivers.owl ; \
	fi

components/vfb_drivers.owl: mirror/vfb_drivers.owl
	$(ROBOT) remove --input $< --axioms disjoint \
		annotate --ontology-iri $(ONTBASE)/$@ \
			--version-iri $(ONTBASE)/releases/$(TODAY)/$@ \
			--output $@

update_repo:
	sh ../scripts/update_repo.sh
