# IAM policy for ALB Load Balancer Controller
resource "aws_iam_policy" "alb_load_balancer_iam_policy" {
  name = "alb-load-balancer-iam-policy"

  policy = file("helm_values/alb-load-balancer-iam-policy.json")
}

resource "aws_iam_role" "alb_load_balancer_iam_role" {
  name = "alb-load-balancer-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      },
    ]
  })
}

# Attach the IAM policy to the ALB Load Balancer Role
resource "aws_iam_role_policy_attachment" "alb_load_balancer_role_policy_attachment" {
  policy_arn = aws_iam_policy.alb_load_balancer_iam_policy.arn
  role       = aws_iam_role.alb_load_balancer_iam_role.name
}

# Deploy the ALB Load Balancer Controller using Helm
resource "helm_release" "alb_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.4"

  set = [{
    name  = "clusterName"
    value = data.terraform_remote_state.eks.outputs.cluster_name
    }, {
    name  = "serviceAccount.create"
    value = "true"
    }, {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
    }, {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_load_balancer_iam_role.arn
    }
  ]
}

data "aws_caller_identity" "current" {}
