# Georgia Travel Guide — Backend

Microservice backend for the tourist guide app, exactly as described in the thesis:
an **API Gateway** (REST) that talks to five microservices over **gRPC**, backed by **PostgreSQL**.

```
Flutter ──REST──▶ API Gateway ──gRPC──▶ Auth (.NET)      ┐
                              ├──gRPC──▶ City (Go)        │
                              ├──gRPC──▶ Places (Go)      ├──▶ PostgreSQL
                              ├──gRPC──▶ Route (Go)       │
                              └──gRPC──▶ Favorite (Go)    ┘
```

| Component | Language | Port | Responsibility |
|---|---|---|---|
| gateway  | Go      | 8080 | REST API, JWT verification, routing to gRPC |
| auth     | .NET    | 5001 | register, login, refresh, profile, JWT signing |
| city     | Go      | 5002 | cities: list, search, filter, detail |
| places   | Go      | 5003 | attractions, restaurants, hotels |
| route    | Go      | 5004 | tourist routes |
| favorite | Go      | 5005 | user favorites |
| postgres | —       | 5432 | data |
| adminer  | —       | 8081 | web DB browser (optional) |

## Run it

Only **Docker** is required. Everything else (Go build, proto generation, .NET build,
schema + seed load) happens inside the containers.

```bash
cp .env.example .env        # optional: change JWT_SECRET
docker compose up -d --build
```

First boot: Postgres auto-applies `db/migrations/001_init.sql` and `db/seed.sql`.

Check it:

```bash
curl http://localhost:8080/health          # {"status":"ok"}
curl http://localhost:8080/api/cities      # seeded Georgian cities
```

Browse the database at http://localhost:8081 (system `PostgreSQL`, server `postgres`,
user/pass/db all `guide`).

Stop: `docker compose down`  ·  wipe data too: `make clean`.

## Quick smoke test

```bash
# register -> returns access + refresh tokens
curl -s -X POST http://localhost:8080/api/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"me@example.com","password":"secret1","full_name":"ჩემი სახელი"}'

# login
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"me@example.com","password":"secret1"}' | python3 -c 'import sys,json;print(json.load(sys.stdin)["access_token"])')

# call a protected endpoint
curl -s http://localhost:8080/api/users/me -H "Authorization: Bearer $TOKEN"

# add a favorite
curl -s -X POST http://localhost:8080/api/favorites -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' -d '{"entity_type":"city","entity_id":1}'
```

## REST API

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | /api/auth/register | – | create account, returns tokens |
| POST | /api/auth/login | – | login, returns tokens |
| POST | /api/auth/refresh | – | new access token from refresh token |
| GET  | /api/users/me | ✓ | current profile |
| PUT  | /api/users/me | ✓ | update profile |
| GET  | /api/cities | – | list (`?page=&page_size=&region=&search=`) |
| GET  | /api/cities/{id} | – | city detail |
| GET  | /api/cities/{id}/attractions | – | attractions |
| GET  | /api/cities/{id}/restaurants | – | restaurants |
| GET  | /api/cities/{id}/hotels | – | hotels |
| GET  | /api/routes | – | routes (`?city_id=`) |
| GET  | /api/routes/{id} | – | route detail |
| GET  | /api/favorites | ✓ | list favorites |
| POST | /api/favorites | ✓ | add favorite `{entity_type, entity_id}` |
| DELETE | /api/favorites | ✓ | remove favorite `{entity_type, entity_id}` |

## Layout

```
proto/                 gRPC contracts (.proto)
cmd/<svc>/main.go       entrypoints for each Go binary
internal/<svc>/         gRPC server + DB queries per service
internal/gateway/       REST router, gRPC clients, JWT middleware
internal/{config,db,jwt}  shared helpers
internal/pb/            generated gRPC stubs (created at build; git-ignored)
services/auth/          the .NET auth service
db/migrations, db/seed  SQL schema and sample data
Dockerfile.go           multi-stage build for all Go binaries
docker-compose.yml      full local stack
```

## Notes

- Auth signs HS256 JWTs; the gateway verifies them with the **same `JWT_SECRET`**.
  Access tokens last 15 min, refresh tokens 30 days.
- To regenerate Go stubs locally (outside Docker) you need `protoc` plus
  `protoc-gen-go` and `protoc-gen-go-grpc`, then run `make proto`.
- This is the backend scaffold. The mobile client connects to `http://10.0.2.2:8080`
  from the Android emulator (see the thesis run instructions).
