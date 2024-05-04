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
