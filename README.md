# pgvector-ocaml

[pgvector](https://github.com/pgvector/pgvector) examples for OCaml

Supports [PostgreSQL-OCaml](https://github.com/mmottl/postgresql-ocaml)

[![Build Status](https://github.com/pgvector/pgvector-ocaml/actions/workflows/build.yml/badge.svg)](https://github.com/pgvector/pgvector-ocaml/actions)

## Getting Started

Follow the instructions for your database library:

- [PostgreSQL-OCaml](#postgresql-ocaml)

## PostgreSQL-OCaml

Enable the extension

```ocaml
c#exec ~expect:[Command_ok]
  "CREATE EXTENSION IF NOT EXISTS vector"
```

Create a table

```ocaml
c#exec ~expect:[Command_ok]
  "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))"
```

Insert vectors

```ocaml
c#exec ~expect:[Command_ok] ~params:[|"[1,1,1]"; "[2,2,2]"; "[1,1,2]"|]
  "INSERT INTO items (embedding) VALUES ($1), ($2), ($3)"
```

Get the nearest neighbors

```ocaml
let result =
  c#exec ~expect:[Tuples_ok] ~params:[|"[1,1,1]"|]
    "SELECT * FROM items ORDER BY embedding <-> $1 LIMIT 5"
in
result#get_all_lst |> List.map (List.map print_endline)
```

Add an approximate index

```ocaml
c#exec ~expect:[Command_ok]
  "CREATE INDEX ON items USING ivfflat (embedding vector_l2_ops) WITH (lists = 100)"
(* or *)
c#exec ~expect:[Command_ok]
  "CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)"
```

Use `vector_ip_ops` for inner product and `vector_cosine_ops` for cosine distance

See a [full example](example.ml)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/pgvector/pgvector-ocaml/issues)
- Fix bugs and [submit pull requests](https://github.com/pgvector/pgvector-ocaml/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/pgvector/pgvector-ocaml.git
cd pgvector-ocaml
createdb pgvector_ocaml_test
opam install postgresql
opam exec -- dune exec ./example.exe
```
