
table "profiles" {
  schema = schema.public

  primary_key  {
    columns = [column.id]
  }

  column "id" {
    null = false
    type = bigint
    identity {
      generated = "BY DEFAULT"
      start = 1
      increment = 1
    }
  }

  column "user_id" {
    null = false
    type = uuid

  }

  foreign_key "profile_user_id_fkey" {
    columns     = [column.user_id]
    ref_columns = [table.auth.users.column.id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }

  column "name" {
    null = false
    type = text
    unique = true
  }

  index "idx_profile_name_unique" {
    columns = [
      column.name
    ]
    unique = true
  }
}