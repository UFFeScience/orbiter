import os
from trino.dbapi import connect

# while True:
#     continue

TRINO_HOST = "trino.data-exploration.svc.cluster.local"
TRINO_PORT = "8080"
TRINO_USERNAME = "trino"
TRINO_CATALOG = "delta_lake"

current_path = f"{os.getcwd()}/sql_ddl/"
for schema in os.listdir(current_path):

    conn = connect(
        host=TRINO_HOST,
        port=TRINO_PORT,
        user=TRINO_USERNAME,
        catalog=TRINO_CATALOG,
        schema=schema,
        # http_scheme="https",
    )
    cur = conn.cursor()

    cur.execute(f"CREATE SCHEMA IF NOT EXISTS {TRINO_CATALOG}.{schema}")
    cur.fetchall()

    for sql_file_path in os.listdir(f"{current_path}/{schema}/"):

        with open(f"{current_path}/{schema}/{sql_file_path}", "r") as sql_file:
            print(f"executing {sql_file_path}")
            sql = sql_file.read()

            if sql.upper().startswith("CREATE TABLE"):
                table_name = (
                    sql
                    .split("(")[0]
                    .split("CREATE TABLE")[1]
                    .strip()
                )

                print(f"Deleting {table_name} table if it exists")
                cur.execute(f"DROP TABLE IF EXISTS {table_name}")
                cur.fetchall()

            cur.execute(sql)
            cur.fetchall()
