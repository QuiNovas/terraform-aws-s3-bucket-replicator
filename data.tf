data "aws_s3_bucket" "source" {
  bucket = var.source_bucket
}

data "aws_iam_policy_document" "replicator" {
  statement {
    actions = [
      "s3:GetObject*",
    ]
    resources = [
      "${data.aws_s3_bucket.source.arn}/*",
    ]
    sid = "AllowCopyingFrom"
  }
  statement {
    actions = [
      "s3:DeleteObject*",
      "s3:PutObject*",
    ]
    resources = var.destination_bucket_obj_arns
    sid       = "AllowCopyingTo"
  }
}

