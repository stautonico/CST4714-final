CREATE TABLE S23916715.InvoiceLine_ProfG_FP
(
    id          INT PRIMARY KEY IDENTITY (1,1),
    invoice     INT NOT NULL,
    product     INT NOT NULL,
    price       INT NOT NULL,
    quantity    INT NOT NULL,
    discount    INT,
    description VARCHAR(1024),

    FOREIGN KEY (invoice) REFERENCES S23916715.Invoice_ProfG_FP (id),
    FOREIGN KEY (product) REFERENCES S23916715.Product_ProfG_FP (id),
    FOREIGN KEY (price) REFERENCES S23916715.Price_ProfG_FP (id),
    FOREIGN KEY (discount) REFERENCES S23916715.Discount_ProfG_FP (id),
)