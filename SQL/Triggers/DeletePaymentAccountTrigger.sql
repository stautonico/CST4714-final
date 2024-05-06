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
