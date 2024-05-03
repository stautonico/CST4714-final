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