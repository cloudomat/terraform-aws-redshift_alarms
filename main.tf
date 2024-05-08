# Copyright 2023 Teak.io, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4, < 6"
    }
  }

  required_version = ">= 1.5.0"
}

locals {
  var_map = {
    compute_cpu_utilization = {
      low_value          = var.compute_cpu_utilization_high_threshold
      high_value         = var.compute_cpu_utilization_vhigh_threshold
      metric_postfix     = "%"
      metric_description = "CPU Utilization"
      metric_name        = "CPUUtilization"
      directionality     = "high"
    },
    leader_cpu_utilization = {
      low_value          = var.leader_cpu_utilization_high_threshold
      high_value         = var.leader_cpu_utilization_vhigh_threshold
      metric_postfix     = "%"
      metric_description = "CPU Utilization"
      metric_name        = "CPUUtilization"
      directionality     = "high"
    },
    compute_percentage_disk_space_used = {
      low_value          = var.percentage_disk_space_used_high_threshold
      high_value         = var.percentage_disk_space_used_vhigh_threshold
      metric_postfix     = "%"
      metric_description = "Disk Space Used"
      metric_name        = "PercentageDiskSpaceUsed"
      directionality     = "high"
    }
  }

  low_priority_alarms  = { for key, value in local.var_map : "low_${key}" => merge(value, { level = "", value = value["low_value"] }) if value["low_value"] != null }
  high_priority_alarms = { for key, value in local.var_map : "high_${key}" => merge(value, { level = "high", value = value["high_value"] }) if value["high_value"] != null }
  alarms               = merge(local.low_priority_alarms, local.high_priority_alarms)

  computed_redshift_nodes = toset(concat(["LEADER"], [for i in range(var.redshift_cluster.number_of_nodes) : "COMPUTE-${i}"]))

  compute_node_alarms = [
    for node in local.computed_redshift_nodes :
    { for key, value in local.alarms : "${node}_${key}" => merge(value, { node = node }) if strcontains(key, "compute") }
    if startswith(lower(node), "compute")
  ]

  leader_node_alarms = [
    for node in local.computed_redshift_nodes :
    { for key, value in local.alarms : "${node}_${key}" => merge(value, { node = node }) if strcontains(key, "leader") }
    if startswith(lower(node), "leader")
  ]

  combined_alarms = concat(local.compute_node_alarms, local.leader_node_alarms)
  all_alarms      = merge(local.combined_alarms...)

  cluster_identifier = var.redshift_cluster.cluster_identifier
}

resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = local.all_alarms

  alarm_name = join(
    " ",
    compact([
      "Redshift cluster",
      local.cluster_identifier,
      each.value["node"],
      each.value["metric_description"],
      each.value["level"] == "high" ? "Very" : null,
      each.value["directionality"] == "high" ? "High" : "Low"
    ])
  )
  alarm_description = "${local.cluster_identifier} ${each.value["node"]} ${each.value["metric_description"]} is ${each.value["directionality"] == "high" ? "above" : "below"} ${each.value["value"]}${try(each.value["metric_postfix"], "")}"

  metric_name = each.value["metric_name"]
  namespace   = "AWS/Redshift"

  dimensions = {
    ClusterIdentifier = local.cluster_identifier,
    NodeID            = title(lower(each.value["node"]))
  }

  comparison_operator = each.value["directionality"] == "high" ? "GreaterThanOrEqualToThreshold" : "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "300"
  threshold           = each.value["value"]

  alarm_actions = each.value["level"] == "high" ? var.high_priority_alarm : var.low_priority_alarm
  ok_actions    = each.value["level"] == "high" ? var.high_priority_alarm : var.low_priority_alarm

  tags = var.tags
}
