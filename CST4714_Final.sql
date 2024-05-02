EXEC S23916715.InitializeInvoice_ProfG_FP
     @customer_email = 'stautonico@gmail.com',
     @inserted_id = @lastInsertedID OUT,
     @description = 'This is my invoice description',
     @due_days = 120;

SELECT *
FROM S23916715.Invoice_ProfG_FP;

SELECT *
FROM Variables_ProfgG_FP;

SELECT *
FROM Product_ProfG_FP;

EXEC S23916715.GetInvoicesFromThisMonth_ProfG_FP @status = 'dRaFt';

EXEC S23916715.GetInvoicesByCustomer_ProfG_FP @customer_id = 8

DECLARE @lastInsertedID INT;

EXEC S23916715.AddNewLineToInvoice_ProfG_FP
     @invoice_num = 5,
     @product_name = 'Web Design Services',
    @product_sku = 'product-002',
     @price_id = 4,
     @quantity = 10,
     @discount_id = 2,
     @description = 'My description',
     @inserted_id = @lastInsertedID OUT