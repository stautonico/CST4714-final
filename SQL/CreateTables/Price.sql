CREATE TABLE S23916715.Price_ProfG_FP
(
    id      INT PRIMARY KEY IDENTITY (1,1),
    amount  INT NOT NULL,
    product INT NOT NULL,

    FOREIGN KEY (product) REFERENCES S23916715.Product_ProfG_FP (id)
)