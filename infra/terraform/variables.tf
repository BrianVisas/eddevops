variable "kubeconfig_path" {
  description = "Path to the kubeconfig file used by the Kubernetes provider."
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Kubernetes namespace for the application resources."
  type        = string
  default     = "platform-demo"
}

variable "replicas" {
  description = "Number of application replicas."
  type        = number
  default     = 2
}

variable "image" {
  description = "Container image used by the deployment."
  type        = string
  default     = "platform-status-api:local"
}
