resource "aws_iam_user" "s3-etcd-backup" {
  name = "s3-etcd-backup-${var.cluster_name}"
}

resource "aws_iam_access_key" "s3-etcd-backup" {
  user = aws_iam_user.s3-etcd-backup.name
  depends_on = [
    aws_iam_user_policy.s3-etcd-backup-access
  ]
}

resource "aws_iam_user_policy" "s3-etcd-backup-access" {
  name = aws_iam_user.s3-etcd-backup.name
  user = aws_iam_user.s3-etcd-backup.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "*"
        Resource = [
          "arn:aws:s3:::${var.s3_etcd_backup_bucket}/${var.cluster_name}",
          "arn:aws:s3:::${var.s3_etcd_backup_bucket}/${var.cluster_name}/*",
        ]
      }
    ]
  })
}