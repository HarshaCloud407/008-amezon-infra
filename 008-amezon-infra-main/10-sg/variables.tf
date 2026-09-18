variable "project" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "sg_names" {
  default = [
    "mongodb",
    "redis",
    "mysql",
    "rabbitmq",
    "catalogue",
    "user",
    "cart",
    "shipping",
    "payment",
    "backend_alb",
    "frontend",
    "frontend_alb",
    "bastion",
    "openvpn",
    "eks_node"
  ]
}