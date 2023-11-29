open Postgresql

let () =
  let conninfo = "postgresql://localhost/pgvector_ocaml_test" in
  let c = new connection ~conninfo () in
  c#set_notice_processing `Quiet ;
  let _ = c#exec ~expect:[Command_ok] "CREATE EXTENSION IF NOT EXISTS vector" in
  let _ = c#exec ~expect:[Command_ok] "DROP TABLE IF EXISTS items" in
  let _ =
    c#exec ~expect:[Command_ok]
      "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))"
  in
  let _ =
    c#exec ~expect:[Command_ok]
      ~params:[|"[1,1,1]"; "[2,2,2]"; "[1,1,2]"|]
      "INSERT INTO items (embedding) VALUES ($1), ($2), ($3)"
  in
  let result =
    c#exec ~expect:[Tuples_ok] ~params:[|"[1,1,1]"|]
      "SELECT * FROM items ORDER BY embedding <-> $1 LIMIT 5"
  in
  let _ = result#get_all_lst |> List.map (List.map print_endline) in
  let _ =
    c#exec ~expect:[Command_ok]
      "CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)"
  in
  c#finish
