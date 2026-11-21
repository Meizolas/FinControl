CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), oidc_sub text UNIQUE, name text NOT NULL,
  email text UNIQUE NOT NULL, role text NOT NULL CHECK (role IN ('assessor','gestor','compliance','direcao')),
  active boolean NOT NULL DEFAULT true, mfa_enabled boolean NOT NULL DEFAULT true, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS resources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), code text UNIQUE NOT NULL, name text NOT NULL, description text NOT NULL
);
CREATE TABLE IF NOT EXISTS access_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), requester_id uuid NOT NULL REFERENCES users(id),
  resource_id uuid NOT NULL REFERENCES resources(id), justification text NOT NULL CHECK (length(justification) BETWEEN 10 AND 500),
  status text NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente','aprovada','negada','revogada','expirada')),
  decided_by uuid REFERENCES users(id), decided_at timestamptz, revoked_by uuid REFERENCES users(id), revoked_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(), expires_at timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS one_pending_request ON access_requests(requester_id,resource_id) WHERE status='pendente';
CREATE TABLE IF NOT EXISTS access_grants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), user_id uuid NOT NULL REFERENCES users(id), resource_id uuid NOT NULL REFERENCES resources(id),
  request_id uuid UNIQUE NOT NULL REFERENCES access_requests(id), granted_at timestamptz NOT NULL DEFAULT now(), revoked_at timestamptz,
  UNIQUE(user_id,resource_id)
);
CREATE OR REPLACE FUNCTION require_approved_request() RETURNS trigger AS $$
DECLARE request_row access_requests%ROWTYPE;
BEGIN
  SELECT * INTO request_row FROM access_requests WHERE id=NEW.request_id;
  IF request_row.status <> 'aprovada' OR request_row.requester_id <> NEW.user_id OR request_row.resource_id <> NEW.resource_id THEN
    RAISE EXCEPTION 'grant requires a matching approved request';
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS access_grant_requires_approval ON access_grants;
CREATE TRIGGER access_grant_requires_approval BEFORE INSERT ON access_grants FOR EACH ROW EXECUTE FUNCTION require_approved_request();
CREATE TABLE IF NOT EXISTS audit_log (
  id bigserial PRIMARY KEY, occurred_at timestamptz NOT NULL DEFAULT now(), actor_id uuid REFERENCES users(id),
  action text NOT NULL, resource text NOT NULL, result text NOT NULL, details jsonb NOT NULL DEFAULT '{}'::jsonb,
  previous_hash text, hash text NOT NULL
);
CREATE OR REPLACE FUNCTION block_audit_mutation() RETURNS trigger AS $$ BEGIN
  RAISE EXCEPTION 'audit_log is append-only';
END; $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS audit_log_append_only ON audit_log;
CREATE TRIGGER audit_log_append_only BEFORE UPDATE OR DELETE ON audit_log FOR EACH ROW EXECUTE FUNCTION block_audit_mutation();
