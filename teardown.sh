#!/bin/bash

kubectl delete service zookeeper-1 "$@"
kubectl delete service zookeeper-2 "$@"
kubectl delete service zookeeper-3 "$@"
kubectl delete service zookeeper "$@"

kubectl delete rc zookeeper-1-rc "$@"
kubectl delete rc zookeeper-2-rc "$@"
kubectl delete rc zookeeper-3-rc "$@"

