mock_provider "aws" {}

variables {
  redshift_cluster = {
    cluster_identifier = "test-001",
    cluster_nodes      = [{ node_role = "LEADER" }, { node_role = "COMPUTE-0" }, { node_role = "COMPUTE-1" }]
  }
  low_priority_alarm                         = ["arn:aws:sns:us-east-1:111111111111:alerts_low"]
  high_priority_alarm                        = ["arn:aws:sns:us-east-1:111111111111:alerts_high"]
  compute_cpu_utilization_high_threshold     = null
  compute_cpu_utilization_vhigh_threshold    = null
  leader_cpu_utilization_high_threshold      = null
  leader_cpu_utilization_vhigh_threshold     = null
  percentage_disk_space_used_high_threshold  = null
  percentage_disk_space_used_vhigh_threshold = null

  network_packets_per_second_allowance_exceeded_vhigh_threshold = null
}

run "no_alarms" {
  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 0
    error_message = <<-EOM
    Unexpected alarms were created.
    Got ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}, expected none.
    EOM
  }
}

run "alarms" {
  variables {
    compute_cpu_utilization_high_threshold  = 10
    compute_cpu_utilization_vhigh_threshold = 20
    leader_cpu_utilization_high_threshold   = 5
    leader_cpu_utilization_vhigh_threshold  = 7
  }

  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 6
    error_message = <<-EOM
    Did not create all expected alarms.
    Got ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  # COMPUTE-0 low
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].alarm_name == "Redshift cluster ${var.redshift_cluster.cluster_identifier} COMPUTE-0 CPU Utilization High"
    error_message = <<-EOM
    Incorrect low priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].alarm_name} expected Redshift cluster ${var.redshift_cluster.cluster_identifier} COMPUTE-0 CPU Utilization High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].alarm_description == "${var.redshift_cluster.cluster_identifier} COMPUTE-0 CPU Utilization is above ${var.compute_cpu_utilization_high_threshold}%"
    error_message = <<-EOM
    Incorrect low priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].alarm_description} expected ${var.redshift_cluster.cluster_identifier} COMPUTE-0 CPU Utilization is above ${var.compute_cpu_utilization_high_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].threshold == var.compute_cpu_utilization_high_threshold
    error_message = <<-EOM
    Incorrect low priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].threshold}, expected ${var.compute_cpu_utilization_high_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].alarm_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].alarm_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].ok_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].ok_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  # COMPUTE-1 low
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_low_compute_cpu_utilization"].alarm_name == "Redshift cluster ${var.redshift_cluster.cluster_identifier} COMPUTE-1 CPU Utilization High"
    error_message = <<-EOM
    Incorrect low priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_low_compute_cpu_utilization"].alarm_name} expected Redshift cluster ${var.redshift_cluster.cluster_identifier} COMPUTE-1 CPU Utilization High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_low_compute_cpu_utilization"].alarm_description == "${var.redshift_cluster.cluster_identifier} COMPUTE-1 CPU Utilization is above ${var.compute_cpu_utilization_high_threshold}%"
    error_message = <<-EOM
    Incorrect low priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_low_compute_cpu_utilization"].alarm_description} expected ${var.redshift_cluster.cluster_identifier} COMPUTE-1 CPU Utilization is above ${var.compute_cpu_utilization_high_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_low_compute_cpu_utilization"].threshold == var.compute_cpu_utilization_high_threshold
    error_message = <<-EOM
    Incorrect low priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_low_compute_cpu_utilization"].threshold}, expected ${var.compute_cpu_utilization_high_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_low_compute_cpu_utilization"].alarm_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_low_compute_cpu_utilization"].alarm_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_low_compute_cpu_utilization"].ok_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_low_compute_cpu_utilization"].ok_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  # LEADER low
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].alarm_name == "Redshift cluster ${var.redshift_cluster.cluster_identifier} LEADER CPU Utilization High"
    error_message = <<-EOM
    Incorrect low priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].alarm_name} expected Redshift cluster ${var.redshift_cluster.cluster_identifier} LEADER CPU Utilization High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].alarm_description == "${var.redshift_cluster.cluster_identifier} LEADER CPU Utilization is above ${var.leader_cpu_utilization_high_threshold}%"
    error_message = <<-EOM
    Incorrect low priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].alarm_description} expected ${var.redshift_cluster.cluster_identifier} LEADER CPU Utilization is above ${var.leader_cpu_utilization_high_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].threshold == var.leader_cpu_utilization_high_threshold
    error_message = <<-EOM
    Incorrect low priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].threshold}, expected ${var.leader_cpu_utilization_high_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].alarm_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].alarm_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].ok_actions == toset(var.low_priority_alarm)
    error_message = <<-EOM
    Incorrect low priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].ok_actions)}, expected ${join(", ", var.low_priority_alarm)}
    EOM
  }

  # COMPUTE-0 high
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].alarm_name == "Redshift cluster ${var.redshift_cluster.cluster_identifier} COMPUTE-0 CPU Utilization Very High"
    error_message = <<-EOM
    Incorrect high priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].alarm_name} expected Redshift cluster ${var.redshift_cluster.cluster_identifier} COMPUTE-0 CPU Utilization Very High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].alarm_description == "${var.redshift_cluster.cluster_identifier} COMPUTE-0 CPU Utilization is above ${var.compute_cpu_utilization_vhigh_threshold}%"
    error_message = <<-EOM
    Incorrect high priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].alarm_description} expected ${var.redshift_cluster.cluster_identifier} COMPUTE-0 CPU Utilization is above ${var.compute_cpu_utilization_vhigh_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].threshold == var.compute_cpu_utilization_vhigh_threshold
    error_message = <<-EOM
    Incorrect high priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].threshold}, expected ${var.compute_cpu_utilization_vhigh_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].alarm_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].alarm_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].ok_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].ok_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  # COMPUTE-1 high
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_high_compute_cpu_utilization"].alarm_name == "Redshift cluster ${var.redshift_cluster.cluster_identifier} COMPUTE-1 CPU Utilization Very High"
    error_message = <<-EOM
    Incorrect high priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_high_compute_cpu_utilization"].alarm_name} expected Redshift cluster ${var.redshift_cluster.cluster_identifier} COMPUTE-1 CPU Utilization Very High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_high_compute_cpu_utilization"].alarm_description == "${var.redshift_cluster.cluster_identifier} COMPUTE-1 CPU Utilization is above ${var.compute_cpu_utilization_vhigh_threshold}%"
    error_message = <<-EOM
    Incorrect high priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_high_compute_cpu_utilization"].alarm_description} expected ${var.redshift_cluster.cluster_identifier} COMPUTE-1 CPU Utilization is above ${var.compute_cpu_utilization_vhigh_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_high_compute_cpu_utilization"].threshold == var.compute_cpu_utilization_vhigh_threshold
    error_message = <<-EOM
    Incorrect high priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_high_compute_cpu_utilization"].threshold}, expected ${var.compute_cpu_utilization_vhigh_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_high_compute_cpu_utilization"].alarm_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_high_compute_cpu_utilization"].alarm_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_high_compute_cpu_utilization"].ok_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["COMPUTE-1_high_compute_cpu_utilization"].ok_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  # LEADER high
  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].alarm_name == "Redshift cluster ${var.redshift_cluster.cluster_identifier} LEADER CPU Utilization Very High"
    error_message = <<-EOM
    Incorrect high priority alarm name.
    Got ${aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].alarm_name} expected Redshift cluster ${var.redshift_cluster.cluster_identifier} LEADER CPU Utilization Very High
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].alarm_description == "${var.redshift_cluster.cluster_identifier} LEADER CPU Utilization is above ${var.leader_cpu_utilization_vhigh_threshold}%"
    error_message = <<-EOM
    Incorrect high priority alarm description.
    Got ${aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].alarm_description} expected ${var.redshift_cluster.cluster_identifier} LEADER CPU Utilization is above ${var.leader_cpu_utilization_vhigh_threshold}%
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].threshold == var.leader_cpu_utilization_vhigh_threshold
    error_message = <<-EOM
    Incorrect high priority alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].threshold}, expected ${var.leader_cpu_utilization_vhigh_threshold}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].alarm_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority alarm actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].alarm_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].ok_actions == toset(var.high_priority_alarm)
    error_message = <<-EOM
    Incorrect high priority ok actions.
    Got ${join(", ", aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].ok_actions)}, expected ${join(", ", var.high_priority_alarm)}
    EOM
  }
}
