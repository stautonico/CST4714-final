EXEC AddPaymentToInvoice_ProfG_FP
     @invoice_num = 11,
     @amount = 300,
     @method = 'CHECK',
     @check_num = '12345678',
     @payment_account = 1

EXEC View_GetInvoicePayments_ProfG_FP @invoice_num = 11;

EXEC GetInvoiceByNum_ProfG_FP 11;



SELECT id, status FROM InvoiceStatus_ProfG_FP WHERE id = 2;

SELECT name, balance FROM PaymentAccount_ProfG_FP WHERE id = 1;


SELECT * FROM PaymentAccount_ProfG_FP;