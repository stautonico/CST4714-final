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