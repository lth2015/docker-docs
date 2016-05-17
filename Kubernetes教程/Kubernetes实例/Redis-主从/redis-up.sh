#!/bin/bash
kubectl create -f redis-master-rc.yaml
kubectl create -f redis-master-svc.yaml
kubectl create -f redis-slave-rc.yaml
kubectl create -f redis-slave-svc.yaml
