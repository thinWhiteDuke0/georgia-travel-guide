
# საქართველოს ტურისტული გზამკვლევი / Georgia Travel Guide

მობილური აპლიკაცია, რომელიც წარმოადგენს საქართველოს ქალაქების ციფრულ ტურისტულ
გზამკვლევს. პროექტი აგებულია მიკროსერვისულ არქიტექტურაზე.

A mobile tourist guide to the cities of Georgia, built on a microservice
backend. Bachelor's thesis project.

https://github.com/user-attachments/assets/38128fd8-870d-46a6-8488-08659dc568b6

---

## არქიტექტურა / Architecture

```
Flutter ──REST──▶ API Gateway ──gRPC──▶ Authentication Service (.NET)  ┐
                              ├──gRPC──▶ City Service     (Go)          │
                              ├──gRPC──▶ Places Service   (Go)          ├──▶ PostgreSQL
                              ├──gRPC──▶ Route Service    (Go)          │
                              └──gRPC──▶ Favorite Service (Go)          ┘
```

| კომპონენტი | ტექნოლოგია | პორტი | დანიშნულება |
|---|---|---|---|
| gateway  | Go      | 8080 | REST API, JWT-ის შემოწმება, მარშრუტიზაცია |
| auth     | .NET 8  | 5001 | რეგისტრაცია, ავტორიზაცია, JWT-ის გენერაცია |
| city     | Go      | 5002 | ქალაქები: სია, ძებნა, ფილტრაცია |
| places   | Go      | 5003 | ღირსშესანიშნაობები, რესტორნები, სასტუმროები |
| route    | Go      | 5004 | ტურისტული მარშრუტები |
| favorite | Go      | 5005 | მომხმარებლის ფავორიტები |
| postgres | —       | 5432 | მონაცემთა ბაზა |
| adminer  | —       | 8081 | ბაზის ვებ-ინტერფეისი |

## ტექნოლოგიები / Tech stack

**Mobile:** Flutter, Dart, Clean Architecture, Riverpod, go_router, Dio, flutter_map
**Backend:** Go, ASP.NET Core, REST API, gRPC (Protocol Buffers), JWT
**Database:** PostgreSQL
**Infra:** Docker, Docker Compose

---

## გაშვება / Getting started

### 1. Backend

საჭიროა მხოლოდ **Docker**. დანარჩენი (Go-ს კომპილაცია, proto-ს გენერაცია,
.NET-ის აწყობა, ბაზის სქემა და საწყისი მონაცემები) კონტეინერებში სრულდება.

```bash
cd backend
cp .env.example .env
docker compose up -d --build
```

შემოწმება:

```bash
curl http://localhost:8080/health      # {"status":"ok"}
curl http://localhost:8080/api/cities  # საწყისი ქალაქები
```

ბაზის დათვალიერება: <http://localhost:8081> — System `PostgreSQL`,
Server `postgres`, მომხმარებელი/პაროლი/ბაზა: `guide`.

გაჩერება: `docker compose down` · მონაცემებთან ერთად: `docker compose down -v`

### 2. Mobile

```bash
cd mobile
flutter create --project-name georgia_travel_guide .   # ერთხელ, პლატფორმის ფაილებისთვის
flutter pub get
```

გაშვება:

```bash
# Android ემულატორი (10.0.2.2 = ჰოსტის localhost)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

# ბრაუზერი
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

**Android-ისთვის** `android/app/src/main/AndroidManifest.xml`-ში დაამატეთ:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application android:usesCleartextTraffic="true" ... >
```

(საჭიროა მხოლოდ ლოკალური `http://` backend-ისთვის)

---

## API

| მეთოდი | მისამართი | ტოკენი | დანიშნულება |
|---|---|---|---|
| POST | `/api/auth/register` | – | რეგისტრაცია |
| POST | `/api/auth/login` | – | ავტორიზაცია |
| POST | `/api/auth/refresh` | – | ტოკენის განახლება |
| GET  | `/api/users/me` | ✓ | პროფილი |
| PUT  | `/api/users/me` | ✓ | პროფილის რედაქტირება |
| GET  | `/api/cities` | – | ქალაქების სია (`?page=&region=&search=`) |
| GET  | `/api/cities/{id}` | – | ქალაქის დეტალები |
| GET  | `/api/cities/{id}/attractions` | – | ღირსშესანიშნაობები |
| GET  | `/api/cities/{id}/restaurants` | – | რესტორნები |
| GET  | `/api/cities/{id}/hotels` | – | სასტუმროები |
| GET  | `/api/routes` | – | მარშრუტები (`?city_id=`) |
| GET  | `/api/routes/{id}` | – | მარშრუტის დეტალები |
| GET  | `/api/favorites` | ✓ | ფავორიტების სია |
| POST | `/api/favorites` | ✓ | ფავორიტში დამატება |
| DELETE | `/api/favorites` | ✓ | ფავორიტიდან ამოღება |

## მონაცემთა ბაზა / Database

ცხრილები: `users`, `cities`, `attractions`, `restaurants`, `hotels`, `routes`,
`favorites`. სქემა: `backend/db/migrations/001_init.sql`, საწყისი მონაცემები:
`backend/db/seed.sql`. ორივე ავტომატურად ისხმება ბაზის პირველი გაშვებისას.

## სტრუქტურა / Repository layout

```
backend/
  proto/            gRPC კონტრაქტები (.proto)
  cmd/<svc>/        თითოეული Go სერვისის entry point
  internal/<svc>/   gRPC სერვერი + SQL მოთხოვნები
  internal/gateway/ REST router, gRPC კლიენტები, JWT middleware
  services/auth/    .NET ავთენტიფიკაციის სერვისი
  db/               სქემა და საწყისი მონაცემები
  docker-compose.yml
mobile/
  lib/core/         კონფიგურაცია, ქსელი, საცავი, თემა, router
  lib/features/     auth, cities, places, routes, favorites, profile, map
                    (თითოეული: data/ + presentation/)
```

## უსაფრთხოება / Security notes

- პაროლები ინახება bcrypt-ით ჰეშირებული სახით.
- წვდომის ტოკენი მოქმედებს 15 წუთი, განახლების ტოკენი 30 დღე.
- `JWT_SECRET` უნდა იყოს **მინიმუმ 32 სიმბოლო** (HS256-ის მოთხოვნა).
  რეპოზიტორიაში მოცემული მნიშვნელობა მხოლოდ სატესტოა — რეალურ გარემოში
  აუცილებლად შეცვალეთ.

## ლიცენზია / License

MIT
