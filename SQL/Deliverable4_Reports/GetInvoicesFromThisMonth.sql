CREATE OR ALTER PROCEDURE S23916715.GetInvoicesFromThisMonth_ProfG_FP(
    @status VARCHAR(10) = NULL
)
AS
BEGIN
    SET NOCOUNT ON

    -- Select all invoices that have a creation date that is within the last 30 days
    -- Optionally, include the status if it was provided

    SELECT i.id          AS InvoiceID,
           i.num         AS InvoiceNumber,
           i.created     AS InvoiceCreated,
           i.updated     AS InvoiceUpdated,
           i.status      AS InvoiceStatus,
           i.description AS InvoiceDescription,
           c.id          AS CustomerID,
           c.email       AS CustomerEmail,
           c.first_name  AS CustomerFirstName,
           c.last_name   AS CustomerLastName
    FROM S23916715.Invoice_ProfG_FP AS i
             INNER JOIN
         S23916715.Customer_ProfG_FP AS c ON i.customer = c.id
    WHERE YEAR(created) = YEAR(GETDATE())
      AND MONTH(created) = MONTH(GETDATE())
      -- I'm pretty sure this server is configured to be case-insensitive,
      -- so we don't need to worry about changing the case (the db should store all upper case)
      AND (@status IS NULL OR status = S23916715.GetInvoiceStatusId_ProfF_FP(@status))
      AND i.deleted = 0;

    SET NOCOUNT OFF
END