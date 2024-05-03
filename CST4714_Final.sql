SELECT *
FROM GetTotalBilledThisMonth_ProfG_FP;


UPDATE S23916715.Invoice_ProfG_FP
SET status = 'CANCELLED'
WHERE id IN (1, 2, 3, 4, 5, 6, 8, 10, 12, 23, 38)


DECLARE @totalValue FLOAT;

SET @totalValue = S23916715.CalculateRemainingBalance_ProfF_FP(36);

SELECT @totalValue

EXECUTE GetInvoiceByNum_ProfG_FP 36

SELECT *
FROM InvoicePaymentRecord_ProfG_FP
WHERE invoice = 37


EXEC CreateNewCustomer_ProfG_FP @email = 'stautonico@gmail.com', @phone_num = '123-467-7890', @first_name = 'Steve',
     @last_name = 'Tautonico', @address = '1234', @address_line_two = NULL, @city = 'City', @state = 'NY',
     @zip_code = '12345', @inserted_id = NULL;


EXEC InitializeInvoice_ProfG_FP @customer_email = 'stautonico@gmail.com', @inserted_id = NULL;

SELECT * FROM Invoice_ProfG_FP;

EXEC GetInvoiceByNum_ProfG_FP 1;

EXEC AddNewLineToInvoice_ProfG_FP @invoice_num = 1, @product_name = 'Product 1', @product_sku = 'SKU-001', @price_id = 1, @quantity = 2, @inserted_id = NULL

INSERT INTO Price_ProfG_FP (amount, product) VALUES (12346, 1);

EXEC CreateNewProduct_ProfG_FP @name = 'Product 1', @sku = 'SKU-001', @inserted_id = NULL

EXEC AddPaymentToInvoice_ProfG_FP 1, 46.92, 'CHECK', '12346789'

INSERT INTO PaymentMethod_ProfG_FP (method) VALUES ('CHECK')

DECLARE @remaining FLOAT;

SET @remaining = S23916715.CalculateRemainingBalance_ProfF_FP(138)

SELECT @remaining;

SELECT * FROM Invoice_ProfG_FP WHERE num = 1;

SELECT * FROM InvoicePaymentRecord_ProfG_FP;

