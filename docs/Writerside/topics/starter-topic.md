# Deliverable 4 (Reports)

## 1. Get Invoices by Customer

This stored procedure takes either a customer's email address or the customer id number and returns all invoices that
are associated with the given customer

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.GetInvoicesByCustomer_ProfG_FP(
    @customer_email VARCHAR(320) = NULL,
    @customer_id INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON
    -- We need either the email or the id, not both, not neither
    IF @customer_email IS NULL AND @customer_id IS NULL
        BEGIN
            PRINT 'Please provide either the customer email or the customer id';
            RETURN
        END

    IF @customer_email IS NOT NULL AND @customer_id IS NOT NULL
        BEGIN
            PRINT 'Please provide either the customer email or the customer id but not both';
            RETURN
        END

    -- Check if the customer exists
    DECLARE @findCustomerCount INT;
    SELECT @findCustomerCount = COUNT(*)
    FROM S23916715.Customer_ProfG_FP
    WHERE (@customer_email IS NOT NULL AND email = @customer_email)
       OR (@customer_id IS NOT NULL AND id = @customer_id);

    IF @findCustomerCount = 0
        BEGIN
            PRINT 'Customer does not exist'
            RETURN
        END


    SELECT i.id                        AS InvoiceID,
           i.num                       AS InvoiceNumber,
           i.created                   AS InvoiceCreated,
           i.updated                   AS InvoiceUpdated,
           i.status                    AS InvoiceStatus,
           i.description               AS InvoiceDescription,
           c.id                        AS CustomerID,
           maskedCustomer.masked_email AS CustomerEmail,
           c.first_name                AS CustomerFirstName,
           c.last_name                 AS CustomerLastName
    FROM S23916715.Invoice_ProfG_FP AS i
             INNER JOIN
         S23916715.Customer_ProfG_FP AS c ON i.customer = c.id
             INNER JOIN View_Customers_ProfG_FP AS maskedCustomer ON i.customer = maskedCustomer.id
    WHERE (@customer_email IS NOT NULL AND c.email = @customer_email)
       OR (@customer_id IS NOT NULL AND c.id = @customer_id)
    AND i.deleted = 0;

    SET NOCOUNT OFF

END

</code-block>



<!--Writerside adds this topic when you create a new documentation project.
You can use it as a sandbox to play with Writerside features, and remove it from the TOC when you don't need it anymore.-->

## 2. Get Invoices from this Month

This stored procedure gets all the invoices that were created in the current month. It has an optional argument to
specify an invoice status to filer by

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.GetInvoicesFromThisMonth_ProfG_FP(
    @status VARCHAR(10) = NULL
)
AS
BEGIN
    SET NOCOUNT ON

    -- Select all invoices that have a creation date that is within the last 30 days
    -- Optionally, include the status if it was provided

    SELECT i.id          AS InvoiceID,
           i.num         AS InvoiceNumber,
           i.created     AS InvoiceCreated,
           i.updated     AS InvoiceUpdated,
           i.status      AS InvoiceStatus,
           i.description AS InvoiceDescription,
           c.id          AS CustomerID,
           c.email       AS CustomerEmail,
           c.first_name  AS CustomerFirstName,
           c.last_name   AS CustomerLastName
    FROM S23916715.Invoice_ProfG_FP AS i
             INNER JOIN
         S23916715.Customer_ProfG_FP AS c ON i.customer = c.id
    WHERE YEAR(created) = YEAR(GETDATE())
      AND MONTH(created) = MONTH(GETDATE())
      -- I'm pretty sure this server is configured to be case-insensitive,
      -- so we don't need to worry about changing the case (the db should store all upper case)
      AND (@status IS NULL OR status = S23916715.GetInvoiceStatusId_ProfF_FP(@status))
      AND i.deleted = 0;

    SET NOCOUNT OFF

END
</code-block>

## 3. Customers that have Unpaid Invoices

This view returns all customers that have an invoice which isn't paid or canceled. This view implements
data masking to hide sensitive fields such as phone number and email addresses.

<code-block lang="sql">
CREATE OR ALTER VIEW S23916715.CustomersThatHaveUnpaidInvoices_ProfG_FP AS
SELECT c.id,
       c.masked_email,
       c.masked_phone_number,
       c.first_name,
       c.last_name,
       COUNT(i.id) AS unpaid_invoice_count
FROM S23916715.View_Customers_ProfG_FP c
         LEFT JOIN S23916715.Invoice_ProfG_FP i ON c.id = i.customer
WHERE i.status NOT IN (S23916715.GetInvoiceStatusId_ProfF_FP('PAID'), S23916715.GetInvoiceStatusId_ProfF_FP('DRAFT'),
                       S23916715.GetInvoiceStatusId_ProfF_FP('CANCELED'))
   OR i.id IS NULL AND i.deleted = 0
GROUP BY c.id, c.masked_email, c.masked_phone_number, c.first_name, c.last_name;

</code-block>

## 4. Customer View

This view displays all the customers registered in the system. This view implements
data masking to hide sensitive fields such as phone number and email addresses.

<code-block lang="sql">
CREATE OR ALTER VIEW S23916715.View_Customers_ProfG_FP AS
SELECT id,
       CONCAT(
               LEFT(email, 1), -- Grab the first letter from the username
               REPLICATE('*',
                         LEN(SUBSTRING(email, 2, CHARINDEX('@', email) - 2))), -- Mask everything in between the first and last letter of the username portion of the address
               RIGHT(email, 1), -- Grab the first letter from the username
               SUBSTRING(email, CHARINDEX('@', email), LEN(email)) -- Append the domain
       ) AS masked_email,
       CONCAT(
               '***-***-',
               SUBSTRING(phone_num, 9, 4)
       ) AS masked_phone_number,
       first_name,
       last_name,
       address,
       address_line_two,
       city,
       state,
       zip_code
FROM S23916715.Customer_ProfG_FP
WHERE deleted = 0;
</code-block>

## 5. Get Unpaid Invoices

This stored procedure gets all invoices that aren't `PAID`, `DRAFT` OR `CANCELED`.
This procedure also has an optional `asJson` argument which will output the result as a JSON string.
This procedure implements data masking that disguises customer email and phone number.

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.GetUnpaidInvoices(
    @asJson BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #UnpaidInvoices
    (
        InvoiceID          INT,
        InvoiceNumber      INT,
        InvoiceCreated     DATETIME,
        InvoiceUpdated     DATETIME,
        InvoiceStatus      VARCHAR(10),
        InvoiceDescription VARCHAR(1024),
        CustomerID         INT,
        CustomerEmail      VARCHAR(320),
        CustomerFirstName  VARCHAR(128),
        CustomerLastName   VARCHAR(128)
    )

    INSERT INTO #UnpaidInvoices (InvoiceID, InvoiceNumber, InvoiceCreated, InvoiceUpdated, InvoiceStatus,
                                 InvoiceDescription, CustomerID, CustomerEmail, CustomerFirstName, CustomerLastName)
    SELECT i.id                        AS InvoiceID,
           i.num                       AS InvoiceNumber,
           i.created                   AS InvoiceCreated,
           i.updated                   AS InvoiceUpdated,
           i.status                    AS InvoiceStatus,
           i.description               AS InvoiceDescription,
           c.id                        AS CustomerID,
           maskedCustomer.masked_email AS CustomerEmail,
           c.first_name                AS CustomerFirstName,
           c.last_name                 AS CustomerLastName
    FROM S23916715.Invoice_ProfG_FP AS i
             INNER JOIN
         S23916715.Customer_ProfG_FP AS c ON i.customer = c.id
             INNER JOIN View_Customers_ProfG_FP AS maskedCustomer ON i.customer = maskedCustomer.id
    WHERE i.status NOT IN (S23916715.GetInvoiceStatusId('PAID'), S23916715.GetInvoiceStatusId('DRAFT'),
                           S23916715.GetInvoiceStatusId('CANCELED'))
      AND i.deleted = 0;

    IF @asJson = 1
        BEGIN
            -- This is what happens when we're not allowed to use *
            SELECT InvoiceID,
                   InvoiceNumber,
                   InvoiceCreated,
                   InvoiceUpdated,
                   InvoiceStatus,
                   InvoiceDescription,
                   CustomerID,
                   CustomerEmail,
                   CustomerFirstName,
                   CustomerLastName
            FROM #UnpaidInvoices
            FOR JSON PATH;
        END
    ELSE
        BEGIN
            -- This is what happens when we're not allowed to use *
            SELECT InvoiceID,
                   InvoiceNumber,
                   InvoiceCreated,
                   InvoiceUpdated,
                   InvoiceStatus,
                   InvoiceDescription,
                   CustomerID,
                   CustomerEmail,
                   CustomerFirstName,
                   CustomerLastName
            FROM #UnpaidInvoices;
        END

    DROP TABLE #UnpaidInvoices;

    SET NOCOUNT OFF

END
</code-block>

## 6. Get Paid Invoices

This stored procedure gets all invoices that have a status of `PAID`
This procedure also has an optional `asJson` argument which will output the result as a JSON string.
This procedure implements data masking that disguises customer email and phone number.

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.GetPaidInvoices(
    @asJson BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #PaidInvoices
    (
        InvoiceID          INT,
        InvoiceNumber      INT,
        InvoiceCreated     DATETIME,
        InvoiceUpdated     DATETIME,
        InvoiceStatus      VARCHAR(10),
        InvoiceDescription VARCHAR(1024),
        CustomerID         INT,
        CustomerEmail      VARCHAR(320),
        CustomerFirstName  VARCHAR(128),
        CustomerLastName   VARCHAR(128)
    )

    INSERT INTO #PaidInvoices (InvoiceID, InvoiceNumber, InvoiceCreated, InvoiceUpdated, InvoiceStatus,
                               InvoiceDescription, CustomerID, CustomerEmail, CustomerFirstName, CustomerLastName)
    SELECT i.id                        AS InvoiceID,
           i.num                       AS InvoiceNumber,
           i.created                   AS InvoiceCreated,
           i.updated                   AS InvoiceUpdated,
           i.status                    AS InvoiceStatus,
           i.description               AS InvoiceDescription,
           c.id                        AS CustomerID,
           maskedCustomer.masked_email AS CustomerEmail,
           c.first_name                AS CustomerFirstName,
           c.last_name                 AS CustomerLastName
    FROM S23916715.Invoice_ProfG_FP AS i
             INNER JOIN
         S23916715.Customer_ProfG_FP AS c ON i.customer = c.id
             INNER JOIN View_Customers_ProfG_FP AS maskedCustomer ON i.customer = maskedCustomer.id
    WHERE i.status = S23916715.GetInvoiceStatusId_ProfF_FP('PAID')
    AND i.deleted = 0;

    IF @asJson = 1
        BEGIN
            -- This is what happens when we're not allowed to use * :(
            SELECT InvoiceID,
                   InvoiceNumber,
                   InvoiceCreated,
                   InvoiceUpdated,
                   InvoiceStatus,
                   InvoiceDescription,
                   CustomerID,
                   CustomerEmail,
                   CustomerFirstName,
                   CustomerLastName
            FROM #PaidInvoices
            FOR JSON PATH;
        END
    ELSE
        BEGIN
            -- This is what happens when we're not allowed to use * :(
            SELECT InvoiceID,
                   InvoiceNumber,
                   InvoiceCreated,
                   InvoiceUpdated,
                   InvoiceStatus,
                   InvoiceDescription,
                   CustomerID,
                   CustomerEmail,
                   CustomerFirstName,
                   CustomerLastName
            FROM #PaidInvoices;
        END

    DROP TABLE #PaidInvoices;

    SET NOCOUNT OFF

END

</code-block>

## 7. Get Stale Invoices

This view returns all invoices that are "stale." A stale invoice is defined as an invoice that hasn't been updated
in at least 30 days.
This view implements data masking that disguises customer email and phone number.



<code-block lang="sql">
-- Get invoices that haven't been modified in at least 30 days
CREATE OR ALTER VIEW S23916715.GetStaleInvoices_ProfG_FP AS
SELECT i.id                        AS InvoiceID,
       i.num                       AS InvoiceNumber,
       i.created                   AS InvoiceCreated,
       i.updated                   AS InvoiceUpdated,
       i.status                    AS InvoiceStatus,
       i.description               AS InvoiceDescription,
       c.id                        AS CustomerID,
       maskedCustomer.masked_email AS CustomerEmail,
       c.first_name                AS CustomerFirstName,
       c.last_name                 AS CustomerLastName
FROM S23916715.Invoice_ProfG_FP AS i
         INNER JOIN
     S23916715.Customer_ProfG_FP AS c ON i.customer = c.id
         INNER JOIN View_Customers_ProfG_FP AS maskedCustomer ON i.customer = maskedCustomer.id
-- In theory, this also checks if the date is >= 30 days in the future, but the updated field
-- should never be in the future so it doesn't really matter
WHERE DATEDIFF(DAY, i.updated, GETDATE()) >= 30
AND i.deleted = 0;
</code-block>

## 8. Get Invoices by Number

This procedure gets an invoice provided the invoice number (different from the id.)
This procedure has an optional `asJson` argument which will output the result as a JSON string.
This procedure implements data masking that disguises customer email and phone number.

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.GetInvoiceByNum_ProfG_FP(
    @invoice_num INT,
    @asJson BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON

    CREATE TABLE #invoices
    (
        InvoiceID          INT,
        InvoiceNumber      INT,
        InvoiceCreated     DATETIME,
        InvoiceUpdated     DATETIME,
        InvoiceStatus      VARCHAR(10),
        InvoiceDescription VARCHAR(1024),
        CustomerEmail      VARCHAR(320),
        CustomerFirstName  VARCHAR(128),
        CustomerLastName   VARCHAR(128),
        Total              FLOAT
    );

    INSERT INTO #invoices (InvoiceID, InvoiceNumber, InvoiceCreated, InvoiceUpdated, InvoiceStatus, InvoiceDescription,
                           CustomerEmail, CustomerFirstName, CustomerLastName, Total)
    SELECT i.id                                                 AS InvoiceID,
           i.num                                                AS InvoiceNumber,
           i.created                                            AS InvoiceCreated,
           i.updated                                            AS InvoiceUpdated,
           i.status                                             AS InvoiceStatus,
           i.description                                        AS InvoiceDescription,
           maskedCustomer.masked_email                          AS CustomerEmail,
           c.first_name                                         AS CustomerFirstName,
           c.last_name                                          AS CustomerLastName,
           -- We store all money amounts as ints (aka x100) since computers make floating point mistakes.
           -- When we want to display a money amount, we have to divide by 100
           TRY_CAST(SUM(il.quantity * p.amount) AS FLOAT) / 100 AS Total
    FROM S23916715.Invoice_ProfG_FP AS i
             INNER JOIN S23916715.Customer_ProfG_FP AS c ON i.customer = c.id
             INNER JOIN View_Customers_ProfG_FP AS maskedCustomer ON i.customer = maskedCustomer.id
             INNER JOIN S23916715.InvoiceLine_ProfG_FP AS il ON i.id = il.invoice
             INNER JOIN S23916715.Price_ProfG_FP AS p ON il.price = p.id
    WHERE i.num = @invoice_num
    GROUP BY i.id, i.num, i.created, i.updated, i.status, i.description, maskedCustomer.masked_email,
             c.first_name, c.last_name;

    IF @asJson = 1
        BEGIN
            -- This is what happens when we're not allowed to use * >:(
            SELECT InvoiceID,
                   InvoiceNumber,
                   InvoiceCreated,
                   InvoiceUpdated,
                   InvoiceStatus,
                   InvoiceDescription,
                   CustomerEmail,
                   CustomerFirstName,
                   CustomerLastName,
                   Total
            FROM #invoices
            FOR JSON PATH;
        END
    ELSE
        BEGIN
            -- This is what happens when we're not allowed to use * >:(
            SELECT InvoiceID,
                   InvoiceNumber,
                   InvoiceCreated,
                   InvoiceUpdated,
                   InvoiceStatus,
                   InvoiceDescription,
                   CustomerEmail,
                   CustomerFirstName,
                   CustomerLastName,
                   Total
            FROM #invoices;
        END

    DROP TABLE #invoices;


    SET NOCOUNT OFF

END
</code-block>

## 9. Get Prices for Product

This procedure gets all the prices associated with a product.
This procedure takes either a product id or a product name & sku. If both or neither are provided, the procedure throws
an error

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.GetPricesForProduct_ProfG_FP(
    @product_id INT = NULL,
    @product_name VARCHAR(128) = NULL,
    @product_sku VARCHAR(128) = NULL
)
AS
BEGIN
    -- We can't have both id and product&sku
    IF @product_id IS NOT NULL AND @product_sku IS NOT NULL AND @product_name IS NOT NULL
        BEGIN
            PRINT 'You can''t provide both product ID and product name&sku'
            RETURN
        END
        -- We have to have at least one of the two
    ELSE
        IF @product_id IS NULL AND (@product_name IS NULL OR @product_sku IS NULL)
            BEGIN
                PRINT 'You must provide at least product ID or product name&sku'
                RETURN
            END

    -- If we don't have the product id, we need to find it
    IF @product_id IS NULL
        BEGIN
            SELECT @product_id = id FROM S23916715.Product_ProfG_FP WHERE name = @product_name AND sku = @product_sku;

            IF @product_sku IS NULL
                BEGIN
                    PRINT CONCAT('Product with name ', @product_name, ' and sku ', @product_sku, ' doesn''t exist')
                    RETURN
                END
        END

    SELECT id,
           TRY_CAST(amount AS FLOAT) / 100 AS price
    FROM S23916715.Price_ProfG_FP
    WHERE product = @product_id;

END
</code-block>

## 10. Get Total Billed this Month

This view gets all invoices that were created during the current month, aren't canceled and aren't marked as deleted,
then totals up the amount billed. The value is returned as a float.

<code-block lang="sql">
CREATE OR ALTER VIEW S23916715.GetTotalBilledThisMonth_ProfG_FP AS
SELECT CONVERT(FLOAT, SUM(CONVERT(BIGINT, Total))) / 100 AS GrandTotal
FROM (SELECT SUM(CONVERT(BIGINT, il.quantity * p.amount)) AS Total
      FROM S23916715.Invoice_ProfG_FP AS i
               INNER JOIN S23916715.InvoiceLine_ProfG_FP AS il ON i.id = il.invoice
               INNER JOIN S23916715.Price_ProfG_FP AS p ON il.price = p.id
      WHERE YEAR(created) = YEAR(GETDATE())
        AND MONTH(created) = MONTH(GETDATE())
        AND status != 'CANCELLED'
      AND deleted = 0
) AS Invoices;
</code-block>

## 11. Get Total Paid this Month

This view gets all payment records for invoices that were created during the current month, then totals up the amount
billed. The value is returned as a float.
This view also includes payments on invoices that aren't 100% paid off (partial payments.)

<code-block lang="sql">
CREATE OR ALTER VIEW S23916715.GetTotalPaidThisMonth_ProfG_FP AS
SELECT CONVERT(FLOAT, SUM(CONVERT(BIGINT, Total))) / 100 AS GrandTotal
FROM (SELECT SUM(CONVERT(BIGINT, amount)) AS Total
      FROM S23916715.InvoicePaymentRecord_ProfG_FP
      WHERE YEAR(date) = YEAR(GETDATE())
        AND MONTH(date) = MONTH(GETDATE())
) AS Records;
</code-block>

## 12. Calculate Remaining Balance

This function, given an invoice number, calculates the remaining balance on an invoice by totaling up the amount paid
on every payment record that refers to the given invoice and subtracting the total cost. This function is used in
several places for business logic but
can also be used to generate reporting data.

<code-block lang="sql">
CREATE OR ALTER FUNCTION S23916715.CalculateRemainingBalance_ProfF_FP(@invoice_num INT)
    RETURNS FLOAT
AS
BEGIN
    -- Try and find the invoice id
    DECLARE @invoice_id INT;

    SELECT @invoice_id = id FROM S23916715.Invoice_ProfG_FP WHERE num = @invoice_num;

    IF @invoice_id IS NULL
        RETURN -1

    -- Go grab the invoice and its total cost
    DECLARE @totalValue BIGINT;

    SELECT @totalValue = SUM(il.quantity * p.amount)
    FROM S23916715.Invoice_ProfG_FP AS i
             INNER JOIN S23916715.InvoiceLine_ProfG_FP AS il ON i.id = il.invoice
             INNER JOIN S23916715.Price_ProfG_FP AS p ON il.price = p.id
    WHERE i.num = @invoice_num;

    -- Now total up the amount paid
    DECLARE @amountPaid BIGINT;

    SET @amountPaid = S23916715.FindAmountPaid_ProfF_FP(@invoice_num);

    RETURN TRY_CAST(@totalValue - @amountPaid AS FLOAT) / 100;

END
</code-block>

## 13. Get Invoice Payments

This procedure gets all payments associated with the given invoice number.
This procedure implements data masking by only displaying the last four digits of the check number (if one exists)

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.View_GetInvoicePayments_ProfG_FP(
    @invoice_num INT
)
AS
BEGIN
    SET NOCOUNT ON

    -- TODO: Mask the check number if there is one
    -- TODO: THIS SHIT DON'T WORK. I think its something wrong with the joins. Break it down and try later

    -- Step 1: Make sure our invoice exists
    DECLARE @invoice_id INT;

    SELECT @invoice_id = id FROM S23916715.Invoice_ProfG_FP WHERE num = @invoice_num;

    IF @invoice_id IS NULL
        BEGIN
            PRINT CONCAT('Invoice with num ', @invoice_num, ' doesn''t exist')
            RETURN
        END

    -- Step 2: Grab all the invoice payment records that match our invoice's id,
    --         as well as their associated methods and invoice
    SELECT ipr.id,
           i.num,
           ipr.amount,
           ipr.date,
           m.method,
           IIF(ipr.check_num IS NOT NULL, CONCAT(REPLICATE('*', 4), RIGHT(ipr.check_num, 4)), NULL) AS maksed_check_num
    FROM S23916715.InvoicePaymentRecord_ProfG_FP AS ipr
             INNER JOIN S23916715.Invoice_ProfG_FP i ON i.id = ipr.invoice
             INNER JOIN S23916715.PaymentMethod_ProfG_FP m ON m.id = ipr.method
    WHERE ipr.invoice = @invoice_id;

    SET NOCOUNT OFF

END
</code-block>

## 14. Find Amount Paid

This function, given an invoice number, calculates the balance paid on an invoice by totaling up the amount paid
on every payment record that refers to the given invoice. This function is used in several places for business logic but
can also be used to generate reporting data.

<code-block lang="sql">
CREATE OR ALTER FUNCTION S23916715.FindAmountPaid_ProfF_FP(@invoice_num INT)
    RETURNS FLOAT
AS
BEGIN
    -- Try and find the invoice id
    DECLARE @invoice_id INT;

    SELECT @invoice_id = id FROM S23916715.Invoice_ProfG_FP WHERE num = @invoice_num;

    IF @invoice_id IS NULL
        RETURN -1

    -- Find all of the payment records that reference this invoice
    DECLARE @amountPaid BIGINT;

    SELECT @amountPaid = SUM(amount)
    FROM S23916715.InvoicePaymentRecord_ProfG_FP
    WHERE invoice = @invoice_id;

    RETURN @amountPaid;

END
</code-block>

## 15. Get Total Billed this Year

This view gets all invoices that were created during the current year, aren't canceled and aren't marked as deleted,
then totals up the amount billed. The value is returned as a float.

<code-block lang="sql">
CREATE OR ALTER VIEW S23916715.GetTotalBilledThisYear_ProfG_FP AS
SELECT CONVERT(FLOAT, SUM(CONVERT(BIGINT, Total))) / 100 AS GrandTotal
FROM (SELECT SUM(CONVERT(BIGINT, il.quantity * p.amount)) AS Total
      FROM S23916715.Invoice_ProfG_FP AS i
               INNER JOIN S23916715.InvoiceLine_ProfG_FP AS il ON i.id = il.invoice
               INNER JOIN S23916715.Price_ProfG_FP AS p ON il.price = p.id
      WHERE YEAR(created) = YEAR(GETDATE())
        AND status != 'CANCELLED'
        AND deleted = 0) AS Invoices;
</code-block>

## 16. Get Total Paid this Year

This view gets all payment records for invoices that were created during the current year, then totals up the amount
billed. The value is returned as a float.
This view also includes payments on invoices that aren't 100% paid off (partial payments.)

<code-block lang="sql">
CREATE OR ALTER VIEW S23916715.GetTotalPaidThisYear_ProfG_FP AS
SELECT CONVERT(FLOAT, SUM(CONVERT(BIGINT, Total))) / 100 AS GrandTotal
FROM (SELECT SUM(CONVERT(BIGINT, amount)) AS Total
      FROM S23916715.InvoicePaymentRecord_ProfG_FP
      WHERE YEAR(date) = YEAR(GETDATE())) AS Records;
</code-block>