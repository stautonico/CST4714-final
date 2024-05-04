import pyodbc

SERVER = "cityechdb1.database.windows.net"
DATABASE = "students"
USERNAME = "steven.tautonico15"
PASSWORD = "!@$23916715t!"
DRIVER = "{ODBC Driver 17 for SQL Server}"
CONNECTION_STRING = f'DRIVER={DRIVER};SERVER={SERVER};DATABASE={DATABASE};UID={USERNAME};PWD={PASSWORD}'


def init_connection():
    try:
        conn = pyodbc.connect(CONNECTION_STRING)
        c = conn.cursor()
    except pyodbc.Error as e:
        print("Error connecting to Azure SQL Database: ", e)
        exit(1)

    return conn, c


def close_connection(connection, cursor):
    cursor.close()
    connection.close()
