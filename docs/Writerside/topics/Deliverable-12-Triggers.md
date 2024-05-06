# Deliverable 12 (Triggers)

## Override Customer Delete

According to the companies data retention policy, no data can be deleted.
To solve this, the `DELETE` operation is overwritten and replace with setting the `deleted` column to true.

<code-block lang="sql">
CREATE OR ALTER TRIGGER S23916715.DeleteCustomer_Trigger_ProfG_FP
    ON S23916715.Customer_ProfG_FP
    INSTEAD OF DELETE
    AS
BEGIN
    SET NOCOUNT ON;

    UPDATE S23916715.Customer_ProfG_FP
    SET deleted = 1
    FROM S23916715.Customer_ProfG_FP
             INNER JOIN deleted ON S23916715.Customer_ProfG_FP.id = deleted.id;

    SET NOCOUNT OFF;

END;
</code-block>

## Override Invoice Delete

According to the companies data retention policy, no data can be deleted.
To solve this, the `DELETE` operation is overwritten and replace with setting the `deleted` column to true.

<code-block lang="sql">
CREATE OR ALTER TRIGGER S23916715.UpdateInvoices_Trigger_ProfG_FP
    ON S23916715.Invoice_ProfG_FP
    INSTEAD OF DELETE
    AS
BEGIN
    SET NOCOUNT ON;

    UPDATE S23916715.Invoice_ProfG_FP
    SET deleted = 1, updated=SYSDATETIME()
    FROM S23916715.Invoice_ProfG_FP
             INNER JOIN deleted ON S23916715.Invoice_ProfG_FP.id = deleted.id;

    SET NOCOUNT OFF;

END;
</code-block>

## INSERT/UPDATE/DELETE Trigger for Invoice

This trigger runs on all `INSERT`, `UPDATE`, and `DELETE` operations, but has different behavior for each event.
On insert, the associated customer's invoice count is incremented.
On update, the invoice's update field is set to the current timestamp
On delete, the invoice's deleted field is set to true and the update field is set to the current timestamp

<code-block lang="sql">
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
</code-block>

## Customer Update

On update, the customer's updated field is set to the current timestamp

<code-block lang="sql">
CREATE OR ALTER TRIGGER S23916715.CustomerUpdateTrigger_ProfG_FP
    ON S23916715.Customer_ProfG_FP
    AFTER UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    -- When we update a customer, set its `updated` field
    UPDATE S23916715.Customer_ProfG_FP
    SET updated = SYSDATETIME()
    FROM S23916715.Customer_ProfG_FP
             INNER JOIN inserted ON S23916715.Customer_ProfG_FP.id = inserted.id;

    SET NOCOUNT OFF;
END
</code-block>