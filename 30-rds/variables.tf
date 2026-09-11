variable "project_name" {
    default = "roboshop"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "roboshop"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "zone_id" {
    default = "Z09967543987OBRKFSPGO"
}

variable "domain_name" {
    default = "iambatman.online"
}