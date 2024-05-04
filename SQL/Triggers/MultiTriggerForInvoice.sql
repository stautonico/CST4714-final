CREATE OR ALTER TRIGGER S23916715.MultiTriggerForInvoice_ProfG_FP
    ON S23916715.Invoice_ProfG_FP
    AFTER INSERT, UPDATE, DELETE
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @eventType VARCHAR(10);

    -- Grab the event type so we can run some code conditionally
    SET @eventType = CASE
                         WHEN EXISTS (SELECT * FROM INSERTED) THEN 'INSERT'
                         WHEN EXISTS (SELECT * FROM DELETED) THEN 'DELETE'
                         ELSE 'UPDATE'
        END;

    IF @eventType = 'INSERT'
        BEGIN
            -- When we insert new records, find the customer and increment their invoice count
            DECLARE @insertedRows INT = @@ROWCOUNT;

            IF @insertedRows > 0
                BEGIN
                    UPDATE S23916715.Customer_ProfG_FP
                    SET invoice_count = invoice_count + 1
                    FROM S23916715.Invoice_ProfG_FP AS inv
                             INNER JOIN S23916715.Customer_ProfG_FP AS cust ON inv.customer = cust.id;
                END
        END

    ELSE
        IF @eventType = 'UPDATE'
            -- When we update an invoice, set its `updated` field
            BEGIN
                UPDATE S23916715.Invoice_ProfG_FP
                SET updated = SYSDATETIME()
                FROM S23916715.Invoice_ProfG_FP
                         INNER JOIN inserted ON S23916715.Invoice_ProfG_FP.id = inserted.id;
            END

        ELSE
            IF @eventType = 'DELETE'
                -- When we delete an invoice, instead mark it as deleted (and set its updated field)
                BEGIN
                    UPDATE S23916715.Invoice_ProfG_FP
                    SET deleted = 1 -- Set a flag indicating that the file was marked 'deleted'
                    FROM deleted AS d
                    WHERE S23916715.Invoice_ProfG_FP.id = d.id;
                END

    SET NOCOUNT OFF;
END
