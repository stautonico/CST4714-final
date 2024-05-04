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
