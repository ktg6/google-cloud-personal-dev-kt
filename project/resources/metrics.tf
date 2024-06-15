resource "google_logging_metric" "cluster_batch_warning_log" {
  name     = "cluster-${var.env}-batch_warning_log"
  project  = var.project_id
  filter   = <<-EOF
    resource.type="k8s_cluster"
    resource.labels.location="${var.region}"
    resource.labels.cluster_name="cluster-${var.env}-aa-common01"
    jsonPayload.involvedObject.kind:("CronJob" OR "Job")
    severity>=WARNING
  EOF

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}
