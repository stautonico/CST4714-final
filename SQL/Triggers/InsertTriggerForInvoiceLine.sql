CREATE OR ALTER TRIGGER S23916715.InsertTriggerForInvoiceLine_ProfG_FP
    ON S23916715.InvoiceLine_ProfG_FP
    AFTER INSERT
    AS
BEGIN
    SET NOCOUNT ON;

    -- When we insert a new invoice line, update the invoice's line count

    DECLARE @insertedRows INT = @@ROWCOUNT;

    IF @insertedRows > 0
        BEGIN
            UPDATE S23916715.Invoice_ProfG_FP
            SET lines = lines + 1
            FROM S23916715.Invoice_ProfG_FP
                     INNER JOIN inserted ON S23916715.Invoice_ProfG_FP.id = inserted.invoice
            WHERE S23916715.Invoice_ProfG_FP.id = inserted.id;
        END

    SET NOCOUNT OFF;
END;
