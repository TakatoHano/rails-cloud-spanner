default: up

build_up: build up

up: migrate
	docker compose up -d spanner web_app

init: create_instance create_db build migrate

migrate:
	docker compose run --rm web_app bundle exec rails db:migrate

create_instance:
	docker compose up -d spanner
	docker compose run --rm create_instance

create_db:
	docker compose run --rm web_app bundle exec rails db:create

build:
	docker compose build

deploy_production: build_and_push migrate_production deploy_cloud_run

deploy_cloud_run:
	gcloud beta run deploy rails-cloud-spanner \
	--platform managed \
	--region ${REGION} \
	--image gcr.io/${PROJECT_ID}/rails-cloud-spanner \
	--set-env-vars=PROJECT_ID=${PROJECT_ID},SPANNER_INSTANCE=trial-1,RAILS_ENV=production \
	--set-secrets=RAILS_MASTER_KEY=rails-master-key:latest \
	--port 3000 \
	--concurrency=5 \
	--max-instances=10 \
	--cpu-boost \
	--allow-unauthenticated

migrate_production:
	gcloud beta run jobs update rails-spanner-migrate \
	--image gcr.io/${PROJECT_ID}/rails-cloud-spanner \
	--command=bundle,exec,rails,db:migrate \
	--region ${REGION} \
	--set-env-vars=PROJECT_ID=${PROJECT_ID},SPANNER_INSTANCE=trial-1,RAILS_ENV=production \
	--set-secrets=RAILS_MASTER_KEY=rails-master-key:latest 
	gcloud beta run jobs execute rails-spanner-migrate --region ${REGION} --wait

build_and_push:
	gcloud builds submit --config cloudbuild.yaml

# run once only!
create_instance_production:
	gcloud spanner instances create trial-1 --config=regional-${REGION} --instance-type=free-instance --description="traial-1"

# run once only! image is gcp default.
create_migrate_production_job:
	gcloud beta run jobs create rails-spanner-migrate \
	--image us-docker.pkg.dev/cloudrun/container/job:latest\
	--region ${REGION}
