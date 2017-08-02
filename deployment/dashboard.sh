#!/bin/sh

(kubectl create -f https://git.io/kube-dashboard || true) && kubectl proxy
