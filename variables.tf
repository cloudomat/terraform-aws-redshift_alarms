# Copyright 2024 Teak.io, Inc.
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

variable "redshift_cluster" {
  type = object({
    cluster_identifier = string
    number_of_nodes    = number
  })
  description = "The redshift cluster to alarm."
}

variable "low_priority_alarm" {
  type        = list(string)
  description = "The actions to trigger on a low priority alarm"
}

variable "high_priority_alarm" {
  type        = list(string)
  description = "The actions to trigger on a high priority alarm"
}

variable "compute_cpu_utilization_high_threshold" {
  type        = number
  default     = 60
  description = "How much cpu can be consumed until a low priority alert is triggered? Set to null to disable."
}

variable "compute_cpu_utilization_vhigh_threshold" {
  type        = number
  default     = 90
  description = "How much cpu can be consumed until a high priority alert is triggered? Set to null to disable."
}

variable "leader_cpu_utilization_high_threshold" {
  type        = number
  default     = 20
  description = "How much cpu can be consumed until a low priority alert is triggered? Set to null to disable."
}

variable "leader_cpu_utilization_vhigh_threshold" {
  type        = number
  default     = 80
  description = "How much cpu can be consumed until a high priority alert is triggered? Set to null to disable."
}

variable "percentage_disk_space_used_high_threshold" {
  type        = number
  default     = 70
  description = "How much disk space can be consumed until a low priority alert is triggered? Set to null to disable."
}

variable "percentage_disk_space_used_vhigh_threshold" {
  type        = number
  default     = 90
  description = "How much disk space can be consumed until a high priority alert is triggered? Set to null to disable."
}

variable "tags" {
  type    = map(any)
  default = {}
}
