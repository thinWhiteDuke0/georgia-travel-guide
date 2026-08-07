.PHONY: up down build rebuild logs ps proto tidy migrate seed psql clean

up:            ## build + start everything
	docker compose up -d --build

down:          ## stop and remove containers
	docker compose down

build:
	docker compose build

rebuild:
	docker compose build --no-cache

logs:
	docker compose logs -f --tail=100

ps:
	docker compose ps

# Local (non-Docker) Go proto generation. Requires protoc + plugins:
#   go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
#   go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
proto:
	bash scripts/genproto.sh

tidy: proto
	go mod tidy

# Re-apply schema / seed to a RUNNING database (initdb already does this on first boot).
migrate:
	docker compose exec -T postgres psql -U guide -d guide < db/migrations/001_init.sql

seed:
	docker compose exec -T postgres psql -U guide -d guide < db/seed.sql

psql:
	docker compose exec postgres psql -U guide -d guide

clean:
	docker compose down -v
