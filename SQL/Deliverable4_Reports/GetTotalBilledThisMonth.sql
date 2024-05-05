CREATE OR ALTER VIEW S23916715.GetTotalBilledThisMonth_ProfG_FP AS
SELECT CONVERT(FLOAT, SUM(CONVERT(BIGINT, Total))) / 100 AS GrandTotal
FROM (SELECT SUM(CONVERT(BIGINT, il.quantity * p.amount)) AS Total
      FROM S23916715.Invoice_ProfG_FP AS i
               INNER JOIN S23916715.InvoiceLine_ProfG_FP AS il ON i.id = il.invoice
               INNER JOIN S23916715.Price_ProfG_FP AS p ON il.price = p.id
      WHERE YEAR(created) = YEAR(GETDATE())
        AND MONTH(created) = MONTH(GETDATE())
        AND status != 'CANCELLED'
      AND deleted = 0
) AS Invoices;