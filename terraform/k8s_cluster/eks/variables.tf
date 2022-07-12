variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "profile" {
  default     = "personal"
  description = "AWS CLI profile"
}

variable "cluster_name" {
  default = "eks"
}

variable "env" {
  default     = "dev"
  description = "dev | qa | prod"
}

variable "kubernetes_version" {
  default = "1.21"
}

variable "default_node_type" {
  default = "t3.micro"
}