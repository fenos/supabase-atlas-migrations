env "local" {
  src = "file://supabase/schema"

  migration {
    dir = "file://supabase/db_migrations"
    format = atlas
  }

  schemas = ["public", "private"]

  // Define the URL of the database which is managed
  // in this environment.
  url = "postgresql://postgres:postgres@localhost:54322/postgres?sslmode=disable"

  // Define the URL of the Dev Database for this environment
  // See: https://atlasgo.io/concepts/dev-database
  dev = "docker://postgres/15"
}