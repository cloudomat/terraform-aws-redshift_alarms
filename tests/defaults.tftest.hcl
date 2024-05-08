mock_provider "aws" {}

variables {
  redshift_cluster = {
    cluster_identifier = "test-001",
    number_of_nodes    = 1
  }
  low_priority_alarm  = ["arn:aws:sns:us-east-1:111111111111:alerts_low"]
  high_priority_alarm = ["arn:aws:sns:us-east-1:111111111111:alerts_high"]
}

run "defaults" {
  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_metric_alarm.alarms)) == 6
    error_message = <<-EOM
    Did not create all expected alarms.
    Got ${join(", ", keys(aws_cloudwatch_metric_alarm.alarms))}
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].threshold == 60
    error_message = <<-EOM
    Incorrect alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_cpu_utilization"].threshold}, expected 60
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].threshold == 90
    error_message = <<-EOM
    Incorrect alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_cpu_utilization"].threshold}, expected 90
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_percentage_disk_space_used"].threshold == 70
    error_message = <<-EOM
    Incorrect alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_low_compute_percentage_disk_space_used"].threshold}, expected 70
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_percentage_disk_space_used"].threshold == 90
    error_message = <<-EOM
    Incorrect alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["COMPUTE-0_high_compute_percentage_disk_space_used"].threshold}, expected 90
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].threshold == 20
    error_message = <<-EOM
    Incorrect alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["LEADER_low_leader_cpu_utilization"].threshold}, expected 20
    EOM
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].threshold == 80
    error_message = <<-EOM
    Incorrect alarm threshold.
    Got ${aws_cloudwatch_metric_alarm.alarms["LEADER_high_leader_cpu_utilization"].threshold}, expected 80
    EOM
  }
}
