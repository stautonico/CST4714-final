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
CREATE OR ALTER TRIGGER S23916715.OverrideDeleteInvoice_Trigger_ProfG_FP
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

## Insert Trigger for Invoice Line

When adding a new line to an invoice, increment that invoice's line count

<code-block lang="sql">
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

</code-block>

## Delete Payment Account

When the payment account is deleted, instead mark it as deleted

<code-block lang="sql">
CREATE OR ALTER TRIGGER S23916715.OverrideDeletePaymentAccount_Trigger_ProfG_FP
    ON S23916715.PaymentAccount_ProfG_FP
    INSTEAD OF DELETE
    AS
BEGIN
    SET NOCOUNT ON;

    UPDATE S23916715.PaymentAccount_ProfG_FP
    SET deleted = 1
    FROM S23916715.PaymentAccount_ProfG_FP
             INNER JOIN deleted ON S23916715.PaymentAccount_ProfG_FP.id = deleted.id;

    SET NOCOUNT OFF;
END;
</code-block>

## Insert Invoice Line

When inserting an invoice line, update its invoice's line count

<code-block lang="sql">
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
</code-block>

## Update Invoice Payment Record

When updating an invoice payment record, we need to make sure that the balance on the associated payment account
matches.
To solve this, after updating a payment record, we subtract the original value from the account and then add the new
value

<code-block lang="sql">
CREATE OR ALTER TRIGGER S23916715.UpdateTriggerForInvoicePaymentRecord_ProfG_FP
    ON S23916715.InvoicePaymentRecord_ProfG_FP
    AFTER UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    -- We don't need to use a transactions because triggers are already run in the context of a transaction
    -- When we update a invoice payment record, we need to correct our total balance in our payment account
    BEGIN TRY
        -- Subtract the old amount
        UPDATE S23916715.PaymentAccount_ProfG_FP
        SET balance = balance - (SELECT amount FROM deleted)
        WHERE id = (SELECT payment_account FROM deleted);

        -- Add the new amount
        UPDATE S23916715.PaymentAccount_ProfG_FP
        SET balance = balance + (SELECT amount FROM inserted)
        WHERE id = (SELECT payment_account FROM inserted);

    END TRY
    BEGIN CATCH
        PRINT 'Something went wrong when updating payment account'
        RETURN
    END CATCH

    SET NOCOUNT OFF;
END
</code-block>