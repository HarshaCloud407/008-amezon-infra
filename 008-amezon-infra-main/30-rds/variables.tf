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
    default = "Z096073630PSK6TVL393N"
}

variable "domain_name" {
    default = "hariawsdevops.online"
}