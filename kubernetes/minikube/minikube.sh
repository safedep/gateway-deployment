#!/bin/bash

GATEWAY_CPU_LIMIT="2"
GATEWAY_MEMORY_LIMIT="4g"
GATEWAY_MINIKUBE_DRIVE="docker"
GATEWAY_CLUSTER_NAME="safedep-gateway"

COLOR_CLEAR='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_GREEN='\033[0;32m'
TEXT_BOLD='\033[1m'

err() {
  echo -e "${COLOR_RED}${TEXT_BOLD}ERROR:${COLOR_CLEAR} $@" >&2
}

info() {
  echo -e "${COLOR_GREEN}${TEXT_BOLD}INFO:${COLOR_CLEAR} $@"
}

warn() {
  echo -e "${COLOR_YELLOW}${TEXT_BOLD}INFO:${COLOR_CLEAR} $@"
}

failIfLastFailed() {
  if [ "$?" != "0" ]; then
    err "Last command execution failed"
    exit -1
  fi
}

setup() {
  cpu=$GATEWAY_CPU_LIMIT
  memory=$GATEWAY_MEMORY_LIMIT
  driver=$GATEWAY_MINIKUBE_DRIVE
  clusterName=$GATEWAY_CLUSTER_NAME

  info "Creating gateway cluster: $clusterName with $cpu CPU(s) and $memory mem"
  minikube start \
    --driver=$driver \
    --cpus=$cpu \
    --memory=$memory \
    --profile=$clusterName \
    --addons=metrics-server

  failIfLastFailed

  info "Mounting policies directory inside cluster node"
  minikube mount --profile=$clusterName \
    "$(pwd)/policies":/data/policies 2>&1 &

  failIfLastFailed
}

teardown() {
  clusterName=$GATEWAY_CLUSTER_NAME

  info "Destroying gateway cluster: $clusterName"
  minikube delete --profile=$clusterName

  failIfLastFailed

  info "Destroying mount for: $clusterName"
  for x in `ps aux | grep "minikube mount --profile=$clusterName" | awk '{print $2}'`; do
    kill -9 $x > /dev/null 2>&1
  done
}

tunnel() {
  clusterName=$GATEWAY_CLUSTER_NAME
  minikube --profile=$clusterName tunnel
}

while test $# -gt 0; do
  case "$1" in
    -cpu)
      shift
      GATEWAY_CPU_LIMIT=$1
      shift
      ;;
    -memory)
      shift
      GATEWAY_MEMORY_LIMIT=$1
      shift
      ;;
    setup)
      shift
      RUN_MODE="setup"
      ;;
    teardown)
      shift
      RUN_MODE="teardown"
      ;;
    tunnel)
      shift
      RUN_MODE="tunnel"
      ;;
    *)
      err "Unrecognized argument: $1"
      exit -1
      ;;
  esac
done

if [ "$RUN_MODE" == "setup" ]; then
  setup
elif [ "$RUN_MODE" == "teardown" ]; then
  teardown
elif [ "$RUN_MODE" == "tunnel" ]; then
  tunnel
else
  err "Mode not set"
  exit -1
fi

