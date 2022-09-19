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

deploy_production: build_and_push deploy_cloud_run

deploy_cloud_run:
	gcloud run deploy rails-cloud-spanner \
	--platform managed \
	--region ${REGION} \
	--image gcr.io/${PROJECT_ID}/rails-cloud-spanner \
	--set-env-vars=PROJECT_ID=${PROJECT_ID},SPANNER_INSTANCE=trial-1,RAILS_ENV=production \
	--port 3000 \
	--concurrency=5 \
	--max-instances=10 \
	--allow-unauthenticated

build_and_push:
	gcloud builds submit --config cloudbuild.yaml

create_instance_production:
	gcloud spanner instances create trial-1 --config=regional-${REGION} --instance-type=free-instance --description="traial-1"
