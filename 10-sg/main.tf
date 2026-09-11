# main.tf

# ---------------------------------------------------
# Security Group for EKS Control Plane (Cluster)
# ---------------------------------------------------
resource "aws_security_group" "eks_cluster_sg" {
  name        = "roboshop-dev-eks-cluster-sg"
  description = "Security group for EKS control plane"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "roboshop-dev-eks-cluster-sg"
    Project     = "roboshop"
    Environment = "dev"
  }
}

# ---------------------------------------------------
# Security Groups (including eks_node) via module
# ---------------------------------------------------
module "sg" {
  count       = length(var.sg_names)
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.project}-${var.environment}-${var.sg_names[count.index]}"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  description = "Security group for ${var.sg_names[count.index]}"
}

# ---------------------------------------------------
# Allow cluster SG to receive traffic from node SG
# (node SG comes from the module, not a separate resource)
# ---------------------------------------------------
resource "aws_security_group_rule" "cluster_ingress_from_nodes" {
  description              = "Allow nodes to communicate with control plane"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = module.sg[index(var.sg_names, "eks_node")].id
}

# ---------------------------------------------------
# Store cluster SG ID in SSM Parameter Store for EKS module
# (eks_node_sg_id is already written by parameters.tf via the sg_names loop)
# ---------------------------------------------------
resource "aws_ssm_parameter" "eks_cluster_sg_id" {
  name  = "/roboshop/dev/eks_cluster_sg_id"
  type  = "String"
  value = aws_security_group.eks_cluster_sg.id

  tags = {
    Project     = "roboshop"
    Environment = "dev"
  }
}