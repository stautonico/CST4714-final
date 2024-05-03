import database
import os
import re
import sys

TABLE_DROP_ORDER = ["Variables", "RevisionLine", "Revision", "InvoicePaymentRecord", "InvoiceLine", "Invoice",
                    "InvoiceStatus", "PaymentMethod", "Price", "Discount", "DiscountType", "Product", "Customer"]


def drop_tables(c):
    for table in TABLE_DROP_ORDER:
        try:
            c.execute(f"DROP TABLE IF EXISTS {table}_ProfG_FP")
        except Exception as e:
            print(f"Failed to drop table: {e}")


def make_tables(c):
    # We do it in the reverse of the drop table order
    for table in reversed(TABLE_DROP_ORDER):
        try:
            with open(f"../SQL/CreateTables/{table}.sql", "r") as f:
                sql = f.read()

            c.execute(sql)
        except Exception as e:
            print(f"Failed to create table '{table}': {e}")
            exit(1)


def extract_from_folder(folder):
    out = []
    for file in os.listdir(f"../SQL/{folder}"):
        with open(os.path.join("..", "SQL", folder, file), "r") as f:
            code = f.read()
            # Extract the type and name
            iterator = 0
            line = code.split("\n")[iterator]
            while line.startswith("--"):
                iterator += 1
                line = code.split("\n")[iterator]

            expr = r"CREATE OR ALTER (PROCEDURE|VIEW|FUNCTION) (S23916715\..*?)(?:\(| AS)"

            matches = re.match(expr, line)

            out.append(matches.groups())

    return out


def drop_reports(cursor):
    matches = extract_from_folder("Deliverable4_Reports")

    for match in matches:
        type, name = match
        cursor.execute(f"DROP {type} IF EXISTS {name}")


def make_reports(cursor):
    for file in os.listdir("../SQL/Deliverable4_Reports"):
        with open(os.path.join("..", "SQL", "Deliverable4_Reports", file), "r") as f:
            code = f.read()

            cursor.execute(code)


def drop_procedures(cursor):
    matches = extract_from_folder("Procedures")

    for match in matches:
        type, name = match
        cursor.execute(f"DROP {type} IF EXISTS {name}")


def make_procedures(cursor):
    for file in os.listdir("../SQL/Procedures"):
        with open(os.path.join("..", "SQL", "Procedures", file), "r") as f:
            code = f.read()

            cursor.execute(code)


def drop_views(cursor):
    matches = extract_from_folder("Views")

    for match in matches:
        type, name = match
        cursor.execute(f"DROP {type} IF EXISTS {name}")


def make_views(cursor):
    for file in os.listdir("../SQL/Views"):
        with open(os.path.join("..", "SQL", "Views", file), "r") as f:
            code = f.read()

            cursor.execute(code)


def drop_functions(cursor):
    matches = extract_from_folder("Functions")

    for match in matches:
        type, name = match
        cursor.execute(f"DROP {type} IF EXISTS {name}")


def make_functions(cursor):
    for file in os.listdir("../SQL/Functions"):
        with open(os.path.join("..", "SQL", "Functions", file), "r") as f:
            code = f.read()

            cursor.execute(code)


def main():
    nocreate = False

    if len(sys.argv) > 1:
        if sys.argv[1] == "--help":
            print(f"usage: reset_database.py [--nocreate]")
            exit(0)

        elif sys.argv[1] == "--nocreate":
            nocreate = True

        else:
            print(f"Invalid argument(s): {' '.join(sys.argv[1:])}")
            exit(1)

    connection, cursor = database.init_connection()

    print("Dropping functions...")
    drop_functions(cursor)
    connection.commit()

    if not nocreate:
        print("Re-creating functions...")
        make_functions(cursor)
        connection.commit()

    print("Dropping tables...")
    drop_tables(cursor)
    connection.commit()

    if not nocreate:
        print("Re-creating tables...")
        make_tables(cursor)
        connection.commit()

    print("Dropping views...")
    drop_views(cursor)
    connection.commit()

    if not nocreate:
        print("Re-creating views...")
        make_views(cursor)
        connection.commit()

    print("Dropping reports...")
    drop_reports(cursor)
    connection.commit()

    if not nocreate:
        print("Re-creating reports...")
        make_reports(cursor)
        connection.commit()

    print("Dropping procedures...")
    drop_procedures(cursor)
    connection.commit()

    if not nocreate:
        print("Re-creating procedures...")
        make_procedures(cursor)
        connection.commit()


    print("All done!")
    connection.commit()

    database.close_connection(connection, cursor)


if __name__ == "__main__":
    main()

TABLE_DROP_ORDER = ["Variables", "RevisionLine", "Revision", ]
