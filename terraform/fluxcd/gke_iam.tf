resource "google_service_account" "secret_sa" {
  account_id   = var.secret_sa
  display_name = "secret store CSI driver SA"
}
# gcloud secrets add-iam-policy-binding bq-readonly-key --member=serviceAccount:readwrite-secrets@{PROJ}.iam.gserviceaccount.com --role='roles/secretmanager.secretAccessor'
data "google_iam_policy" "secret_manager" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      "serviceAccount:${var.secret_sa}@${var.project_id}.iam.gserviceaccount.com",
    ]
  }
}