echo "This is an experimental upgrade repo script. It will overwrite your repositories Makefile, update sparql queries, add missing files and update the docker wrapper. This file must be run on the client machine directly, and not inside a docker container."

set -e

OID=scatlas
SRCDIR=..

rm -f target
mkdir target
./seed-via-docker.sh -c -g False -C $OID"-odk.yaml"
cp -rn target/$OID/src $SRCDIR

