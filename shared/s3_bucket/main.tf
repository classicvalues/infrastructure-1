# Required variables:
variable "name" {
  description = "The name for this bucket (usually the application name)."
}

variable "user" {
  description = "The IAM user to grant permissions to read/write to this bucket."
}

# Optional variables:
variable "acl" {
  description = "The canned ACL for this bucket. See: https://goo.gl/TFnRSY"
  default     = "public-read"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.name}"
  acl    = "${var.acl}"

  tags {
    Application = "${var.name}"
  }
}

data "template_file" "s3_policy" {
  template = "${file("${path.module}/iam-policy.json.tpl")}"

  vars {
    bucket_arn = "${aws_s3_bucket.bucket.arn}"
  }
}

resource "aws_iam_user_policy" "s3_policy" {
  name   = "${var.name}-s3"
  user   = "${var.user}"
  policy = "${data.template_file.s3_policy.rendered}"
}

output "id" {
  value = "${aws_s3_bucket.bucket.id}"
}

output "region" {
  value = "${aws_s3_bucket.bucket.region}"
}

output "config_vars" {
  value = {
    STORAGE_DRIVER = "s3"
    S3_REGION      = "${aws_s3_bucket.bucket.region}"
    S3_BUCKET      = "${aws_s3_bucket.bucket.id}"
  }
}
