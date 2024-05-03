CREATE OR ALTER VIEW S23916715.CustomersThatHaveUnpaidInvoices_ProfG_FP AS
SELECT c.id, c.masked_email, c.masked_phone_number, c.first_name, c.last_name, COUNT(i.id) AS unpaid_invoice_count
FROM S23916715.View_Customers_ProfG_FP c
LEFT JOIN S23916715.Invoice_ProfG_FP i ON c.id = i.customer
WHERE i.status NOT IN ('PAID', 'DRAFT', 'CANCELED') OR i.id IS NULL
GROUP BY c.id, c.masked_email, c.masked_phone_number, c.first_name, c.last_name;
