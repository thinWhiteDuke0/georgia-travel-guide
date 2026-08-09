-- Georgia Travel Guide — schema
CREATE TABLE IF NOT EXISTS users (
    id            BIGSERIAL PRIMARY KEY,
    email         VARCHAR(160) NOT NULL UNIQUE,
    password_hash TEXT         NOT NULL,
    full_name     VARCHAR(160) NOT NULL DEFAULT '',
    avatar_url    TEXT         NOT NULL DEFAULT '',
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS cities (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(160)     NOT NULL,
    region      VARCHAR(160)     NOT NULL DEFAULT '',
    description TEXT             NOT NULL DEFAULT '',
    image_url   TEXT             NOT NULL DEFAULT '',
    latitude    DOUBLE PRECISION NOT NULL DEFAULT 0,
    longitude   DOUBLE PRECISION NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ      NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_cities_name   ON cities (lower(name));
CREATE INDEX IF NOT EXISTS idx_cities_region ON cities (region);

CREATE TABLE IF NOT EXISTS attractions (
    id          BIGSERIAL PRIMARY KEY,
    city_id     BIGINT NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
    name        VARCHAR(200)     NOT NULL,
    category    VARCHAR(80)      NOT NULL DEFAULT '',
    description TEXT             NOT NULL DEFAULT '',
    latitude    DOUBLE PRECISION NOT NULL DEFAULT 0,
    longitude   DOUBLE PRECISION NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_attractions_city ON attractions (city_id);

CREATE TABLE IF NOT EXISTS restaurants (
    id          BIGSERIAL PRIMARY KEY,
    city_id     BIGINT NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
    name        VARCHAR(200)     NOT NULL,
    cuisine     VARCHAR(80)      NOT NULL DEFAULT '',
    price_level INT              NOT NULL DEFAULT 1,
    address     TEXT             NOT NULL DEFAULT '',
    latitude    DOUBLE PRECISION NOT NULL DEFAULT 0,
    longitude   DOUBLE PRECISION NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_restaurants_city ON restaurants (city_id);

CREATE TABLE IF NOT EXISTS hotels (
    id        BIGSERIAL PRIMARY KEY,
    city_id   BIGINT NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
    name      VARCHAR(200)     NOT NULL,
    stars     INT              NOT NULL DEFAULT 0,
    address   TEXT             NOT NULL DEFAULT '',
    latitude  DOUBLE PRECISION NOT NULL DEFAULT 0,
    longitude DOUBLE PRECISION NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_hotels_city ON hotels (city_id);

CREATE TABLE IF NOT EXISTS routes (
    id             BIGSERIAL PRIMARY KEY,
    city_id        BIGINT NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
    title          VARCHAR(200)     NOT NULL,
    description    TEXT             NOT NULL DEFAULT '',
    duration_hours DOUBLE PRECISION NOT NULL DEFAULT 0,
    difficulty     VARCHAR(40)      NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS idx_routes_city ON routes (city_id);

CREATE TABLE IF NOT EXISTS favorites (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entity_type VARCHAR(30) NOT NULL,
    entity_id   BIGINT      NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, entity_type, entity_id)
);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites (user_id, entity_type);
