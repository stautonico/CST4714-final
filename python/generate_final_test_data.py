import database
from mimesis import Person, Address, Text, random, Datetime
from mimesis.locales import Locale
from random import randint, choice
import sys

person = Person(Locale.EN)
address = Address(Locale.EN)
text = Text(Locale.EN)
rand = random.Random()
dt = Datetime(Locale.EN)

STATUSES = ["DRAFT", "PAID", "SENT", "OVERDUE", "CANCELED"]

PRODUCT_NAMES = [
    "Widget X",
    "TurboBlaze 3000",
    "SparkleGleam Pro",
    "PowerGrip Elite",
    "SwiftSnap 2000",
    "FlexiTech X4",
    "LunaShine Deluxe",
    "ThunderBlast 500",
    "EcoGlow Max",
    "PrecisionCut 360",
    "NovaGlide X",
    "AquaWave Pro",
    "MightyEdge 9000",
    "ProCircuit 200",
    "AeroFlow 700",
    "ZenithTech 2.0",
    "FlexiGrip X",
    "SonicWave 1000",
    "TurboBoost 4.5",
    "HydroBlitz 300",
    "SwiftGlide Pro",
    "TitanForce 6000",
    "MaxiGlow Ultra",
    "FlexiTrim 3.0",
    "NovaBeam 800",
    "PowerWave Elite",
    "LunaGlide Max",
    "AquaBoost Pro",
    "ThunderGrip 100",
    "EcoGlide Plus",
    "PrecisionMax 500",
    "FlexiForce X",
    "ProFlow 3000",
    "TurboFlex 2.0",
    "ZenithGlide 800",
    "HydroGrip Pro",
    "SwiftMax 7000",
    "TitanGrip X",
    "MaxiWave 2000",
    "FlexiShine 4.0",
    "NovaForce 300",
    "PowerGlide Plus",
    "LunaFlow Elite",
    "AquaMax 1000",
    "ThunderFlow Pro",
    "EcoFlex 600",
    "PrecisionGlide 900",
    "FlexiBoost 3.0",
    "TurboMax 5000",
    "ZenithForce X"
]

output_string = ""


def insert_fake_customers(cursor, count=50):
    global output_string
    for x in range(count):
        lname = person.last_name().replace("'", "''")
        addy = address.address().replace("'", "''")
        template = f"""
        INSERT INTO S23916715.Customer_ProfG_FP
        (email, phone_num, first_name, last_name, address, address_line_two, city, state, zip_code)
        VALUES (
        '{person.email()}',
        '{rand.generate_string_by_mask(mask="###-###-####")}',
        '{person.first_name()}',
        '{lname}',
        '{addy}',
        NULL,
        '{address.city()}',
        '{address.state(True)}',
        '{address.zip_code()}'
        )
        """
        output_string += template + "\n\n"
        cursor.execute(template)


def insert_fake_products(cursor, count=50):
    global output_string
    for product in PRODUCT_NAMES:
        template = f"""
        INSERT INTO S23916715.Product_ProfG_FP
        (name, description, sku) VALUES
        ('{product}',
        NULL,
        '{''.join([str(x) for x in rand.randints(5, 1, 100)])}')
        """
        output_string += template + "\n\n"
        cursor.execute(template)


def insert_fake_price(cursor, product_count=50, count=500):
    global output_string
    for x in range(count):
        print(f"\b" * 1000, end="")
        print(f"{x + 1}/{count}", end="")
        sys.stdout.flush()
        template = f"""
        INSERT INTO S23916715.Price_ProfG_FP
        (amount, product)
        VALUES
        ({randint(100, 100000)}, {randint(1, product_count)})
        """
        output_string += template + "\n\n"
        cursor.execute(template)

    print("\b" * 1000, end="")


def insert_fake_payment_method(cursor):
    global output_string
    for method in ["CHECK", "CASH", "CREDIT", "WIRE", "CRYPTO"]:
        template = f"""INSERT INTO S23916715.PaymentMethod_ProfG_FP (method) VALUES ('{method}')"""
        output_string += template + "\n\n"
        cursor.execute(template)


def insert_fake_statuses(cursor):
    global output_string
    for status in STATUSES:
        template = f"""INSERT INTO S23916715.InvoiceStatus_ProfG_FP (status) VALUES ('{status}')"""
        output_string += template + "\n\n"
        cursor.execute(template)


