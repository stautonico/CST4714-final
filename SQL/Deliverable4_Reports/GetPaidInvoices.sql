CREATE OR ALTER PROCEDURE S23916715.GetPaidInvoices(
    @asJson BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #PaidInvoices
    (
        InvoiceID          INT,
        InvoiceNumber      INT,
        InvoiceCreated     DATETIME,
        InvoiceUpdated     DATETIME,
        InvoiceStatus      VARCHAR(10),
        InvoiceDescription VARCHAR(1024),
        CustomerID         INT,
        CustomerEmail      VARCHAR(320),
        CustomerFirstName  VARCHAR(128),
        CustomerLastName   VARCHAR(128)
    )

    INSERT INTO #PaidInvoices (InvoiceID, InvoiceNumber, InvoiceCreated, InvoiceUpdated, InvoiceStatus,
                               InvoiceDescription, CustomerID, CustomerEmail, CustomerFirstName, CustomerLastName)
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
    WHERE i.status = S23916715.GetInvoiceStatusId_ProfF_FP('PAID');

    IF @asJson = 1
        BEGIN
            -- This is what happens when we're not allowed to use * :(
            SELECT InvoiceID,
                   InvoiceNumber,
                   InvoiceCreated,
                   InvoiceUpdated,
                   InvoiceStatus,
                   InvoiceDescription,
                   CustomerID,
                   CustomerEmail,
                   CustomerFirstName,
                   CustomerLastName
            FROM #PaidInvoices
            FOR JSON PATH;
        END
    ELSE
        BEGIN
            -- This is what happens when we're not allowed to use * :(
            SELECT InvoiceID,
                   InvoiceNumber,
                   InvoiceCreated,
                   InvoiceUpdated,
                   InvoiceStatus,
                   InvoiceDescription,
                   CustomerID,
                   CustomerEmail,
                   CustomerFirstName,
                   CustomerLastName
            FROM #PaidInvoices;
        END

    DROP TABLE #PaidInvoices;

    SET NOCOUNT OFF
END
