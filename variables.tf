variable "account_id" {
  description = "Account Id"
  type        = string
}

variable "log_groups_arn" {
  description = "Logs groups arn"
  type        = list(any)
}

variable "kms_alias" {
  description = "Alias name of kms"
  type        = string
}
