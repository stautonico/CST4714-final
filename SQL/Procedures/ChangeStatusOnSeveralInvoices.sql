CREATE OR ALTER PROCEDURE S23916715.ChangeStatusOnSeveralInvoices_ProfG_FP(
    @status VARCHAR(128),
    @invoice_nums VARCHAR(1024) -- a csv of the invoice numbers
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @status_id INT;

    -- Get (and validate) our status
    SET @status_id = S23916715.GetInvoiceStatusId_ProfF_FP(@status);

    IF @status_id IS NULL
        BEGIN
            PRINT CONCAT(@status, ' is an invalid status')
            RETURN
        END

    -- Split the csv argument into a table for looping
    CREATE TABLE #tableOfIds
    (
        id INT
    );

    INSERT INTO #tableOfIds (id)
    SELECT value
    FROM STRING_SPLIT(@invoice_nums, ',');

    -- Loop through each value in our temporary table and find the invoice, then try to set its status
    DECLARE @id INT;

    BEGIN TRANSACTION [UpdateTransaction]

        BEGIN TRY
            WHILE EXISTS (SELECT * FROM #tableOfIds)
                BEGIN
                    -- Pick an invoice num from the top of our temp table
                    SELECT TOP 1 @id = id FROM #tableOfIds;
                    -- Delete that value so we don't pick it next iteration
                    DELETE FROM #tableOfIds WHERE id = @id;

                    -- Make sure the invoice exists
                    DECLARE @invoice_id INT;

                    SELECT @invoice_id = id FROM S23916715.Invoice_ProfG_FP WHERE num = @id;

                    IF @invoice_id IS NULL
                        BEGIN
                            PRINT CONCAT('Invoice with num ', @id, ' doesn''t exist')
                            RETURN
                        END

                    -- Now that we know it exists, update its status
                    UPDATE S23916715.Invoice_ProfG_FP SET status=@status_id WHERE num = @id;

                END
                
            -- Remove our temporary table
            DROP TABLE #tableOfIds;
        END TRY
        BEGIN CATCH
            PRINT 'Something went wrong when updating invoice'
            ROLLBACK TRANSACTION [UpdateTransaction]
            RETURN
        END CATCH
    COMMIT TRANSACTION [UpdateTransaction]

    SET NOCOUNT OFF
END
