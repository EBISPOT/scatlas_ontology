set -e 
date
sh run.sh make prepare_components -B
sh run.sh make all_components -B
sh run.sh make IMP=false prepare_release -B
sh run.sh make IMP=false all_diffs -B
date
