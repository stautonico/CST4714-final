CREATE TABLE S23916715.PaymentMethod_ProfG_FP
(
    id     INT PRIMARY KEY IDENTITY (1,1),
    method VARCHAR(20) NOT NULL, -- Possible values: CHECK, CASH, CREDIT, WIRE, CRYPTO
)