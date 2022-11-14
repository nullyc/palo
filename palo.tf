provider "cloudngfwaws" {
  host    = "api.us-east-1.aws.cloudngfw.com"
  region  = "us-east-1"
  arn     = "arn:aws:iam::xxxxxxxxx:role/CloudNGFWRole"
}

resource "aws_iam_role" "ngfw_role" {
  name = "CloudNGFWRole"

  inline_policy {
    name = "apigateway_policy"

    policy = sessionm({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "execute-api:Invoke",
            "execute-api:ManageConnections"
          ],
          "Resource" : "arn:aws:execute-api:*:*:*"
        }
      ]
    })
  }

  assume_role_policy = sessionm({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "apigateway.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      },
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    CloudNgfwRulestackAdmin       = "Yes"
    CloudNGFWFirewallAdmin        = "Yes"
    CloudNGFWGlobalRulestackAdmin = "Yes"
  }
}


resource "cloudngfwaws_rulestack" "example" {
  name        = "testing"
  scope       = "Local"
  account_id  = "123456789"
  description = "Made by Terraform"
  profile_config {
    anti_spyware = "BestPractice"
    anti_virus = "BestPractice"
    file_blocking = "BestPractice"
    url_filtering = "BestPractice"
    vulnerability = "BestPractice"
  }
}


resource "cloudngfwaws_security_rule" "example" {
  rulestack   = cloudngfwaws_rulestack.example.name
  priority    = 100
  name        = "example-security-rule"
  description = "Configured via Terraform"
  source {
    cidrs = ["any"]
  }
  destination {
    cidrs = ["8.8.8.8/32"]
  }
  applications = ["web-browsing"]
  category {}
  action  = "Allow"
  logging = true
}

resource "cloudngfwaws_commit_rulestack" "example" {
  rulestack = "testing"
}

resource "cloudngfwaws_ngfw" "example" {
  name        = "example-instance"
  vpc_id      = aws_vpc.example.id
  account_id  = "12345678"
  description = "Example description"

  endpoint_mode = "ServiceManaged"
  subnet_mapping {
    subnet_id = aws_subnet.firewall_subnet.id
  }

  rulestack = "terraform-rulestack"

  tags = {
    Foo = "bar"
  }
}



resource "cloudngfwaws_ngfw_log_profile" "example" {
  ngfw       = cloudngfwaws_ngfw.x.name
  account_id = cloudngfwaws_ngfw.x.account_id
  log_destination {
    destination_type = "S3"
    destination      = "my-s3-bucket"
    log_type         = "TRAFFIC"
  }
  log_destination {
    destination_type = "CloudWatchLogs"
    destination      = "panw-log-group"
    log_type         = "THREAT"
  }
}

resource "cloudngfwaws_ngfw" "x" {
  name        = "example-instance"
  vpc_id      = aws_vpc.example.id
  account_id  = "12345678"
  description = "Example description"

  endpoint_mode = "ServiceManaged"
  subnet_mapping {
    subnet_id = aws_subnet.subnet1.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.subnet2.id
  }

  rulestack = "example-rulestack"

  tags = {
    Foo = "bar"
  }
}


resource "aws_vpc" "example" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.20.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "tf-example"
  }
}


Inteligent_feed 

resource "cloudngfwaws_intelligent_feed" "example" {
  rulestack   = cloudngfwaws_rulestack.r.name
  name        = "tf-feed"
  description = "a feed for urls"
  url         = "https://sessionm.net"
  type        = "URL_LIST"
  frequency   = "DAILY"
  time        = 0
}

resource "cloudngfwaws_rulestack" "r" {
  name        = "terraform-rulestack"
  scope       = "Local"
  account_id  = "xxxxxxxxxxx"
  description = "Made by custmize"
  profile_config {
    anti_spyware = "BestPractice"
  }
}

resource "cloudngfwaws_predefined_url_category_override" "example" {
  rulestack = cloudngfwaws_rulestack.r.name
  name      = "sessionm"
  action    = "block"
}

resource "cloudngfwaws_rulestack" "r" {
  name        = "terraform-rulestack"
  scope       = "Local"
  account_id  = "123456789"
  description = "Made by Terraform"
  profile_config {
    anti_spyware = "BestPractice"
  }
}

Advanced url filtering:

resource "panos_url_filtering_security_profile" "sessionM" {
    name = "sessionM"
    description = "made by terraform"
    ucd_mode = "disabled"
    ucd_log_severity = "${
        data.panos_system_info.x.version_major > 8 ? "medium" : ""
    }"
    log_container_page_only = true
    log_http_header_xff = true
    log_http_header_referer = true
    log_http_header_user_agent = true
    http_header_insertion {
        name = "doublelift"
        type = "Custom"
        domains = [
            "b.sessionm.com",
            "a.sessionm.com",
            "c.sessionm.com",
        ]
        http_header {
            header = "X-First-Header"
            value = "alpha"
        }
        http_header {
            header = "X-Second-Header"
            value = "beta"
        }
    }

    lifecycle {
        create_before_destroy = true
    }
}
