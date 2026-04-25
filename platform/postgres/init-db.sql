SELECT 'CREATE DATABASE authentik' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'authentik')\gexec
SELECT 'CREATE DATABASE nocobase' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'nocobase')\gexec

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authentik') THEN
        CREATE ROLE authentik WITH LOGIN PASSWORD 'AuthentikPass123!';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'nocobase') THEN
        CREATE ROLE nocobase WITH LOGIN PASSWORD 'NocoBasePass123!';
    END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE authentik TO authentik;
GRANT ALL PRIVILEGES ON DATABASE nocobase TO nocobase;

ALTER DATABASE authentik OWNER TO authentik;
ALTER DATABASE nocobase OWNER TO nocobase;

\c authentik
GRANT ALL ON SCHEMA public TO authentik;

\c nocobase
GRANT ALL ON SCHEMA public TO nocobase;
