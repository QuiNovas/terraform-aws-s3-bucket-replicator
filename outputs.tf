output "kms_key_arn" {
  description = "The arn of the KMS key used to encrypt the environment variables"
  value       = "${var.kms_key_arn == "" ? aws_kms_key.lambda_environment_variables.*.arn[0] : var.kms_key_arn}"
}

output "replicator_arn" {
  description = "The arn of the lambda function that perfoms replication"
  value       = "${module.replicator.arn}"
}