EXEC View_GetInvoicePayments_ProfG_FP 198;


SELECT * FROM Invoice_ProfG_FP WHERE id in (1,2,3,4,5,6,7,8,9,10);

EXEC S23916715.ChangeStatusOnSeveralInvoices_ProfG_FP 'DRAFT', '1,2,3,4,5,6,7,8,9,10'

UPDATE Invoice_ProfG_FP SET description='test' WHERE id =1;

SELECT * FROM Invoice_ProfG_FP;

DELETE FROM S23916715.Invoice_ProfG_FP WHERE id = 1;


SELECT * FROM Customer_ProfG_FP;

UPDATE Customer_ProfG_FP SET email = 'hahfunny@gmail.com' WHERE id = 1;


SELECT * FROM Customer_ProfG_FP;

EXEC CreateNewCustomer_ProfG_FP
     @email = '@',
     @phone_num = '123-456-7890',
     @first_name = 'Steve',
     @last_name = 'Tautonico',
     @address = '123-467 8th Street',
     @address_line_two = NULL,
     @city = 'City',
     @state = 'NY',
     @zip_code = '12345',
     @inserted_id = NULL