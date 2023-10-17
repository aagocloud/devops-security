#!/bin/bash

dockerBaseImage=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerBaseImage

docker run -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.45.1 -q image --exit-code 0 --severity HIGH --light $dockerBaseImage
docker run -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.45.1 -q image --exit-code 1 --severity CRITICAL --light $dockerBaseImage

    # Trivy scan result processing
    exit_code =$?
    echo "Exit code : $exit_code"

    if [[ "${exit_code}" == 1 ]]; then
        echo "Image scanning failed. Vulnerability found"
        exit 1;
    else
        echo "Image scanning passed. No CRITICAL Vulnerabilities found"
    fi;