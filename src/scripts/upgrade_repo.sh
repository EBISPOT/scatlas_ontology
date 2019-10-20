echo "This is an experimental upgrade repo script. It will overwrite your repositories Makefile, update sparql queries and add missing files."

set -e

OID=scatlas
SRCDIR=../

rm -rf target
mkdir target
/tools/odk.py seed -c -g False -C $OID"-odk.yaml"
ls -l target/$OID/src
ls -l $SRCDIR
rsync -r -u --ignore-existing target/$OID/src/ $SRCDIR

