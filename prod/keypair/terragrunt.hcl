include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-key-pair"
}

locals {
  # Automatically load environment-level variables
  env   = yamldecode(file(find_in_parent_folders("env.yaml")))["env"]
  name = "asg-${local.env["name"]}-${local.env["environment"]}"

}

inputs = {

  # Launch configuration
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "devops-team"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOSeRCtC6UJ4LfsDWKweSrJKUDq/BuSn6hWfdMJ46k6DYf8pdWSTKso0OpN/aSztg5hncSQgaaMFrsx2YkZDNGmS7redMSZpuvL5lmMw0Kcg4nlz8zhL5xYjA/ugm+ZMarbUeYS7ubRQd84u1ZQdxEgFnp+dJx44tXjPkXh43FFHyIbkYOkqbpnvkS1tpt2pEjpx4tTmTRVIq+Bu9d0PFKppMLl7xxhb5iYTlcCOoh6g/UHPg0aqOc5neyxp9Yj7GuYAZnPhu1EPeuQsrNYpJGaSO1YCLPP73Hg65AZdZmccG61kmswKpmE4euZOs3ml+pgG0KFKej60M8dm2yE4iwbCrXO3EZLBDZKT+JOY2RDFw1RtSo8c4XJPcQ6sgyXHGYR3QHHVxkeGPmsyMfwBSLMrOzR30xuqJuIiyc2RZPKX8pjNE41tF3CvJeGEMrTcTHr2FoQUN4L0xY/vgyuWFL8wDyUR7/YcDk9pql44SnjSDtISPBh/bfDCpZb6VNjMs="

}

