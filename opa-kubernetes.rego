package main

deny[msg] {
  input.kind = "Service"
  not input.spec.type = "NodePort"
  msg = "NodePort Service is not Allowed"
}

deny[msg] {
  input.kind = "Deployment"
  not input.spec.template.spec.containers[0].securityContext.runAsNonRoot = true
  msg = "Containers must not run as root - use runAsNonRoot within container securityContext"
}