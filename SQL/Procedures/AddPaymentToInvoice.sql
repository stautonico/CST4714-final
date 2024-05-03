CREATE OR ALTER PROCEDURE S23916715.AddPaymentToInvoice_ProfG_FP(
    @invoice_num INT,
    @amount FLOAT,
    @method VARCHAR(20),
    @check_num VARCHAR(32) = NULL
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

    -- Step 4: Start a transaction for creating the payment record
    -- The reason we need to do this is because if the payment record fully pays off the invoice,
    -- we need to modify the invoice object as well, which could cause problems if something goes wrong
    -- mid-way trough
    BEGIN TRANSACTION [Trans]
        BEGIN TRY
            -- Step 4a: Create the payment record
            INSERT INTO S23916715.InvoicePaymentRecord_ProfG_FP (invoice, amount, method, check_num)
            VALUES (@invoice_id, TRY_CAST(@amount * 100 AS INT), @paymentMethodId,
                    @check_num)

            DECLARE @remaining FLOAT;

            SET @remaining = S23916715.CalculateRemainingBalance_ProfF_FP(@invoice_num)

            IF @remaining <= 0
                BEGIN
                    UPDATE S23916715.Invoice_ProfG_FP SET status = 'PAID', paid=SYSDATETIME() WHERE num = @invoice_num;
                END

            COMMIT TRANSACTION [Trans]
        END TRY
        BEGIN CATCH
            PRINT 'Something went wrong when creating payment record'
            ROLLBACK TRANSACTION [Trans]
            RETURN
        END CATCH

        SET NOCOUNT OFF
END