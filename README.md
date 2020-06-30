# Usage
```hcl-terraform
module aws-client-vpn {
  source = "github.com/michallorens/aws-client-vpn"

  domain_name  = "example.com"
  organization = "Example, Inc"
  cidr         = "10.0.0.0/16"
  subnets      = ["subnet-1a2b3c4e", "subnet-5f6g7h8i"]
}
```