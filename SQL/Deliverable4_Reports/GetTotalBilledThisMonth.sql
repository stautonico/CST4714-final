CREATE OR ALTER VIEW S23916715.GetTotalBilledThisMonth_ProfG_FP AS
SELECT i.id                                                 AS InvoiceID,
       i.num                                                AS InvoiceNumber,
       i.created                                            AS InvoiceCreated,
       i.updated                                            AS InvoiceUpdated,
       i.status                                             AS InvoiceStatus,
       i.description                                        AS InvoiceDescription,
       maskedCustomer.masked_email                          AS CustomerEmail,
       c.first_name                                         AS CustomerFirstName,
       c.last_name                                          AS CustomerLastName,
       -- We store all money amounts as ints (aka x100) since computers make floating point mistakes.
       -- When we want to display a money amount, we have to divide by 100
       TRY_CAST(SUM(il.quantity * p.amount) AS FLOAT) / 100 AS Total
FROM S23916715.Invoice_ProfG_FP AS i
         INNER JOIN S23916715.Customer_ProfG_FP AS c ON i.customer = c.id
         INNER JOIN View_Customers_ProfG_FP AS maskedCustomer ON i.customer = maskedCustomer.id
         INNER JOIN S23916715.InvoiceLine_ProfG_FP AS il ON i.id = il.invoice
         INNER JOIN S23916715.Price_ProfG_FP AS p ON il.price = p.id
GROUP BY i.id, i.num, i.created, i.updated, i.status, i.description, maskedCustomer.masked_email,
         c.first_name, c.last_name;