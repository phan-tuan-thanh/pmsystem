SELECT 'CREATE DATABASE authentik' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'authentik')\gexec
SELECT 'CREATE DATABASE plane_ce' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'plane_ce')\gexec
SELECT 'CREATE DATABASE plane_ai' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'plane_ai')\gexec

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authentik') THEN
        CREATE ROLE authentik WITH LOGIN PASSWORD 'AuthentikPass123!';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'plane_ce') THEN
        CREATE ROLE plane_ce WITH LOGIN PASSWORD 'PlanePass123!';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'plane_ai') THEN
        CREATE ROLE plane_ai WITH LOGIN PASSWORD 'PlaneAIPass123!';
    END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE authentik TO authentik;
GRANT ALL PRIVILEGES ON DATABASE plane_ce TO plane_ce;
GRANT ALL PRIVILEGES ON DATABASE plane_ai TO plane_ai;

ALTER DATABASE authentik OWNER TO authentik;
ALTER DATABASE plane_ce OWNER TO plane_ce;
ALTER DATABASE plane_ai OWNER TO plane_ai;

\c authentik
ALTER SCHEMA public OWNER TO authentik;
GRANT ALL ON SCHEMA public TO authentik;

\c plane_ce
ALTER SCHEMA public OWNER TO plane_ce;
GRANT ALL ON SCHEMA public TO plane_ce;

\c plane_ai
ALTER SCHEMA public OWNER TO plane_ai;
GRANT ALL ON SCHEMA public TO plane_ai;
