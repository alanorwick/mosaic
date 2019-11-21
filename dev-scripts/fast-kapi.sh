#!/bin/bash

cd $HOME/workspace/nectar-mosaic/kapi
docker build . -t xaviermillot/kapi-test:latest
docker push xaviermillot/kapi-test:latest
kubectl delete pod -l app=fast-kapi -n nectar

cd $HOME/workspace/nectar-mosaic/infra/dev-scripts
kubectl apply -f fast-kapi-pod.yaml -n nectar
