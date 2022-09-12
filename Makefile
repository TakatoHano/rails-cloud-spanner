default: up

build_up: build up

up: migrate
	docker compose up -d spanner web_app

init: create_instance build migrate

migrate:
	docker compose run --rm web_app bundle exec rails db:migrate

create_instance:
	docker compose run --rm create_instance

create_db:
	docker compose run --rm web_app bundle exec rails db:create

build:
	docker compose build
