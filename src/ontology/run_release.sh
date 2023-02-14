set -e 
date
sh run.sh make update_zooma_seed -B
sh run.sh make prepare_components -B
# Refreshing imports is necessary because unlike most other ontologies
# SCAO components depent on the imports, which is against ODK law
# See scatlas.Makefile for further comment about the issue.
sh run.sh make refresh-imports -B
sh run.sh make IMP=false all_components -B
sh run.sh make IMP=false prepare_release -B
sh run.sh make IMP=false all_diffs -B
date
