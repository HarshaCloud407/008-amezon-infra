module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.2.1"

  identifier = local.resource_name

  engine         = "mysql"
  engine_version = "8.0"

  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  db_name = "transactions"

  username = "root"
  port     = 3306

  # AWS Secrets Manager manages the RDS master password.
  manage_master_user_password = true

  vpc_security_group_ids = [
    local.mysql_sg_id
  ]

  create_db_subnet_group = false
  db_subnet_group_name   = local.database_subnet_group_name

  family               = "mysql8.0"
  major_engine_version  = "8.0"

  deletion_protection = false
  skip_final_snapshot = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  tags = merge(
    var.common_tags,
    {
      Name = local.resource_name
    }
  )
}

resource "aws_route53_record" "mysql" {
  zone_id = var.zone_id

  name = "mysql-${var.environment}.${var.domain_name}"

  type = "CNAME"
  ttl  = 300

  records = [
    module.db.db_instance_address
  ]

  allow_overwrite = true
}