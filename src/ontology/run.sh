#!/bin/sh
# Wrapper script for docker.
#
# This is used primarily for wrapping the GNU Make workflow.
# Instead of typing "make TARGET", type "./run.sh make TARGET".
# This will run the make workflow within a docker container.
#
# The assumption is that you are working in the src/ontology folder;
# we therefore map the whole repo (../..) to a docker volume.
#
# To use singularity instead of docker, please issue
# 
# export USE_SINGULARITY=<any-value>
#
# before running this script.
#
# See README-editors.md for more details.

IMAGE=${IMAGE:-odkfull}
TAG=${TAG:-latest}
ODK_JAVA_OPTS=-Xmx10G
ODK_DEBUG=${ODK_DEBUG:-no}

TIMECMD=
if [ x$ODK_DEBUG = xyes ]; then
    # If you wish to change the format string, take care of using
    # non-breaking spaces (U+00A0) instead of normal spaces, to
    # prevent the shell from tokenizing the format string.
    echo "Running ${IMAGE} with ${ODK_JAVA_OPTS} of memory for ROBOT and Java-based pipeline steps."
    TIMECMD="/usr/bin/time -f ### DEBUG STATS ###\nElapsed time: %E\nPeak memory: %M kb"
fi


VOLUME_BIND=$PWD/../../:/work
WORK_DIR=/work/src/ontology

if [ -n "$USE_SINGULARITY" ]; then
    export ROBOT_JAVA_ARGS="$ODK_JAVA_OPTS"
    export JAVA_OPTS="$ODK_JAVA_OPTS"
    singularity exec --bind $VOLUME_BIND -W $WORK_DIR docker://obolibrary/$IMAGE:$TAG $TIMECMD "$@"
else
    docker run -v $VOLUME_BIND -w $WORK_DIR -e ROBOT_JAVA_ARGS="$ODK_JAVA_OPTS" -e JAVA_OPTS="$ODK_JAVA_OPTS" --rm -ti obolibrary/$IMAGE:$TAG $TIMECMD "$@"
fi


case "$@" in
*update_repo*|*release*)
    echo "Please remember to update your ODK image from time to time: https://oboacademy.github.io/obook/howto/odk-update/."
    ;;
esac
