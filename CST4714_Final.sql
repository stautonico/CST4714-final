DECLARE @lastInsertedID INT;

EXEC S23916715.InitializeInvoice_ProfG_FP
@customer_email = 'stautonico@gmail.com', @inserted_id = @lastInsertedID OUT, @description = 'This is my invoice description';

SELECT * FROM S23916715.Invoice_ProfG_FP;

SELECT * FROM Variables_ProfgG_FP;


EXEC S23916715.GetInvoicesByCustomer_ProfG_FP @customer_id = 8