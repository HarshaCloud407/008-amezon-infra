variable "project_name" {
    default = "roboshop"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "roboshop"
        Terraform = "true"
        Environment = "dev"
    }
}


variable "zone_name" {
    default = "hariawsdevops.online"
}

variable "zone_id" {
    default = "Z00916842MCDX0S5FWPWY"
}
