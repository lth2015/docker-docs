#!/bin/bash
kubectl delete -f redis-master-rc.yaml
kubectl delete -f redis-master-svc.yaml
kubectl delete -f redis-slave-rc.yaml
kubectl delete -f redis-slave-svc.yaml
