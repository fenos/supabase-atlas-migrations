table "audit_log_entries" {
  schema  = schema.auth
  comment = "Auth: Audit trail for user actions."
  column "instance_id" {
    null = true
    type = uuid
  }
  column "id" {
    null = false
    type = uuid
  }
  column "payload" {
    null = true
    type = json
  }
  column "created_at" {
    null = true
    type = timestamptz
  }
  column "ip_address" {
    null    = false
    type    = character_varying(64)
    default = ""
  }
  primary_key {
    columns = [column.id]
  }
  index "audit_logs_instance_id_idx" {
    columns = [column.instance_id]
  }
}
table "flow_state" {
  schema  = schema.auth
  comment = "stores metadata for pkce logins"
  column "id" {
    null = false
    type = uuid
  }
  column "user_id" {
    null = true
    type = uuid
  }
  column "auth_code" {
    null = false
    type = text
  }
  column "code_challenge_method" {
    null = false
    type = enum.code_challenge_method
  }
  column "code_challenge" {
    null = false
    type = text
  }
  column "provider_type" {
    null = false
    type = text
  }
  column "provider_access_token" {
    null = true
    type = text
  }
  column "provider_refresh_token" {
    null = true
    type = text
  }
  column "created_at" {
    null = true
    type = timestamptz
  }
  column "updated_at" {
    null = true
    type = timestamptz
  }
  column "authentication_method" {
    null = false
    type = text
  }
  primary_key {
    columns = [column.id]
  }
  index "idx_auth_code" {
    columns = [column.auth_code]
  }
  index "idx_user_id_auth_method" {
    columns = [column.user_id, column.authentication_method]
  }
}
table "identities" {
  schema  = schema.auth
  comment = "Auth: Stores identities associated to a user."
  column "id" {
    null = false
    type = text
  }
  column "user_id" {
    null = false
    type = uuid
  }
  column "identity_data" {
    null = false
    type = jsonb
  }
  column "provider" {
    null = false
    type = text
  }
  column "last_sign_in_at" {
    null = true
    type = timestamptz
  }
  column "created_at" {
    null = true
    type = timestamptz
  }
  column "updated_at" {
    null = true
    type = timestamptz
  }
  column "email" {
    null    = true
    type    = text
    comment = "Auth: Email is a generated column that references the optional email property in the identity_data"
    as {
      expr = "lower((identity_data ->> 'email'::text))"
      type = STORED
    }
  }
  primary_key {
    columns = [column.provider, column.id]
  }
  foreign_key "identities_user_id_fkey" {
    columns     = [column.user_id]
    ref_columns = [table.auth.users.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "identities_email_idx" {
#    comment = "Auth: Ensures indexed queries on the email column"
    on {
      column = column.email
      ops    = text_pattern_ops
    }
  }
  index "identities_user_id_idx" {
    columns = [column.user_id]
  }
}
table "instances" {
  schema  = schema.auth
  comment = "Auth: Manages users across multiple sites."
  column "id" {
    null = false
    type = uuid
  }
  column "uuid" {
    null = true
    type = uuid
  }
  column "raw_base_config" {
    null = true
    type = text
  }
  column "created_at" {
    null = true
    type = timestamptz
  }
  column "updated_at" {
    null = true
    type = timestamptz
  }
  primary_key {
    columns = [column.id]
  }
}
table "mfa_amr_claims" {
  schema  = schema.auth
  comment = "auth: stores authenticator method reference claims for multi factor authentication"
  column "session_id" {
    null = false
    type = uuid
  }
  column "created_at" {
    null = false
    type = timestamptz
  }
  column "updated_at" {
    null = false
    type = timestamptz
  }
  column "authentication_method" {
    null = false
    type = text
  }
  column "id" {
    null = false
    type = uuid
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "mfa_amr_claims_session_id_fkey" {
    columns     = [column.session_id]
    ref_columns = [table.sessions.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "mfa_amr_claims_session_id_authentication_method_pkey" {
    unique  = true
    columns = [column.session_id, column.authentication_method]
  }
}
table "mfa_challenges" {
  schema  = schema.auth
  comment = "auth: stores metadata about challenge requests made"
  column "id" {
    null = false
    type = uuid
  }
  column "factor_id" {
    null = false
    type = uuid
  }
  column "created_at" {
    null = false
    type = timestamptz
  }
  column "verified_at" {
    null = true
    type = timestamptz
  }
  column "ip_address" {
    null = false
    type = inet
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "mfa_challenges_auth_factor_id_fkey" {
    columns     = [column.factor_id]
    ref_columns = [table.mfa_factors.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "mfa_factors" {
  schema  = schema.auth
  comment = "auth: stores metadata about factors"
  column "id" {
    null = false
    type = uuid
  }
  column "user_id" {
    null = false
    type = uuid
  }
  column "friendly_name" {
    null = true
    type = text
  }
  column "factor_type" {
    null = false
    type = enum.factor_type
  }
  column "status" {
    null = false
    type = enum.factor_status
  }
  column "created_at" {
    null = false
    type = timestamptz
  }
  column "updated_at" {
    null = false
    type = timestamptz
  }
  column "secret" {
    null = true
    type = text
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "mfa_factors_user_id_fkey" {
    columns     = [column.user_id]
    ref_columns = [table.auth.users.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "factor_id_created_at_idx" {
    columns = [column.user_id, column.created_at]
  }
  index "mfa_factors_user_friendly_name_unique" {
    unique  = true
    columns = [column.friendly_name, column.user_id]
    where   = "(TRIM(BOTH FROM friendly_name) <> ''::text)"
  }
}
table "refresh_tokens" {
  schema  = schema.auth
  comment = "Auth: Store of tokens used to refresh JWT tokens once they expire."
  column "instance_id" {
    null = true
    type = uuid
  }
  column "id" {
    null = false
    type = bigserial
  }
  column "token" {
    null = true
    type = character_varying(255)
  }
  column "user_id" {
    null = true
    type = character_varying(255)
  }
  column "revoked" {
    null = true
    type = boolean
  }
  column "created_at" {
    null = true
    type = timestamptz
  }
  column "updated_at" {
    null = true
    type = timestamptz
  }
  column "parent" {
    null = true
    type = character_varying(255)
  }
  column "session_id" {
    null = true
    type = uuid
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "refresh_tokens_session_id_fkey" {
    columns     = [column.session_id]
    ref_columns = [table.sessions.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "refresh_tokens_instance_id_idx" {
    columns = [column.instance_id]
  }
  index "refresh_tokens_instance_id_user_id_idx" {
    columns = [column.instance_id, column.user_id]
  }
  index "refresh_tokens_parent_idx" {
    columns = [column.parent]
  }
  index "refresh_tokens_session_id_revoked_idx" {
    columns = [column.session_id, column.revoked]
  }
  index "refresh_tokens_token_unique" {
    unique  = true
    columns = [column.token]
  }
}
table "saml_providers" {
  schema  = schema.auth
  comment = "Auth: Manages SAML Identity Provider connections."
  column "id" {
    null = false
    type = uuid
  }
  column "sso_provider_id" {
    null = false
    type = uuid
  }
  column "entity_id" {
    null = false
    type = text
  }
  column "metadata_xml" {
    null = false
    type = text
  }
  column "metadata_url" {
    null = true
    type = text
  }
  column "attribute_mapping" {
    null = true
    type = jsonb
  }
  column "created_at" {
    null = true
    type = timestamptz
  }
  column "updated_at" {
    null = true
    type = timestamptz
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "saml_providers_sso_provider_id_fkey" {
    columns     = [column.sso_provider_id]
    ref_columns = [table.sso_providers.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "saml_providers_entity_id_key" {
    unique  = true
    columns = [column.entity_id]
  }
  index "saml_providers_sso_provider_id_idx" {
    columns = [column.sso_provider_id]
  }
  check "entity_id not empty" {
    expr = "(char_length(entity_id) > 0)"
  }
  check "metadata_url not empty" {
    expr = "((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))"
  }
  check "metadata_xml not empty" {
    expr = "(char_length(metadata_xml) > 0)"
  }
}
table "saml_relay_states" {
  schema  = schema.auth
  comment = "Auth: Contains SAML Relay State information for each Service Provider initiated login."
  column "id" {
    null = false
    type = uuid
  }
  column "sso_provider_id" {
    null = false
    type = uuid
  }
  column "request_id" {
    null = false
    type = text
  }
  column "for_email" {
    null = true
    type = text
  }
  column "redirect_to" {
    null = true
    type = text
  }
  column "from_ip_address" {
    null = true
    type = inet
  }
  column "created_at" {
    null = true
    type = timestamptz
  }
  column "updated_at" {
    null = true
    type = timestamptz
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "saml_relay_states_sso_provider_id_fkey" {
    columns     = [column.sso_provider_id]
    ref_columns = [table.sso_providers.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "saml_relay_states_for_email_idx" {
    columns = [column.for_email]
  }
  index "saml_relay_states_sso_provider_id_idx" {
    columns = [column.sso_provider_id]
  }
  check "request_id not empty" {
    expr = "(char_length(request_id) > 0)"
  }
}
table "schema_migrations" {
  schema  = schema.auth
  comment = "Auth: Manages updates to the auth system."
  column "version" {
    null = false
    type = character_varying(255)
  }
  primary_key {
    columns = [column.version]
  }
}
table "sessions" {
  schema  = schema.auth
  comment = "Auth: Stores session data associated to a user."
  column "id" {
    null = false
    type = uuid
  }
  column "user_id" {
    null = false
    type = uuid
  }
  column "created_at" {
    null = true
    type = timestamptz
  }
  column "updated_at" {
    null = true
    type = timestamptz
  }
  column "factor_id" {
    null = true
    type = uuid
  }
  column "aal" {
    null = true
    type = enum.aal_level
  }
  column "not_after" {
    null    = true
    type    = timestamptz
    comment = "Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired."
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "sessions_user_id_fkey" {
    columns     = [column.user_id]
    ref_columns = [table.auth.users.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "sessions_user_id_idx" {
    columns = [column.user_id]
  }
  index "user_id_created_at_idx" {
    columns = [column.user_id, column.created_at]
  }
}
table "sso_domains" {
  schema  = schema.auth
  comment = "Auth: Manages SSO email address domain mapping to an SSO Identity Provider."
  column "id" {
    null = false
    type = uuid
  }
  column "sso_provider_id" {
    null = false
    type = uuid
  }
  column "domain" {
    null = false
    type = text
  }
  column "created_at" {
    null = true
    type = timestamptz
  }
  column "updated_at" {
    null = true
    type = timestamptz
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "sso_domains_sso_provider_id_fkey" {
    columns     = [column.sso_provider_id]
    ref_columns = [table.sso_providers.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "sso_domains_domain_idx" {
    unique = true
    on {
      expr = "lower(domain)"
    }
  }
  index "sso_domains_sso_provider_id_idx" {
    columns = [column.sso_provider_id]
  }
  check "domain not empty" {
    expr = "(char_length(domain) > 0)"
  }
}
table "sso_providers" {
  schema  = schema.auth
  comment = "Auth: Manages SSO identity provider information; see saml_providers for SAML."
  column "id" {
    null = false
    type = uuid
  }
  column "resource_id" {
    null    = true
    type    = text
    comment = "Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code."
  }
  column "created_at" {
    null = true
    type = timestamptz
  }
  column "updated_at" {
    null = true
    type = timestamptz
  }
  primary_key {
    columns = [column.id]
  }
  index "sso_providers_resource_id_idx" {
    unique = true
    on {
      expr = "lower(resource_id)"
    }
  }
  check "resource_id not empty" {
    expr = "((resource_id = NULL::text) OR (char_length(resource_id) > 0))"
  }
}
table "auth" "users" {
  schema  = schema.auth
  comment = "Auth: Stores user login data within a secure schema."
  column "instance_id" {
    null = true
    type = uuid
  }
  column "id" {
    null = false
    type = uuid
  }
  column "aud" {
    null = true
    type = character_varying(255)
  }
  column "role" {
    null = true
    type = character_varying(255)
  }
  column "email" {
    null = true
    type = character_varying(255)
  }
  column "encrypted_password" {
    null = true
    type = character_varying(255)
  }
  column "email_confirmed_at" {
    null = true
    type = timestamptz
  }
  column "invited_at" {
    null = true
    type = timestamptz
  }
  column "confirmation_token" {
    null = true
    type = character_varying(255)
  }
  column "confirmation_sent_at" {
    null = true
    type = timestamptz
  }
  column "recovery_token" {
    null = true
    type = character_varying(255)
  }
  column "recovery_sent_at" {
    null = true
    type = timestamptz
  }
  column "email_change_token_new" {
    null = true
    type = character_varying(255)
  }
  column "email_change" {
    null = true
    type = character_varying(255)
  }
  column "email_change_sent_at" {
    null = true
    type = timestamptz
  }
  column "last_sign_in_at" {
    null = true
    type = timestamptz
  }
  column "raw_app_meta_data" {
    null = true
    type = jsonb
  }
  column "raw_user_meta_data" {
    null = true
    type = jsonb
  }
  column "is_super_admin" {
    null = true
    type = boolean
  }
  column "created_at" {
    null = true
    type = timestamptz
  }
  column "updated_at" {
    null = true
    type = timestamptz
  }
  column "phone" {
    null    = true
    type    = text
    default = sql("NULL::character varying")
  }
  column "phone_confirmed_at" {
    null = true
    type = timestamptz
  }
  column "phone_change" {
    null    = true
    type    = text
    default = ""
  }
  column "phone_change_token" {
    null    = true
    type    = character_varying(255)
    default = ""
  }
  column "phone_change_sent_at" {
    null = true
    type = timestamptz
  }
  column "confirmed_at" {
    null = true
    type = timestamptz
    as {
      expr = "LEAST(email_confirmed_at, phone_confirmed_at)"
      type = STORED
    }
  }
  column "email_change_token_current" {
    null    = true
    type    = character_varying(255)
    default = ""
  }
  column "email_change_confirm_status" {
    null    = true
    type    = smallint
    default = 0
  }
  column "banned_until" {
    null = true
    type = timestamptz
  }
  column "reauthentication_token" {
    null    = true
    type    = character_varying(255)
    default = ""
  }
  column "reauthentication_sent_at" {
    null = true
    type = timestamptz
  }
  column "is_sso_user" {
    null    = false
    type    = boolean
    default = false
    comment = "Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails."
  }
  column "deleted_at" {
    null = true
    type = timestamptz
  }
  primary_key {
    columns = [column.id]
  }
  index "confirmation_token_idx" {
    unique  = true
    columns = [column.confirmation_token]
    where   = "((confirmation_token)::text !~ '^[0-9 ]*$'::text)"
  }
  index "email_change_token_current_idx" {
    unique  = true
    columns = [column.email_change_token_current]
    where   = "((email_change_token_current)::text !~ '^[0-9 ]*$'::text)"
  }
  index "email_change_token_new_idx" {
    unique  = true
    columns = [column.email_change_token_new]
    where   = "((email_change_token_new)::text !~ '^[0-9 ]*$'::text)"
  }
  index "reauthentication_token_idx" {
    unique  = true
    columns = [column.reauthentication_token]
    where   = "((reauthentication_token)::text !~ '^[0-9 ]*$'::text)"
  }
  index "recovery_token_idx" {
    unique  = true
    columns = [column.recovery_token]
    where   = "((recovery_token)::text !~ '^[0-9 ]*$'::text)"
  }
  index "users_email_partial_key" {
    unique  = true
    columns = [column.email]
#    comment = "Auth: A partial unique index that applies only when is_sso_user is false"
    where   = "(is_sso_user = false)"
  }
  index "users_instance_id_email_idx" {
    on {
      column = column.instance_id
    }
    on {
      expr = "lower((email)::text)"
    }
  }
  index "users_instance_id_idx" {
    columns = [column.instance_id]
  }
  index "users_phone_key" {
    unique  = true
    columns = [column.phone]
  }
  check "users_email_change_confirm_status_check" {
    expr = "((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2))"
  }
}
enum "code_challenge_method" {
  schema = schema.auth
  values = ["s256", "plain"]
}
enum "factor_type" {
  schema = schema.auth
  values = ["totp", "webauthn"]
}
enum "factor_status" {
  schema = schema.auth
  values = ["unverified", "verified"]
}
enum "aal_level" {
  schema = schema.auth
  values = ["aal1", "aal2", "aal3"]
}
schema "auth" {
}
schema "public" {
}
