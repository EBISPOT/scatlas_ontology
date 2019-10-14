
## Customize Makefile settings for SCAtlas
##
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

../curation/scatlas_seed.txt: ../curation/scatlas_seed_table.tsv
	cat $< | cut -f3 -s > $@