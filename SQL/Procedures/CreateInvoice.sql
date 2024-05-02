CREATE OR ALTER PROCEDURE S23916715.InitializeInvoice_ProfG_FP(
    @customer_email VARCHAR(320),
    @invoice_num INT = NULL,
    @description VARCHAR(1024) = NULL,
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

    SELECT @numVar = value FROM S23916715.Variables_ProfgG_FP WHERE [key] = 'invoice_accumulator';

    IF @numVar IS NULL
        BEGIN
            -- We haven't started accumulating invoice numbers yet, so start from 1
            INSERT INTO S23916715.Variables_ProfgG_FP ([key], value) VALUES ('invoice_accumulator', '1');
            SET @invoice_num = 1;
        END
    ELSE
        BEGIN
            -- Convert the value to a INT
            SET @invoice_num = TRY_CAST(@numVar AS INT) + 1
            -- Now increment our accumulator in the database
            UPDATE S23916715.Variables_ProfgG_FP
            SET value=TRY_CAST(@invoice_num AS VARCHAR)
            WHERE [key] = 'invoice_accumulator';
        END

    -- Step 3: Insert the new invoice
    BEGIN TRY
        INSERT INTO S23916715.Invoice_ProfG_FP
            (num, customer, description)
        VALUES (@invoice_num, @customerID, @description);

        -- Set our output variable to the ID of the last inserted ID (scoped)
        SET @inserted_id = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        PRINT 'Something went wrong when initializing new invoice'
        RETURN
    END CATCH

    SET NOCOUNT OFF
END