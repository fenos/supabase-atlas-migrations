
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