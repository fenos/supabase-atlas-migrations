-- Add new schema named "auth"
CREATE SCHEMA "auth";
-- Create "schema_migrations" table
CREATE TABLE "auth"."schema_migrations" ("version" character varying(255) NOT NULL, PRIMARY KEY ("version"));
-- Set comment to table: "schema_migrations"
COMMENT ON TABLE "auth"."schema_migrations" IS 'Auth: Manages updates to the auth system.';
-- Create enum type "code_challenge_method"
CREATE TYPE "auth"."code_challenge_method" AS ENUM ('s256', 'plain');
-- Create "flow_state" table
CREATE TABLE "auth"."flow_state" ("id" uuid NOT NULL, "user_id" uuid NULL, "auth_code" text NOT NULL, "code_challenge_method" "auth"."code_challenge_method" NOT NULL, "code_challenge" text NOT NULL, "provider_type" text NOT NULL, "provider_access_token" text NULL, "provider_refresh_token" text NULL, "created_at" timestamptz NULL, "updated_at" timestamptz NULL, "authentication_method" text NOT NULL, PRIMARY KEY ("id"));
-- Create index "idx_auth_code" to table: "flow_state"
CREATE INDEX "idx_auth_code" ON "auth"."flow_state" ("auth_code");
-- Create index "idx_user_id_auth_method" to table: "flow_state"
CREATE INDEX "idx_user_id_auth_method" ON "auth"."flow_state" ("user_id", "authentication_method");
-- Set comment to table: "flow_state"
COMMENT ON TABLE "auth"."flow_state" IS 'stores metadata for pkce logins';
-- Create "users" table
CREATE TABLE "auth"."users" ("instance_id" uuid NULL, "id" uuid NOT NULL, "aud" character varying(255) NULL, "role" character varying(255) NULL, "email" character varying(255) NULL, "encrypted_password" character varying(255) NULL, "email_confirmed_at" timestamptz NULL, "invited_at" timestamptz NULL, "confirmation_token" character varying(255) NULL, "confirmation_sent_at" timestamptz NULL, "recovery_token" character varying(255) NULL, "recovery_sent_at" timestamptz NULL, "email_change_token_new" character varying(255) NULL, "email_change" character varying(255) NULL, "email_change_sent_at" timestamptz NULL, "last_sign_in_at" timestamptz NULL, "raw_app_meta_data" jsonb NULL, "raw_user_meta_data" jsonb NULL, "is_super_admin" boolean NULL, "created_at" timestamptz NULL, "updated_at" timestamptz NULL, "phone" text NULL DEFAULT NULL::character varying, "phone_confirmed_at" timestamptz NULL, "phone_change" text NULL DEFAULT '', "phone_change_token" character varying(255) NULL DEFAULT '', "phone_change_sent_at" timestamptz NULL, "confirmed_at" timestamptz NULL GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED, "email_change_token_current" character varying(255) NULL DEFAULT '', "email_change_confirm_status" smallint NULL DEFAULT 0, "banned_until" timestamptz NULL, "reauthentication_token" character varying(255) NULL DEFAULT '', "reauthentication_sent_at" timestamptz NULL, "is_sso_user" boolean NOT NULL DEFAULT false, "deleted_at" timestamptz NULL, PRIMARY KEY ("id"), CONSTRAINT "users_email_change_confirm_status_check" CHECK ((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)));
-- Create index "confirmation_token_idx" to table: "users"
CREATE UNIQUE INDEX "confirmation_token_idx" ON "auth"."users" ("confirmation_token") WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);
-- Create index "email_change_token_current_idx" to table: "users"
CREATE UNIQUE INDEX "email_change_token_current_idx" ON "auth"."users" ("email_change_token_current") WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);
-- Create index "email_change_token_new_idx" to table: "users"
CREATE UNIQUE INDEX "email_change_token_new_idx" ON "auth"."users" ("email_change_token_new") WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);
-- Create index "reauthentication_token_idx" to table: "users"
CREATE UNIQUE INDEX "reauthentication_token_idx" ON "auth"."users" ("reauthentication_token") WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);
-- Create index "recovery_token_idx" to table: "users"
CREATE UNIQUE INDEX "recovery_token_idx" ON "auth"."users" ("recovery_token") WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);
-- Create index "users_email_partial_key" to table: "users"
CREATE UNIQUE INDEX "users_email_partial_key" ON "auth"."users" ("email") WHERE (is_sso_user = false);
-- Create index "users_instance_id_email_idx" to table: "users"
CREATE INDEX "users_instance_id_email_idx" ON "auth"."users" ("instance_id", (lower((email)::text)));
-- Create index "users_instance_id_idx" to table: "users"
CREATE INDEX "users_instance_id_idx" ON "auth"."users" ("instance_id");
-- Create index "users_phone_key" to table: "users"
CREATE UNIQUE INDEX "users_phone_key" ON "auth"."users" ("phone");
-- Set comment to table: "users"
COMMENT ON TABLE "auth"."users" IS 'Auth: Stores user login data within a secure schema.';
-- Set comment to column: "is_sso_user" on table: "users"
COMMENT ON COLUMN "auth"."users" ."is_sso_user" IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';
-- Create "instances" table
CREATE TABLE "auth"."instances" ("id" uuid NOT NULL, "uuid" uuid NULL, "raw_base_config" text NULL, "created_at" timestamptz NULL, "updated_at" timestamptz NULL, PRIMARY KEY ("id"));
-- Set comment to table: "instances"
COMMENT ON TABLE "auth"."instances" IS 'Auth: Manages users across multiple sites.';
-- Create "audit_log_entries" table
CREATE TABLE "auth"."audit_log_entries" ("instance_id" uuid NULL, "id" uuid NOT NULL, "payload" json NULL, "created_at" timestamptz NULL, "ip_address" character varying(64) NOT NULL DEFAULT '', PRIMARY KEY ("id"));
-- Create index "audit_logs_instance_id_idx" to table: "audit_log_entries"
CREATE INDEX "audit_logs_instance_id_idx" ON "auth"."audit_log_entries" ("instance_id");
-- Set comment to table: "audit_log_entries"
COMMENT ON TABLE "auth"."audit_log_entries" IS 'Auth: Audit trail for user actions.';
-- Create enum type "aal_level"
CREATE TYPE "auth"."aal_level" AS ENUM ('aal1', 'aal2', 'aal3');
-- Create "sessions" table
CREATE TABLE "auth"."sessions" ("id" uuid NOT NULL, "user_id" uuid NOT NULL, "created_at" timestamptz NULL, "updated_at" timestamptz NULL, "factor_id" uuid NULL, "aal" "auth"."aal_level" NULL, "not_after" timestamptz NULL, PRIMARY KEY ("id"), CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE);
-- Create index "sessions_user_id_idx" to table: "sessions"
CREATE INDEX "sessions_user_id_idx" ON "auth"."sessions" ("user_id");
-- Create index "user_id_created_at_idx" to table: "sessions"
CREATE INDEX "user_id_created_at_idx" ON "auth"."sessions" ("user_id", "created_at");
-- Set comment to table: "sessions"
COMMENT ON TABLE "auth"."sessions" IS 'Auth: Stores session data associated to a user.';
-- Set comment to column: "not_after" on table: "sessions"
COMMENT ON COLUMN "auth"."sessions" ."not_after" IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';
-- Create "mfa_amr_claims" table
CREATE TABLE "auth"."mfa_amr_claims" ("session_id" uuid NOT NULL, "created_at" timestamptz NOT NULL, "updated_at" timestamptz NOT NULL, "authentication_method" text NOT NULL, "id" uuid NOT NULL, PRIMARY KEY ("id"), CONSTRAINT "mfa_amr_claims_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions" ("id") ON UPDATE NO ACTION ON DELETE CASCADE);
-- Create index "mfa_amr_claims_session_id_authentication_method_pkey" to table: "mfa_amr_claims"
CREATE UNIQUE INDEX "mfa_amr_claims_session_id_authentication_method_pkey" ON "auth"."mfa_amr_claims" ("session_id", "authentication_method");
-- Set comment to table: "mfa_amr_claims"
COMMENT ON TABLE "auth"."mfa_amr_claims" IS 'auth: stores authenticator method reference claims for multi factor authentication';
-- Create "sso_providers" table
CREATE TABLE "auth"."sso_providers" ("id" uuid NOT NULL, "resource_id" text NULL, "created_at" timestamptz NULL, "updated_at" timestamptz NULL, PRIMARY KEY ("id"), CONSTRAINT "resource_id not empty" CHECK ((resource_id = NULL::text) OR (char_length(resource_id) > 0)));
-- Create index "sso_providers_resource_id_idx" to table: "sso_providers"
CREATE UNIQUE INDEX "sso_providers_resource_id_idx" ON "auth"."sso_providers" ((lower(resource_id)));
-- Set comment to table: "sso_providers"
COMMENT ON TABLE "auth"."sso_providers" IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';
-- Set comment to column: "resource_id" on table: "sso_providers"
COMMENT ON COLUMN "auth"."sso_providers" ."resource_id" IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';
-- Create "saml_providers" table
CREATE TABLE "auth"."saml_providers" ("id" uuid NOT NULL, "sso_provider_id" uuid NOT NULL, "entity_id" text NOT NULL, "metadata_xml" text NOT NULL, "metadata_url" text NULL, "attribute_mapping" jsonb NULL, "created_at" timestamptz NULL, "updated_at" timestamptz NULL, PRIMARY KEY ("id"), CONSTRAINT "saml_providers_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, CONSTRAINT "entity_id not empty" CHECK (char_length(entity_id) > 0), CONSTRAINT "metadata_url not empty" CHECK ((metadata_url = NULL::text) OR (char_length(metadata_url) > 0)), CONSTRAINT "metadata_xml not empty" CHECK (char_length(metadata_xml) > 0));
-- Create index "saml_providers_entity_id_key" to table: "saml_providers"
CREATE UNIQUE INDEX "saml_providers_entity_id_key" ON "auth"."saml_providers" ("entity_id");
-- Create index "saml_providers_sso_provider_id_idx" to table: "saml_providers"
CREATE INDEX "saml_providers_sso_provider_id_idx" ON "auth"."saml_providers" ("sso_provider_id");
-- Set comment to table: "saml_providers"
COMMENT ON TABLE "auth"."saml_providers" IS 'Auth: Manages SAML Identity Provider connections.';
-- Create "refresh_tokens" table
CREATE TABLE "auth"."refresh_tokens" ("instance_id" uuid NULL, "id" bigserial NOT NULL, "token" character varying(255) NULL, "user_id" character varying(255) NULL, "revoked" boolean NULL, "created_at" timestamptz NULL, "updated_at" timestamptz NULL, "parent" character varying(255) NULL, "session_id" uuid NULL, PRIMARY KEY ("id"), CONSTRAINT "refresh_tokens_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions" ("id") ON UPDATE NO ACTION ON DELETE CASCADE);
-- Create index "refresh_tokens_instance_id_idx" to table: "refresh_tokens"
CREATE INDEX "refresh_tokens_instance_id_idx" ON "auth"."refresh_tokens" ("instance_id");
-- Create index "refresh_tokens_instance_id_user_id_idx" to table: "refresh_tokens"
CREATE INDEX "refresh_tokens_instance_id_user_id_idx" ON "auth"."refresh_tokens" ("instance_id", "user_id");
-- Create index "refresh_tokens_parent_idx" to table: "refresh_tokens"
CREATE INDEX "refresh_tokens_parent_idx" ON "auth"."refresh_tokens" ("parent");
-- Create index "refresh_tokens_session_id_revoked_idx" to table: "refresh_tokens"
CREATE INDEX "refresh_tokens_session_id_revoked_idx" ON "auth"."refresh_tokens" ("session_id", "revoked");
-- Create index "refresh_tokens_token_unique" to table: "refresh_tokens"
CREATE UNIQUE INDEX "refresh_tokens_token_unique" ON "auth"."refresh_tokens" ("token");
-- Set comment to table: "refresh_tokens"
COMMENT ON TABLE "auth"."refresh_tokens" IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';
-- Create "saml_relay_states" table
CREATE TABLE "auth"."saml_relay_states" ("id" uuid NOT NULL, "sso_provider_id" uuid NOT NULL, "request_id" text NOT NULL, "for_email" text NULL, "redirect_to" text NULL, "from_ip_address" inet NULL, "created_at" timestamptz NULL, "updated_at" timestamptz NULL, PRIMARY KEY ("id"), CONSTRAINT "saml_relay_states_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, CONSTRAINT "request_id not empty" CHECK (char_length(request_id) > 0));
-- Create index "saml_relay_states_for_email_idx" to table: "saml_relay_states"
CREATE INDEX "saml_relay_states_for_email_idx" ON "auth"."saml_relay_states" ("for_email");
-- Create index "saml_relay_states_sso_provider_id_idx" to table: "saml_relay_states"
CREATE INDEX "saml_relay_states_sso_provider_id_idx" ON "auth"."saml_relay_states" ("sso_provider_id");
-- Set comment to table: "saml_relay_states"
COMMENT ON TABLE "auth"."saml_relay_states" IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';
-- Create "sso_domains" table
CREATE TABLE "auth"."sso_domains" ("id" uuid NOT NULL, "sso_provider_id" uuid NOT NULL, "domain" text NOT NULL, "created_at" timestamptz NULL, "updated_at" timestamptz NULL, PRIMARY KEY ("id"), CONSTRAINT "sso_domains_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, CONSTRAINT "domain not empty" CHECK (char_length(domain) > 0));
-- Create index "sso_domains_domain_idx" to table: "sso_domains"
CREATE UNIQUE INDEX "sso_domains_domain_idx" ON "auth"."sso_domains" ((lower(domain)));
-- Create index "sso_domains_sso_provider_id_idx" to table: "sso_domains"
CREATE INDEX "sso_domains_sso_provider_id_idx" ON "auth"."sso_domains" ("sso_provider_id");
-- Set comment to table: "sso_domains"
COMMENT ON TABLE "auth"."sso_domains" IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';
-- Create "identities" table
CREATE TABLE "auth"."identities" ("id" text NOT NULL, "user_id" uuid NOT NULL, "identity_data" jsonb NOT NULL, "provider" text NOT NULL, "last_sign_in_at" timestamptz NULL, "created_at" timestamptz NULL, "updated_at" timestamptz NULL, "email" text NULL GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED, PRIMARY KEY ("provider", "id"), CONSTRAINT "identities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE);
-- Create index "identities_email_idx" to table: "identities"
CREATE INDEX "identities_email_idx" ON "auth"."identities" ("email" text_pattern_ops);
-- Create index "identities_user_id_idx" to table: "identities"
CREATE INDEX "identities_user_id_idx" ON "auth"."identities" ("user_id");
-- Set comment to table: "identities"
COMMENT ON TABLE "auth"."identities" IS 'Auth: Stores identities associated to a user.';
-- Set comment to column: "email" on table: "identities"
COMMENT ON COLUMN "auth"."identities" ."email" IS 'Auth: Email is a generated column that references the optional email property in the identity_data';
-- Create enum type "factor_type"
CREATE TYPE "auth"."factor_type" AS ENUM ('totp', 'webauthn');
-- Create enum type "factor_status"
CREATE TYPE "auth"."factor_status" AS ENUM ('unverified', 'verified');
-- Create "mfa_factors" table
CREATE TABLE "auth"."mfa_factors" ("id" uuid NOT NULL, "user_id" uuid NOT NULL, "friendly_name" text NULL, "factor_type" "auth"."factor_type" NOT NULL, "status" "auth"."factor_status" NOT NULL, "created_at" timestamptz NOT NULL, "updated_at" timestamptz NOT NULL, "secret" text NULL, PRIMARY KEY ("id"), CONSTRAINT "mfa_factors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE);
-- Create index "factor_id_created_at_idx" to table: "mfa_factors"
CREATE INDEX "factor_id_created_at_idx" ON "auth"."mfa_factors" ("user_id", "created_at");
-- Create index "mfa_factors_user_friendly_name_unique" to table: "mfa_factors"
CREATE UNIQUE INDEX "mfa_factors_user_friendly_name_unique" ON "auth"."mfa_factors" ("friendly_name", "user_id") WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);
-- Set comment to table: "mfa_factors"
COMMENT ON TABLE "auth"."mfa_factors" IS 'auth: stores metadata about factors';
-- Create "mfa_challenges" table
CREATE TABLE "auth"."mfa_challenges" ("id" uuid NOT NULL, "factor_id" uuid NOT NULL, "created_at" timestamptz NOT NULL, "verified_at" timestamptz NULL, "ip_address" inet NOT NULL, PRIMARY KEY ("id"), CONSTRAINT "mfa_challenges_auth_factor_id_fkey" FOREIGN KEY ("factor_id") REFERENCES "auth"."mfa_factors" ("id") ON UPDATE NO ACTION ON DELETE CASCADE);
-- Set comment to table: "mfa_challenges"
COMMENT ON TABLE "auth"."mfa_challenges" IS 'auth: stores metadata about challenge requests made';
