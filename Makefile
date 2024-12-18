dc-up:
	docker-compose --env-file .env -f infra/local/docker-compose.yaml up --watch

dc-up-build:
	docker-compose --env-file .env -f infra/local/docker-compose.yaml up --build --watch
