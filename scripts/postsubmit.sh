#!/bin/bash
PROJECT_NAME=$1
PROJECT_ROOT=$2
shift
shift

set -e

: ${N_JOBS:=2}

case $OS in
linux)
    docker rm -f ${PROJECT_NAME} &>/dev/null || true
    docker run -d -it --name ${PROJECT_NAME} --privileged polettimarco/fruit-basesystem:ubuntu-$UBUNTU
    docker exec ${PROJECT_NAME} mkdir ${PROJECT_NAME}
    docker cp ${PROJECT_ROOT} ${PROJECT_NAME}:/${PROJECT_NAME}
    
    docker exec ${PROJECT_NAME} bash -c "
        export COMPILER=$COMPILER; 
        export N_JOBS=$N_JOBS;
        export STLARG=$STLARG; 
        export OS=$OS;
        ls -lachs
        cd ${PROJECT_NAME}
        bash scripts/postsubmit-helper.sh $1"
    exit $?
    ;;

osx)
    export COMPILER
    export N_JOBS
    export STLARG
    export OS
    bash scripts/postsubmit-helper.sh "$@"
    exit $?
    ;;

*)
    echo "Unsupported OS: $OS"
    exit 1
esac
