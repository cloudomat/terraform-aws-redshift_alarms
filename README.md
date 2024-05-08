# Redshift Alarms

This module creates CloudWatch alerts for Redshift clusters.

Each supported metric can be given two thresholds. The first threshold will trigger a "low priority" alarm. This is intended for early notification of unusual system behavior or known potential issues, such as running out of database capacity. The second threshold will trigger a "high priority" alarm. This is intended for situations which require immediate attention and may indicate that downtime of the Redshift cluster or services using the cluster is imminent.

## Installation

This is a complete example of a minimal set of alarms.

```hcl
provider "aws" {}

variable "cluster_identifier" {
  type        = string
  description = "The identifier of a Redshift cluster to monitor."
}

data "aws_redshift_cluster" "cluster" {
  cluster_identifier = var.cluster_identifier
}

module "alarms" {
  source = "cloudomat/redshift_alerts/aws"

  redshift_cluster = data.aws_redshift_cluster.cluster

  low_priority_alarm  = []
  high_priority_alarm = []
}
```
