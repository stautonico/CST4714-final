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
