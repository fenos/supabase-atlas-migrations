# Supabase + Atlas

This project is a PoC to show how to use Supabase with Atlas for managing migrations.

## Requirements

- [Supabase CLI](https://supabase.com/docs/guides/cli#installation) installed:

```shell
brew install supabase/tap/supabase
```

- Docker Running on your machine.

## Getting started

Clone the repo:


```shell
git clone https://github.com/fenos/supabase-atlas-migrations
```

Start supabase local development:

```shell
supabase start
```

#### Migrate with Atlas

```shell
make apply
```

#### Check migration status

```shell
make status
```

#### Rollback with Atlas

TBD

## Creating a new migration

The atlas schema definition is located under `schema` folder.
Once you modify the schema you'll need to run `make gen` to generate the corresponded migration.
