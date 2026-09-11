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
    default = "Z00916842MCDX0S5FWPWY"
}

variable "domain_name" {
    default = "hariawsdevops.online"
}