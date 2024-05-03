SELECT * FROM GetTotalBilledThisMonth_ProfG_FP;

SELECT SUM(Total) AS GrandTotal FROM (
    SELECT
           SUM(il.quantity * p.amount) AS Total
    FROM S23916715.Invoice_ProfG_FP AS i
             INNER JOIN S23916715.InvoiceLine_ProfG_FP AS il ON i.id = il.invoice
             INNER JOIN S23916715.Price_ProfG_FP AS p ON il.price = p.id) AS Invoices;

