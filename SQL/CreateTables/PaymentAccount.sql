CREATE TABLE S23916715.PaymentAccount_ProfG_FP
(
    id      INT PRIMARY KEY IDENTITY (1,1),
    name    VARCHAR(128) NOT NULL,
    balance INT          NOT NULL DEFAULT 0,
    deleted BIT          NOT NULL DEFAULT 0
)