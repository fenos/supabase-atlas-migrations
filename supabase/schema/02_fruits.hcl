table "fruits" {
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
  }

  column "owner_id" {
    null = false
    type = uuid
    default = sql("gen_random_uuid()")
  }

  index "idx_fruits_name_unique" {
    columns = [
      column.name
    ]
    unique = true
  }
}