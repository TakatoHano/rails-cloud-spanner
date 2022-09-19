# README

Sample rails app use ruby-spanner-activerecord

# Versions
## -   Ruby version: 3.1.2 (Rails 7.0.4)
## - Terraform version: 1.2.9 (google 4.36.0)

# For Developper
## Set Env
```sh
# for terraforn and gcloud cli
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_CREDENTIAL
export GOOGLE_PROJECT=YOUR_PROJECT
export PROJECT_ID=$GOOGLE_PROJECT
# spanner free-trail instance support region
# us-east5, europe-west3, asia-south2, asia-southeast2
export REGION=us-east5
export RAILS_MASTER_KEY=YOUR_MASTER_KEY
```

## Database creation & initialization: `make init`

## Start Service(local): `make (up) `

---
# Create GCP Recources
## Create Spanner free-trail-instance (run once)
```sh
make create_instance_production
```
## Create resource by Terraform
### Run on infra dir
```sh
cd infra && terraform init
```

### 1. Comment out google_kms_secret, google_secret_manager_secret, and google_secret_manager_secret_version
```hcl
# comment out
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
```

### 2. Create resource exclude secret
```sh
terraform plan
terraform apply -auto-approve
```
### 3. Encrypt your rails master key 
```sh
echo -n $RAILS_MASTER_KEY | gcloud kms encrypt --location asia-northeast1 --keyring key-ring --key crypto-key --plaintext-file - --ciphertext-file - | base64
```
### 4. Set google_kms_secret, and uncomment
```hcl
data "google_kms_secret" "rails_master_key" {
  crypto_key = google_kms_crypto_key.crypto_key.id
  # Must Replace!: echo -n $RAILS_MASTER_KEY | gcloud kms encrypt --location asia-northeast1 --keyring key-ring --key crypto-key --plaintext-file - --ciphertext-file - | base64
  ciphertext = ### Here! ###
}
```
### 5. Create secret
```sh
terraform plan
terraform apply -auto-approve
```

## Deploy App to GCP Cloud Run
```sh
make deploy_production
```