def insert_fake_invoice(cursor, customer_count=50, count=200):
    global output_string
    for x in range(count):
        print(f"\b" * 1000, end="")
        print(f"{x + 1}/{count}", end="")
        sys.stdout.flush()
        desc = "NULL"
        template = f"""
        INSERT INTO S23916715.Invoice_ProfG_FP
        ("""

        # Pick the status now so we can determine if we're inserting the paid timestamp
        status = choice(STATUSES)
        status_id = STATUSES.index(status) + 1

        if status == "PAID":
            template += "paid,"

        template += "status, customer, description, num)"
        template += " VALUES "
        if status == "PAID":
            template += f"('" + dt.datetime().strftime("%Y-%m-%d %H:%M:%S") + "',"
        else:
            template += "("

        template += f"{status_id}, {randint(1, customer_count)}, '{desc}', {x})"

        output_string += template + "\n\n"
        cursor.execute(template)

    print("\b" * 1000, end="")


def get_prices_for_product(cursor, product_id):
    query = f"SELECT * FROM S23916715.Price_ProfG_FP WHERE product = {product_id}"
    cursor.execute(query)

    out = []

    results = cursor.fetchall()

    for r in results:
        out.append({"id": r[0], "amount": r[1]})

    return out


def insert_fake_invoice_line(cursor, invoice_count=200, product_count=50, count=500):
    global output_string
    for x in range(count):
        print(f"\b" * 1000, end="")
        print(f"{x + 1}/{count}", end="")
        sys.stdout.flush()
        # Pick a random product
        prod_id = randint(1, product_count)
        # Grab its prices
        prices = get_prices_for_product(cursor, prod_id)
        # Keep going until we get one with prices
        while len(prices) == 0:
            prices = get_prices_for_product(cursor, prod_id)

        template = f"""
        EXECUTE S23916715.AddNewLineToInvoice_ProfG_FP
        @invoice_num={randint(1, invoice_count)},
        @product_id={prod_id},
        @price_id={choice(prices)['id']},
        @quantity={randint(1, 25)},
        @inserted_id = NULL
        """
        output_string += template + "\n\n"
        cursor.execute(template)

    print("\b" * 1000, end="")


def insert_payment_accounts(cursor):
    global output_string
    for account in ["Checking", "Savings", "Business"]:
        template = f"INSERT INTO S23916715.PaymentAccount_ProfG_FP (name) VALUES ('{account}')"
        output_string += template + "\n\n"
        cursor.execute(template)


def insert_invoice_payment_record(cursor, count=250, invoice_count=200):
    global output_string
    for x in range(count):
        print(f"\b" * 1000, end="")
        print(f"{x + 1}/{count}", end="")
        sys.stdout.flush()
        # Pick a random payment method
        methods = ["CHECK", "CASH", "CREDIT", "WIRE", "CRYPTO"]
        rand_method = choice(methods)
        check_num = None
        if rand_method == "CHECK":
            # Generate a random number for the check number
            check_num = rand.generate_string_by_mask(mask="########")

        template = f"""
            EXECUTE S23916715.AddPaymentToInvoice_ProfG_FP
            @invoice_num={randint(1, invoice_count)},
            @amount={randint(1, 100000)},
            @method='{rand_method}',
            @check_num={'NULL' if check_num is None else check_num},
            @payment_account={randint(1, 3)}
            """
        output_string += template + "\n\n"
        cursor.execute(template)

    print("\b" * 1000, end="")


def main():
    connection, cursor = database.init_connection()

    print("Making fake customers")
    insert_fake_customers(cursor)
    print("Making fake products")
    insert_fake_products(cursor)
    print("Making fake prices")
    insert_fake_price(cursor)
    print("Making fake payment methods")
    insert_fake_payment_method(cursor)

    print("Making fake invoice statuses")
    insert_fake_statuses(cursor)

    print("Making fake invoices")
    insert_fake_invoice(cursor)
    print("Making fake invoice lines")
    insert_fake_invoice_line(cursor)

    print("Making fake payment accounts")
    insert_payment_accounts(cursor)

    print("Making fake invoice payment records")
    insert_invoice_payment_record(cursor)

    print("All done")

    connection.commit()

    database.close_connection(connection, cursor)

    print("Building SQL file...")
    with open("payload.sql", "w") as f:
        lines = output_string.split("\n\n")

        for line in lines:
            f.write(line.replace("\n", "").replace("        ", "").replace("    ", " ") + "\n")


if __name__ == "__main__":
    main()
