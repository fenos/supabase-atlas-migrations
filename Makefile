
PG_URL="postgresql://postgres:postgres@localhost:54322/postgres?sslmode=disable"

introspect:
	atlas schema inspect -u "$(PG_URL)" --schema public

gen:
	atlas migrate diff \
      --dir "file://supabase/migrations" \
      --to "file://supabase/schema" \
      --dev-url "docker://postgres/15"

apply:
	atlas migrate apply \
      --dir "file://supabase/migrations" \
      --url $(PG_URL) \
      --allow-dirty
