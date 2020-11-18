resource "aws_iam_policy" "replicator" {
  name        = "${var.prefix}-LambdaLambdaLambdaReplicator"
  policy      = data.aws_iam_policy_document.replicator.json
  description = var.description
}

module "replicator" {
  dead_letter_arn = var.dead_letter_arn
  description     = var.description
  environment_variables = {
    DESTINATION_BUCKETS = join(",", var.destination_bucket_ids)
  }
  handler     = "function.handler"
  kms_key_arn = var.kms_key_arn
  name        = "${var.prefix}-s3-bucket-replicator"
  policy_arns = [
    aws_iam_policy.replicator.arn,
  ]
  runtime       = "python3.7"
  l3_object_key = "quinovas/s3-bucket-replicator/s3-bucket-replicator-0.0.1.zip"
  source        = "QuiNovas/lambdalambdalambda/aws"
  timeout       = 600
  tags          = var.tags
  version       = "3.0.3"
}

resource "aws_lambda_permission" "allow_bucket_execution" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.replicator.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.source.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket     = data.aws_s3_bucket.source.id
  depends_on = [aws_lambda_permission.allow_bucket_execution]
  lambda_function {
    lambda_function_arn = module.replicator.arn
    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:*",
    ]
  }
}

