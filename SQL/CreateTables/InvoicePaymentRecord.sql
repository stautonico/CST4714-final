CREATE TABLE S23916715.InvoicePaymentRecord_ProfG_FP
(
    id        INT PRIMARY KEY IDENTITY (1,1),
    invoice   INT      NOT NULL,
    amount    INT      NOT NULL,
    date      DATETIME NOT NULL DEFAULT SYSDATETIME(),
    method    INT      NOT NULL,
    check_num CHAR(8),

    FOREIGN KEY (invoice) REFERENCES S23916715.Invoice_ProfG_FP (id),
    FOREIGN KEY (method) REFERENCES S23916715.PaymentMethod_ProfG_FP (id)
)