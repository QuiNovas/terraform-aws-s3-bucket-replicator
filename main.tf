resource "aws_iam_policy" "replicator" {
  name    = "LambdaLambdaLambdaReplicator"
  policy  = "${data.aws_iam_policy_document.replicator.json}"
}

resource "aws_kms_key" "lambda_environment_variables" {
  count               = "${var.kms_key_arn == "" ? 1 : 0}"
  description         = "For lambda environment variables"
  enable_key_rotation = true
}

resource "aws_kms_alias" "lambda_environment_variables" {
  count         = "${var.kms_key_arn == "" ? 1 : 0}"
  name          = "alias/lambda-environment-variables"
  target_key_id = "${aws_kms_key.lambda_environment_variables.key_id}"
}

module "replicator" {
  dead_letter_arn   = "${var.dead_letter_arn}"
  environment_variables {
    DESTINATION_BUCKETS = "${join(",", var.destination_bucket_ids)}"
  }
  handler           = "function.handler"
  kms_key_arn       = "${var.kms_key_arn == "" ? aws_kms_key.lambda_environment_variables.arn : var.kms_key_arn}"
  name              = "s3-bucket-replicator"
  policy_arns       = [
    "${aws_iam_policy.replicator.arn}",
  ]
  policy_arns_count = 1
  runtime           = "python3.7"
  l3_object_key     = "quinovas/s3-bucket-replicator/s3-bucket-replicator-0.0.1.zip"
  source            = "QuiNovas/lambdalambdalambda/aws"
  timeout           = 600
  version           = "0.2.0"
}

resource "aws_lambda_permission" "allow_bucket_execution" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${module.replicator.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${data.aws_s3_bucket.source.arn}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${data.aws_s3_bucket.source.id}"
  depends_on = [
    "aws_lambda_permission.allow_bucket_execution",
  ]
  lambda_function {
    lambda_function_arn = "${module.replicator.arn}"
    events              = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:*",
    ]
  }
}
