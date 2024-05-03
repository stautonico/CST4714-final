-- Get invoices that haven't been modified in at least 30 days
CREATE OR ALTER VIEW S23916715.GetStaleInvoices_ProfG_FP AS
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
-- In theory, this also checks if the date is >= 30 days in the future, but the updated field
-- should never be in the future so it doesn't really matter
WHERE DATEDIFF(DAY, i.updated, GETDATE()) >= 30