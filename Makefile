
PG_URL=postgresql://postgres:postgres@localhost:54322/postgres?sslmode=disable

introspect:
	atlas schema inspect -u "$(PG_URL)" --schema public

gen:
	atlas migrate diff --env local

apply:
	atlas migrate apply --env local --allow-dirty

status:
	atlas migrate status --env local

clean:
	atlas schema apply \
		--url=$(PG_URL) \
		--to file://migrations?version=20230519092225 \
		--dev-url "docker://postgres/15"
