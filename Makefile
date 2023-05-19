
PG_URL=postgresql://postgres:postgres@localhost:54322/postgres?sslmode=disable

introspect:
	atlas schema inspect -u "$(PG_URL)" --schema auth --schema public > schema/00_supabase.hcl

gen:
	atlas migrate diff --env local

apply:
	atlas migrate apply --baseline "20230519114524" --env local

status:
	atlas migrate status --env local

clean:
	atlas schema apply \
		--url=$(PG_URL) \
		--to file://migrations?version=20230519092225 \
		--dev-url "docker://postgres/15"
