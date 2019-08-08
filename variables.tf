variable "dead_letter_arn" {
  description = "The arn for the SNS topic that handles dead letters"
  type        = string
}

variable "destination_bucket_ids" {
  description = "A list of bucket name/ids to replicate to."
  type        = list(string)
}

variable "destination_bucket_obj_arns" {
  description = "A list of bucket arns to replicate to. Must be in the format arn:aws:s3:::my_bucket/*"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "The arn of the KMS key used to encrypt the environment variables"
  type        = string
}

variable "prefix" {
  type = string
  default =""
  
}


variable "source_bucket" {
  description = "The bucket name or id to replicate."
  type        = string
}

