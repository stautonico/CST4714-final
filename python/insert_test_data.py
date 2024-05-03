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


# TODO: Use the stored procedures to create these

def insert_fake_customers(cursor, count=50):
    for x in range(count):
        lname = person.last_name().replace("'", "''")
        addy = address.address().replace("'", "''")
        template = f"""
        INSERT INTO S23916715.Customer_ProfG_FP
        (email, phone_num, first_name, last_name, address, address_line_two, city, state, zip_code)
        VALUES (
        '{person.email()}',
        '{person.phone_number()}',
        '{person.first_name()}',
        '{lname}',
        '{addy}',
        NULL,
        '{address.city()}',
        '{address.state(True)}',
        '{address.zip_code()}'
        )
        """
        cursor.execute(template)


def insert_fake_products(cursor, count=50):
    for x in range(count):
        desc = text.sentence().replace("'", "''")
        template = f"""
        INSERT INTO S23916715.Product_ProfG_FP
        (name, description, sku) VALUES
        ('{' '.join(text.words(4))}',
        '{desc}',
        '{''.join([str(x) for x in rand.randints(5, 1, 100)])}')
        """
        cursor.execute(template)


def insert_discount_types(cursor):
    for discount_type in ["FIXED", "PERCENT"]:
        cursor.execute(f"INSERT INTO S23916715.DiscountType_ProfG_FP (type) VALUES ('{discount_type}')")


def insert_fake_discount(cursor, count=50):
    for x in range(count):
        template = f"""
        INSERT INTO S23916715.Discount_ProfG_FP
        (amount, type)
        VALUES
        ({randint(1, 100)}, {randint(1, 2)})
        """
        cursor.execute(template)


def insert_fake_price(cursor, product_count=50, count=500):
    for x in range(count):
        print(f"\b" * 1000, end="")
        print(f"{x + 1}/{count}", end="")
        sys.stdout.flush()
        template = f"""
        INSERT INTO S23916715.Price_ProfG_FP
        (amount, product)
        VALUES
        ({randint(100, 1000000)}, {randint(1, product_count)})
        """
        cursor.execute(template)

    print("\b" * 1000, end="")


def insert_fake_payment_method(cursor):
    for method in ["CHECK", "CASH", "CREDIT", "WIRE", "CRYPTO"]:
        cursor.execute(f"""INSERT INTO S23916715.PaymentMethod_ProfG_FP (method) VALUES ('{method}')""")


def insert_fake_invoice(cursor, customer_count=50, count=200):
    for x in range(count):
        print(f"\b" * 1000, end="")
        print(f"{x + 1}/{count}", end="")
        sys.stdout.flush()
        desc = " ".join(text.words(10)).replace("'", "''")
        template = f"""
        INSERT INTO S23916715.Invoice_ProfG_FP
        ("""

        # Pick the status now so we can determine if we're inserting the paid timestamp
        status = choice(["DRAFT", "PAID", "SENT", "OVERDUE", "CANCELED"])

        if status == "PAID":
            template += "paid,"

        template += "status, customer, description, num)"
        template += " VALUES "
        if status == "PAID":
            template += f"('" + dt.datetime().strftime("%Y-%m-%d %H:%M:%S") + "',"
        else:
            template += "("

        template += f"'{status}', {randint(1, customer_count)}, '{desc}', {x})"

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


def insert_fake_invoice_line(cursor, invoice_count=200, product_count=50, discount_count=50, count=500):
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

        cursor.execute(template)

        # TODO: Add discounts

    print("\b" * 1000, end="")


def insert_invoice_payment_record(cursor, count=250, invoice_count=200):
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
            check_num = rand.generate_string_by_mask(mask="############")

        template = f"""
            EXECUTE S23916715.AddPaymentToInvoice_ProfG_FP
            @invoice_num={randint(1, invoice_count)},
            @amount={randint(1, 100000)},
            @method='{rand_method}',
            @check_num={'NULL' if check_num is None else check_num}
            """

        cursor.execute(template)

    print("\b" * 1000, end="")


def main():
    connection, cursor = database.init_connection()

    print("Making fake customers")
    insert_fake_customers(cursor)
    print("Making fake products")
    insert_fake_products(cursor)
    print("Making fake discount types")
    insert_discount_types(cursor)
    print("Making fake discounts")
    insert_fake_discount(cursor)
    print("Making fake prices")
    insert_fake_price(cursor)
    print("Making fake payment methods")
    insert_fake_payment_method(cursor)
    print("Making fake invoices")
    insert_fake_invoice(cursor)
    print("Making fake invoice lines")
    insert_fake_invoice_line(cursor)
    print("Make fake invoice payment records")
    insert_invoice_payment_record(cursor)

    print("All done")

    connection.commit()

    database.close_connection(connection, cursor)


if __name__ == "__main__":
    main()
