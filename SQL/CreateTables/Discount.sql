CREATE TABLE S23916715.Discount_ProfG_FP
(
    id     INT PRIMARY KEY IDENTITY (1,1),
    amount INT NOT NULL,
    type   INT NOT NULL,

    FOREIGN KEY (type) REFERENCES S23916715.DiscountType_ProfG_FP (id)
)