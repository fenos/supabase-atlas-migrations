env "local" {
  src = "file://schema"

  migration {
    dir = "file://migrations"
    format = atlas
  }

  schemas = ["public", "private", "auth"]

  // Define the URL of the database which is managed
  // in this environment.
  url = "postgresql://postgres:postgres@localhost:54322/postgres?sslmode=disable"

  // Define the URL of the Dev Database for this environment
  // See: https://atlasgo.io/concepts/dev-database
  dev = "docker://postgres/15"
}