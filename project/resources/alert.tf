locals {
warning_alert_cluster = {
    pro_slack_post_message_document = <<-EOF
      Cloud Monitoringにてcluster-pro、Cronjob,Jobに関するWARNINGを検知しました。
      詳細の確認をお願いします。
      https://console.cloud.google.com/logs/query;query=resource.type%3D%22k8s_cluster%22%20severity%3E%3DWARNING%0Aresource.type%3D%22k8s_cluster%22%20resource.labels.location%3D%22asia-east1%22%0Aresource.labels.cluster_name%3D%22cluster-stg-aa-common01%22%0AjsonPayload.involvedObject.kind:%2528%22CronJob%22%20OR%20%22Job%22%2529;timeRange=PT3H;summaryFields=:false:32:beginning:false?project=learngcp-335008
    EOF
    stg_slack_post_message_document = <<-EOF
      Cloud Monitoringにてcluster-stg、Cronjob,Jobに関するWARNINGを検知しました。
      詳細の確認をお願いします。
    EOF
 }
}

data "google_monitoring_notification_channel" "cluster_warning_alert_channel" {
  display_name = "warning-alert-log-detection"
}

# Cluster Cronjob,Batch異常検知用
resource "google_monitoring_alert_policy" "warning_batch_log_alert_cluster" {
  project      = var.project_id
  combiner     = "OR"
  display_name = "Cronjob＆Batch WARNING Alert cluster-${var.env}"
  # Cronjob,Batch関連のWARNINGの発生を検知されたら通知する
  conditions {
    display_name = google_logging_metric.common_cluster_batch_warning_log.name

    condition_threshold {
      filter = <<-EOF
          metric.type="logging.googleapis.com/user/${google_logging_metric.common_cluster_batch_warning_log.name}"
          resource.type="k8s_cluster"
      EOF
      comparison      = "COMPARISON_GT"
      duration        = "0s"
      threshold_value = "0" // 1件でも検知したら作動させる

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_COUNT"
        cross_series_reducer = "REDUCE_COUNT"
      }

      trigger {
        count = 1
      }
    }
  }

  documentation {
    mime_type = "text/markdown"
    content = var.env == "pro" ? local.warning_alert_cluster.pro_slack_post_message_document : local.warning_alert_cluster.stg_slack_post_message_document
  }

  notification_channels = [
    data.google_monitoring_notification_channel.cluster_warning_alert_channel.name #slackチャンネル名：warning-alert-log-detection
  ]
}
