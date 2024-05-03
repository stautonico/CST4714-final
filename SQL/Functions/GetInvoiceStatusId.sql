CREATE OR ALTER FUNCTION S23916715.GetInvoiceStatusId_ProfF_FP(@status VARCHAR(128))
    RETURNS INT
AS
BEGIN
    -- Try to find the status by the value
    DECLARE @status_id INT;

    SELECT @status_id = id FROM S23916715.InvoiceStatus_ProfG_FP WHERE status = @status;

    RETURN @status_id;
END