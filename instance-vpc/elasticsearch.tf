resource "aws_elasticsearch_domain" "es" {
  domain_name           = "Elasticsearch-tf-test"
  elasticsearch_version = "6.0"
  cluster_config {
    instance_type = "t2.small.elasticsearch"
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": ["***.**.**.**"]}
            }
        }
    ]
}
CONFIG

ebs_options {
    ebs_enabled = true
    volume_size = 10
}

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags {
    Domain = "TestDomain"
  }
}