CREATE TABLE S23916715.Invoice_ProfG_FP
(
    id          INT PRIMARY KEY IDENTITY (1,1),
    num         INT UNIQUE NOT NULL,
    created     DATETIME   NOT NULL DEFAULT SYSDATETIME(),
    updated     DATETIME   NOT NULL DEFAULT SYSDATETIME(),
    due         DATE       NOT NULL DEFAULT DATEADD(DAY, 30, GETDATE()),
    paid        DATETIME, -- The timestamp when the invoice was paid
    status      INT        NOT NULL,
    customer    INT        NOT NULL,
    description VARCHAR(1024),

    FOREIGN KEY (customer) REFERENCES S23916715.Customer_ProfG_FP (id),
    FOREIGN KEY (status) REFERENCES S23916715.InvoiceStatus_ProfG_FP (id)
)