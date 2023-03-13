resource "google_artifact_registry_repository" "my-repo" {
  location      = "europe-west4"
  repository_id = "cp-task"
  description   = "docker image repo"
  format        = "DOCKER"
}