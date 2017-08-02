#!/bin/sh

kubectl create -f https://git.io/kube-dashboard && kubectl proxy
