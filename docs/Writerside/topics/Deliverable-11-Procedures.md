# Deliverable 11 (Business Logic Procedures)

## Initialize Invoice

This procedure takes the required information to create a new invoice.

<table>
<thead>
<tr>
    <th>Field</th>
    <th>Description</th>
    <th>Required</th>
</tr>
</thead>
<tbody>
<tr>
    <td><code>customer_email</code></td>
    <td>The email of the customer associated with</td>
    <td>✓</td>
</tr>

<tr>
    <td><code>invoice_num</code></td>
    <td>Override the automatically generated invoice number</td>
    <td>❌</td>  
</tr>


<tr>
    <td><code>due_date</code></td>
    <td>The date the invoice is due (mutually exclusive with <code>due_days</code>)</td>
    <td>❌</td>
</tr>   

<tr>
    <td><code>due_days</code></td>
    <td>How many days from the current date the invoice is due (mutually exclusive with <code>due_date</code>)</td>
    <td>❌</td>
</tr>

<tr>
    <td><code>inserted_id</code></td>
    <td>Output var which returns the ID of the newly inserted invoice</td>
    <td>❌</td>
</tr>
</tbody>
</table>

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.InitializeInvoice_ProfG_FP(
    @customer_email VARCHAR(320),
    @invoice_num INT = NULL,
    @description VARCHAR(1024) = NULL,
    @due_date DATE = NULL,
    @due_days INT = NULL, -- The amount of days (from today) which the invoice is due
    @inserted_id INT OUT
)
AS
BEGIN
    SET NOCOUNT ON
    -- Step 1: Check that our customer exists
    DECLARE @customerID INT;

    SELECT @customerID = id FROM S23916715.Customer_ProfG_FP WHERE email = @customer_email;

    IF @customerID IS NULL
        BEGIN
            PRINT CONCAT('Customer with email ', @customer_email, ' does not exist');
            RETURN
        END

    -- Step 2a: If the user provided an invoice number, check if an invoice already exists with this number
    IF @invoice_num IS NOT NULL
        BEGIN
            DECLARE @foundInvoiceNum INT;

            SELECT @foundInvoiceNum = num FROM S23916715.Invoice_ProfG_FP WHERE num = @invoice_num;

            IF @foundInvoiceNum IS NOT NULL
                BEGIN
                    PRINT CONCAT('Invoice with the number ', @foundInvoiceNum, ' exists')
                    RETURN
                END
        END

    -- Step 2b: If the user did not provide an invoice number, try to increment it from our variables table
    DECLARE @numVar VARCHAR(128);

    SELECT @numVar = value FROM S23916715.Variables_ProfG_FP WHERE [key] = 'invoice_accumulator';

    IF @numVar IS NULL
        BEGIN
            -- We haven't started accumulating invoice numbers yet, so start from 1
            INSERT INTO S23916715.Variables_ProfG_FP ([key], value) VALUES ('invoice_accumulator', '1');
            SET @invoice_num = 1;
        END
    ELSE
        BEGIN
            -- Convert the value to a INT
            SET @invoice_num = TRY_CAST(@numVar AS INT) + 1
            -- Now increment our accumulator in the database
            UPDATE S23916715.Variables_ProfG_FP
            SET value=TRY_CAST(@invoice_num AS VARCHAR)
            WHERE [key] = 'invoice_accumulator';
        END

    -- Step 3: We can't have both the due_date and the due_days
    IF @due_date IS NOT NULL AND @due_days IS NOT NULL
        BEGIN
            PRINT 'You can''t provide both due_date and due_days'
            RETURN
        END

    -- Find the id for the 'DRAFT' status
    DECLARE @statusId INT;

    SELECT @statusId = id FROM S23916715.InvoiceStatus_ProfG_FP WHERE status = 'DRAFT';
    IF @statusId IS NULL
        BEGIN
            PRINT 'Something went wrong when creating new invoice (bad status)'
            RETURN
        END

    -- Step 4: Insert the new invoice
    BEGIN TRY
        IF @due_days IS NOT NULL OR @due_date IS NOT NULL
            BEGIN
                DECLARE @due DATE;
                IF @due_date IS NOT NULL
                    -- If we have the due_date, just insert that,
                    SET @due = @due_date
                ELSE
                    -- but if we have the due_days, set `due` = today's date + the due_days
                    SET @due = DATEADD(DAY, @due_days, GETDATE())

                INSERT INTO S23916715.Invoice_ProfG_FP (num, customer, description, due, status)
                VALUES (@invoice_num, @customerID, @description, @due, @statusId)
            END
        ELSE
            -- We we didn't provide either due_days or due_date, don't insert it (it'll default to today + 30 days)
            BEGIN
                INSERT INTO S23916715.Invoice_ProfG_FP
                    (num, customer, description, status)
                VALUES (@invoice_num, @customerID, @description, @statusId);
            END

        -- Set our output variable to the ID of the last inserted ID (scoped)
        SET @inserted_id = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        PRINT 'Something went wrong when initializing new invoice'
        RETURN
    END CATCH

    SET NOCOUNT OFF
END
</code-block>

## Add Line to Invoice

This procedure adds a new product line to an invoice.

<table>
<thead>
  <tr>
    <th>Field</th>
    <th>Description</th>
    <th>Required</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td><code>invoice_num</code></td>
    <td>The number of the invoice to add the line to</td>
    <td>✓</td>
  </tr>
  <tr>
    <td><code>product_name</code></td>
    <td>The name of the product to add to the invoice (requires <code>product_sku</code>, mutually exclusive with <code>product_id</code>)</td>
    <td>❌</td>
  </tr>
  <tr>
    <td><code>product_sku</code></td>
    <td>The sku of the product to add to the invoice (requires <code>product_name</code>, mutually exclusive with <code>product_id</code>)</td>
    <td>❌</td>
  </tr>
  <tr>
    <td><code>product_id</code></td>
    <td>The id of the product to add to the invoice (mutually exclusive with <code>product_name</code> &amp; <code>product_sku</code>)</td>
    <td>❌</td>
  </tr>
  <tr>
    <td><code>price_id</code></td>
    <td>The id of the price to add to the line</td>
    <td>✓</td>
  </tr>
  <tr>
    <td><code>quantity</code></td>
    <td>The quantity of the product to add to the invoice</td>
    <td>✓</td>
  </tr>
  <tr>
    <td><code>description</code></td>
    <td>Any additional information associated with the line</td>
    <td>❌</td>
  </tr>
  <tr>
    <td><code>inserted_id</code></td>
    <td>Output var which returns the id of the newly inserted invoice line</td>
    <td>❌</td>
  </tr>
</tbody>
</table>

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.AddNewLineToInvoice_ProfG_FP(
    @invoice_num INT,
    @product_name VARCHAR(128) = NULL,
    @product_sku VARCHAR(128) = NULL,
    @product_id INT = NULL,
    @price_id INT,
    @quantity INT,
    @description VARCHAR(1024) = NULL,
    @inserted_id INT OUT
)
AS
BEGIN
    SET NOCOUNT ON

    -- Step 1: Make sure the invoice exists
    DECLARE @invoice_id INT;

    SELECT @invoice_id = id FROM S23916715.Invoice_ProfG_FP WHERE num = @invoice_num;
    IF @invoice_id IS NULL
        BEGIN
            PRINT CONCAT('Invoice with the number ', @invoice_num, ' doesn''t exist')
            RETURN
        END

    -- Step 2: Check if we're going to find the product by id or name&sku
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

    -- Now we can try to find the product
    SELECT @product_id = id
    FROM S23916715.Product_ProfG_FP
    WHERE (@product_id IS NOT NULL AND id = @product_id)
       OR (@product_name IS NOT NULL AND @product_sku IS NOT NULL AND name = @product_name AND sku = @product_sku);

    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Product doesn''t exist'
            RETURN
        END

    -- We can try to find the price
    DECLARE @pricesProductId INT

    SELECT @pricesProductId = product FROM S23916715.Price_ProfG_FP WHERE id = @price_id;

    IF @pricesProductId IS NULL
        BEGIN
            PRINT 'The provided price does not exist'
            RETURN
        END

    -- The price must belong to the provided product
    IF @pricesProductId != @product_id
        BEGIN
            PRINT 'The provided price does not belong to the provided product'
            RETURN
        END

    -- Validate our provided quantity
    IF @quantity <= 0
        BEGIN
            PRINT 'Quantity must be > 0'
            RETURN
        END

    -- Finally, insert our new invoice line
    BEGIN TRY
        INSERT INTO S23916715.InvoiceLine_ProfG_FP (invoice, product, price, quantity, description)
        VALUES (@invoice_id, @product_id, @price_id, @quantity, @description);

        -- Set our output var to the new ID
        SET @inserted_id = SCOPE_IDENTITY();

        PRINT CONCAT('Successfully added line to in invoice num ', TRY_CAST(@invoice_num AS VARCHAR))
    END TRY
    BEGIN CATCH
        PRINT 'Something went wrong when inserting new line into invoice';
        RETURN
    END CATCH

    SET NOCOUNT OFF

END
</code-block>

## Add Payment to Invoice

Log a payment for a given invoice. Automatically updates the invoice's status if necessary.

<table>
<thead>
  <tr>
    <th>Field</th>
    <th>Description</th>
    <th>Required</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td><code>invoice_num</code></td>
    <td>The number of the invoice to log the payment to</td>
    <td>✓</td>
  </tr>
  <tr>
    <td><code>amount</code></td>
    <td>The amount (in dollars and cents) paid</td>
    <td>✓</td>
  </tr>
  <tr>
    <td><code>method</code></td>
    <td>The method of payment (check, cash, crypto, etc.)</td>
    <td>✓</td>
  </tr>
  <tr>
    <td><code>check_num</code></td>
    <td>The number written on the check (only applicable if the <code>method</code> is "check")</td>
    <td>❌</td>
  </tr>
  <tr>
    <td><code>payment_account</code></td>
    <td>The account the payment would be paid out to</td>
    <td>✓</td>
  </tr>
</tbody>
</table>

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.AddPaymentToInvoice_ProfG_FP(
    @invoice_num INT,
    @amount FLOAT,
    @method VARCHAR(20),
    @check_num VARCHAR(32) = NULL,
    @payment_account INT
)
AS
BEGIN
    SET NOCOUNT ON

    -- Step 1: Make sure our invoice exists
    DECLARE @invoice_id INT;

    SELECT @invoice_id = id FROM S23916715.Invoice_ProfG_FP WHERE num = @invoice_num;

    IF @invoice_id IS NULL
        BEGIN
            PRINT CONCAT('Invoice with num ', @invoice_num, ' doesn''t exist')
            RETURN
        END

    -- Step 2: Validate the payment method the user provided
    DECLARE @paymentMethodId INT;
    SET @paymentMethodId = S23916715.GetPaymentMethodId_ProfF_FP(@method);

    IF @paymentMethodId IS NULL
        BEGIN
            PRINT CONCAT(@method, ' is an invalid payment method');
            RETURN
        END

    -- Step 3: If the payment method isn't check but we provided a check number, fail
    IF @method != 'CHECK' AND @check_num IS NOT NULL
        BEGIN
            PRINT 'Check number can only be supplied when payment method is check'
            RETURN
        END

    -- Step 4: Make sure the payment account id is valid
    DECLARE @findAccountCount INT;

    SELECT @findAccountCount = COUNT(*)
    FROM S23916715.PaymentAccount_ProfG_FP
    WHERE id = @payment_account AND deleted = 0;
    IF @findAccountCount IS NULL OR @findAccountCount = 0
        BEGIN
            PRINT 'Payment account doesn''t exist'
            RETURN
        END

    -- Step 5: Start a transaction for creating the payment record
    -- The reason we need to do this is because if the payment record fully pays off the invoice,
    -- we need to modify the invoice object as well, which could cause problems if something goes wrong
    -- mid-way trough
    BEGIN TRANSACTION [Trans]
        BEGIN TRY
            -- Step 5a: Create the payment record
            INSERT INTO S23916715.InvoicePaymentRecord_ProfG_FP (invoice, amount, method, check_num, payment_account)
            VALUES (@invoice_id, TRY_CAST(@amount * 100 AS INT), @paymentMethodId,
                    @check_num, @payment_account)

            DECLARE @remaining FLOAT;

            SET @remaining = S23916715.CalculateRemainingBalance_ProfF_FP(@invoice_num)

            -- Step 5b: If the invoice is completely paid off, set the status to paid and set the `paid` timestamp
            IF @remaining <= 0
                BEGIN
                    UPDATE S23916715.Invoice_ProfG_FP
                    SET status = S23916715.GetInvoiceStatusId_ProfF_FP('PAID'),
                        paid=SYSDATETIME()
                    WHERE num = @invoice_num;
                END

            -- Step 5c: Add the payment total to our account
            UPDATE S23916715.PaymentAccount_ProfG_FP
            SET balance = balance + TRY_CAST(@amount * 100 AS INT)
            WHERE id = @payment_account;

            COMMIT TRANSACTION [Trans]
        END TRY
        BEGIN CATCH
            PRINT 'Something went wrong when creating payment record'
            ROLLBACK TRANSACTION [Trans]
            RETURN
        END CATCH

        SET NOCOUNT OFF

END
</code-block>

## Change Status on Several Invoices

Given several `invoice_nums` (in CSV format), set the `status` on each invoice to the given `@status`

<table>
<thead>
  <tr>
    <th>Field</th>
    <th>Description</th>
    <th>Required</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td><code>status</code></td>
    <td>The status to set on each invoice</td>
    <td>✓</td>
  </tr>
  <tr>
    <td><code>invoice_nums</code></td>
    <td>The invoice numbers to change the status of (in CSV format)</td>
    <td>✓</td>
  </tr>
</tbody>
</table>

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.ChangeStatusOnSeveralInvoices_ProfG_FP(
    @status VARCHAR(128),
    @invoice_nums VARCHAR(1024) -- a csv of the invoice numbers
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @status_id INT;

    -- Get (and validate) our status
    SET @status_id = S23916715.GetInvoiceStatusId_ProfF_FP(@status);

    IF @status_id IS NULL
        BEGIN
            PRINT CONCAT(@status, ' is an invalid status')
            RETURN
        END

    -- Split the csv argument into a table for looping
    CREATE TABLE #tableOfIds
    (
        id INT
    );

    INSERT INTO #tableOfIds (id)
    SELECT value
    FROM STRING_SPLIT(@invoice_nums, ',');

    -- Loop through each value in our temporary table and find the invoice, then try to set its status
    DECLARE @id INT;

    BEGIN TRANSACTION [UpdateTransaction]

        BEGIN TRY
            WHILE EXISTS (SELECT * FROM #tableOfIds)
                BEGIN
                    -- Pick an invoice num from the top of our temp table
                    SELECT TOP 1 @id = id FROM #tableOfIds;
                    -- Delete that value so we don't pick it next iteration
                    DELETE FROM #tableOfIds WHERE id = @id;

                    -- Make sure the invoice exists
                    DECLARE @invoice_id INT;

                    SELECT @invoice_id = id FROM S23916715.Invoice_ProfG_FP WHERE num = @id;

                    IF @invoice_id IS NULL
                        BEGIN
                            PRINT CONCAT('Invoice with num ', @id, ' doesn''t exist')
                            RETURN
                        END

                    -- Now that we know it exists, update its status
                    UPDATE S23916715.Invoice_ProfG_FP SET status=@status_id WHERE num = @id;

                END
                
            -- Remove our temporary table
            DROP TABLE #tableOfIds;
        END TRY
        BEGIN CATCH
            PRINT 'Something went wrong when updating invoice'
            ROLLBACK TRANSACTION [UpdateTransaction]
            RETURN
        END CATCH
    COMMIT TRANSACTION [UpdateTransaction]

    SET NOCOUNT OFF
END
</code-block>

## Create New Customer

<table>
  <thead>
    <tr>
      <th>Field</th>
      <th>Description</th>
      <th>Required</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>email</code></td>
      <td>The customer's email address</td>
      <td>✓</td>
    </tr>
    <tr>
      <td><code>phone_num</code></td>
      <td>The customer's phone number</td>
      <td>✓</td>
    </tr>
    <tr>
      <td><code>first_name</code></td>
      <td>The customer's first name</td>
      <td>✓</td>
    </tr>
    <tr>
      <td><code>last_name</code></td>
      <td>The customer's last name</td>
      <td>✓</td>
    </tr>
    <tr>
      <td><code>address</code></td>
      <td>Address line one</td>
      <td>✓</td>
    </tr>
    <tr>
      <td><code>address_line_two</code></td>
      <td>Address line two</td>
      <td>❌</td>
    </tr>
    <tr>
      <td><code>city</code></td>
      <td>City</td>
      <td>✓</td>
    </tr>
    <tr>
      <td><code>state</code></td>
      <td>State (2 characters)</td>
      <td>✓</td>
    </tr>
    <tr>
      <td><code>zip_code</code></td>
      <td>Zip code</td>
      <td>✓</td>
    </tr>
    <tr>
      <td><code>inserted_id</code></td>
      <td>Output parameter for inserted ID</td>
      <td>❌</td>
    </tr>
  </tbody>
</table>

<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.CreateNewCustomer_ProfG_FP(
    @email VARCHAR(320),
    @phone_num VARCHAR(12),
    @first_name VARCHAR(128),
    @last_name VARCHAR(128),
    @address VARCHAR(128),
    @address_line_two VARCHAR(128) = NULL,
    @city VARCHAR(128),
    @state CHAR(2),
    @zip_code VARCHAR(16),
    @inserted_id INT OUT
)
AS
BEGIN
    SET NOCOUNT ON

    -- Step 1: Make sure we don't already have this customer (the email should be unique)
    DECLARE @findCustomerCount INT;

    SELECT @findCustomerCount = COUNT(*) FROM S23916715.Customer_ProfG_FP WHERE email = @email;
    IF @findCustomerCount IS NOT NULL AND @findCustomerCount != 0
        BEGIN
            PRINT CONCAT('Customer with email ', @email, ' already exists!');
            RETURN
        END

    -- Step 2: Check if the given email is valid
    DECLARE @isValid BIT;
    SET @isValid = S23916715.ValidateEmail_ProfG_FP(@email);

    IF @isValid = 0
        BEGIN
            PRINT 'Please provide a valid email address'
            RETURN
        END

    -- Step 3: Make sure all of the provided fields aren't null
    -- Note: We don't need to check the email since our validate function does it
    IF @phone_num IS NULL OR
       @first_name IS NULL OR
       @last_name IS NULL OR
       @address IS NULL OR
       @city IS NULL OR
       @state IS NULL OR
       @zip_code IS NULL
        BEGIN
            PRINT 'Please provide all required fields'
            RETURN
        END


    -- At this point we can insert our customer into our database
    BEGIN TRY
        INSERT INTO S23916715.Customer_ProfG_FP
        (email,
         phone_num,
         first_name,
         last_name,
         address,
         address_line_two,
         city, state, zip_code)
        VALUES (@email,
                @phone_num,
                @first_name,
                @last_name,
                @address,
                @address_line_two,
                @city, @state, @zip_code)

        -- Set our output variable to the ID of the last inserted ID (scoped)
        SET @inserted_id = SCOPE_IDENTITY();

        PRINT 'Successfully added new customer'
    END TRY
    BEGIN CATCH
        PRINT 'Something went wrong when creating new customer';
        RETURN
    END CATCH


    SET NOCOUNT OFF

END
</code-block>

# Create New Product

<table>
  <thead>
    <tr>
      <th>Field</th>
      <th>Description</th>
      <th>Required</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td></td>
      <td>✓</td>
    </tr>
    <tr>
      <td><code>description</code></td>
      <td>The default description of the product</td>
      <td>❌</td>
    </tr>
    <tr>
      <td><code>sku</code></td>
      <td>The sku of the product</td>
      <td>✓</td>
    </tr>
    <tr>
      <td><code>inserted_id</code></td>
      <td>Output parameter for inserted ID</td>
      <td>✓</td>
    </tr>
  </tbody>
</table>


<code-block lang="sql">
CREATE OR ALTER PROCEDURE S23916715.CreateNewProduct_ProfG_FP(
    @name VARCHAR(128),
    @description VARCHAR(1204) = NULL,
    @sku VARCHAR(128),
    @inserted_id INT OUT
)
AS
BEGIN
    SET NOCOUNT ON

    -- Step 1: Make sure we don't already have a product with this name or sku
    DECLARE @findProductCount INT;

    -- The name and the sku field don't need to be unique on their own, but the combination needs to be
    SELECT @findProductCount = COUNT(*) FROM S23916715.Product_ProfG_FP WHERE name = @name AND sku = @sku;
    IF @findProductCount IS NOT NULL AND @findProductCount != 0
        BEGIN
            PRINT CONCAT('Product with the name ', @name, ' and sku ', @sku, ' already exist');
            RETURN
        END

    -- Step 2: Make sure we have all of the required fields
    IF @name IS NULL OR
       @sku IS NULL
        BEGIN
            PRINT 'Please provide all required fields'
            RETURN
        END

    BEGIN TRY
        INSERT INTO S23916715.Product_ProfG_FP
            (name, description, sku)
        VALUES (@name,
                @description,
                @sku)

        -- Set our output variable to the ID of the last inserted ID (scoped)
        SET @inserted_id = SCOPE_IDENTITY();

        PRINT 'Successfully added new product'

    END TRY
    BEGIN CATCH
        PRINT 'Something went wrong when creating new product';
        RETURN
    END CATCH

    SET NOCOUNT OFF

END
</code-block>
