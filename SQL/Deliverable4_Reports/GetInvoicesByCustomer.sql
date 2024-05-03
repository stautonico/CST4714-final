CREATE OR ALTER PROCEDURE S23916715.GetInvoicesByCustomer_ProfG_FP(
    @customer_email VARCHAR(320) = NULL,
    @customer_id INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON
    -- We need either the email or the id, not both, not neither
    IF @customer_email IS NULL AND @customer_id IS NULL
        BEGIN
            PRINT 'Please provide either the customer email or the customer id';
            RETURN
        END

    IF @customer_email IS NOT NULL AND @customer_id IS NOT NULL
        BEGIN
            PRINT 'Please provide either the customer email or the customer id but not both';
            RETURN
        END

    -- Check if the customer exists
    DECLARE @findCustomerCount INT;
    SELECT @findCustomerCount = COUNT(*)
    FROM S23916715.Customer_ProfG_FP
    WHERE (@customer_email IS NOT NULL AND email = @customer_email)
       OR (@customer_id IS NOT NULL AND id = @customer_id);

    IF @findCustomerCount = 0
        BEGIN
            PRINT 'Customer does not exist'
            RETURN
        END


    SELECT i.id                        AS InvoiceID,
           i.num                       AS InvoiceNumber,
           i.created                   AS InvoiceCreated,
           i.updated                   AS InvoiceUpdated,
           i.status                    AS InvoiceStatus,
           i.description               AS InvoiceDescription,
           c.id                        AS CustomerID,
           maskedCustomer.masked_email AS CustomerEmail,
           c.first_name                AS CustomerFirstName,
           c.last_name                 AS CustomerLastName
    FROM S23916715.Invoice_ProfG_FP AS i
             INNER JOIN
         S23916715.Customer_ProfG_FP AS c ON i.customer = c.id
             INNER JOIN View_Customers_ProfG_FP AS maskedCustomer ON i.customer = maskedCustomer.id
    WHERE (@customer_email IS NOT NULL AND c.email = @customer_email)
       OR (@customer_id IS NOT NULL AND c.id = @customer_id);

    SET NOCOUNT OFF
END
