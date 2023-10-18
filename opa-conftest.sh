#!/bin/bash
docker run --rm -v $WORKSPACE:/project openpolicyagent/conftest test --policy opa-docker.rego Dockerfile