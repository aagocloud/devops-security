#!/bin/bash
docker run --rm -v $WORKSPACE:/project openpolicyagent/conftest test --policy opa-kubernetes.rego k8s_deployment_service.yaml