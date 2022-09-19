# Activate These APIs!
# cloud spanner
# cloud run
# cloud build
# secret manager
# kms 

# secret: rails-master-key encrypt by kms
# Step:1 create kms
resource "google_kms_key_ring" "key_ring" {
  project  = data.google_project.default.project_id
  name     = "key-ring"
  location = "asia-northeast1"
}

resource "google_kms_crypto_key" "crypto_key" {
  name     = "crypto-key"
  key_ring = google_kms_key_ring.key_ring.id
}

# Step:2 ecncrypt rails_master_key, and set ciphertext
data "google_kms_secret" "rails_master_key" {
  crypto_key = google_kms_crypto_key.crypto_key.id
  # Must Replace!: echo -n $RAILS_MASTER_KEY | gcloud kms encrypt --location asia-northeast1 --keyring key-ring --key crypto-key --plaintext-file - --ciphertext-file - | base64
  ciphertext = "CiQAZ4zH06xt5lU6j2Q4QRsojbdH1RCwg9KJLJt3blR+2noYcbYSSQDLeR9jDCTyztjOnaxTLsvcBjP82GLLCIRWfK5RtzAYt/x4IySg6Awot82dFLuOrYi3/zEk6W8rR+iEnrddxhPQDbJAlqAa3uU="
}

resource "google_secret_manager_secret" "rails_master_key" {
  project   = data.google_project.default.project_id
  secret_id = "rails-master-key"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "rails_master_key" {
  secret      = google_secret_manager_secret.rails_master_key.id
  secret_data = data.google_kms_secret.rails_master_key.plaintext
}

# Allow Access for Cloud Run's Service Agent
resource "google_project_iam_member" "cloud_run_sa_spanner_access" {
  project = data.google_project.default.project_id
  role    = "roles/spanner.databaseUser"
  member  = "serviceAccount:${data.google_project.default.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "cloud_run_sa_secret_access" {
  project = data.google_project.default.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${data.google_project.default.number}-compute@developer.gserviceaccount.com"
}

# Allow Access for Cloud Build's Service Agent
resource "google_project_iam_member" "cloud_build_sa_spanner_access" {
  project = data.google_project.default.project_id
  role    = "roles/spanner.databaseUser"
  member  = "serviceAccount:${data.google_project.default.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloud_build_sa_secret_access" {
  project = data.google_project.default.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${data.google_project.default.number}@cloudbuild.gserviceaccount.com"
}

# Spanner
data "google_spanner_instance" "trial_1" {
  name = "trial-1"
}

resource "google_spanner_database" "spanner_test" {
  instance                 = data.google_spanner_instance.trial_1.name
  name                     = "spanner_test"
  version_retention_period = "3d"
  deletion_protection      = false
}
