# Deliverable 2

## ERD

## a. (Table code)

### Invoice
<code-block lang="sql">
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
    deleted     BIT        NOT NULL DEFAULT 0,
    lines       INT        NOT NULL DEFAULT 0,


    FOREIGN KEY (customer) REFERENCES S23916715.Customer_ProfG_FP (id),
    FOREIGN KEY (status) REFERENCES S23916715.InvoiceStatus_ProfG_FP (id)
)
</code-block>

### Variables
<code-block lang="sql">
-- Table used for keeping track of application variables
CREATE TABLE S23916715.Variables_ProfG_FP
(
    id    INT PRIMARY KEY IDENTITY (1,1),
    [key] VARCHAR(128) NOT NULL UNIQUE,
    value VARCHAR(128) NOT NULL
)
</code-block>

### InvoicePaymentRecord
<code-block lang="sql">
CREATE TABLE S23916715.InvoicePaymentRecord_ProfG_FP
(
    id              INT PRIMARY KEY IDENTITY (1,1),
    invoice         INT      NOT NULL,
    amount          INT      NOT NULL,
    date            DATETIME NOT NULL DEFAULT SYSDATETIME(),
    method          INT      NOT NULL,
    payment_account INT      NOT NULL,
    check_num       CHAR(8),

    FOREIGN KEY (invoice) REFERENCES S23916715.Invoice_ProfG_FP (id),
    FOREIGN KEY (method) REFERENCES S23916715.PaymentMethod_ProfG_FP (id),
    FOREIGN KEY (payment_account) REFERENCES S23916715.PaymentAccount_ProfG_FP (id)
)
</code-block>

### InvoiceLine
<code-block lang="sql">
CREATE TABLE S23916715.InvoiceLine_ProfG_FP
(
    id          INT PRIMARY KEY IDENTITY (1,1),
    invoice     INT NOT NULL,
    product     INT NOT NULL,
    price       INT NOT NULL,
    quantity    INT NOT NULL,
    description VARCHAR(1024),
    payment_account INT NOT NULL,

    FOREIGN KEY (invoice) REFERENCES S23916715.Invoice_ProfG_FP (id),
    FOREIGN KEY (product) REFERENCES S23916715.Product_ProfG_FP (id),
    FOREIGN KEY (price) REFERENCES S23916715.Price_ProfG_FP (id),
    FOREIGN KEY (payment_account) REFERENCES S23916715.PaymentAccount_ProfG_FP (id)
)
</code-block>

### PaymentMethod
<code-block lang="sql">
CREATE TABLE S23916715.PaymentMethod_ProfG_FP
(
    id     INT PRIMARY KEY IDENTITY (1,1),
    method VARCHAR(20) NOT NULL, -- Possible values: CHECK, CASH, CREDIT, WIRE, CRYPTO
)
</code-block>

### Price
<code-block lang="sql">
CREATE TABLE S23916715.Price_ProfG_FP
(
    id      INT PRIMARY KEY IDENTITY (1,1),
    amount  INT NOT NULL,
    product INT NOT NULL,

    FOREIGN KEY (product) REFERENCES S23916715.Product_ProfG_FP (id)
)
</code-block>

### Product
<code-block lang="sql">
CREATE TABLE S23916715.Product_ProfG_FP
(
    id          INT PRIMARY KEY IDENTITY (1,1),
    name        VARCHAR(128) NOT NULL,
    description VARCHAR(1024),
    sku         VARCHAR(128) NOT NULL
)
</code-block>

### Customer
<code-block lang="sql">
CREATE TABLE S23916715.Customer_ProfG_FP
(
    id               INT PRIMARY KEY IDENTITY (1,1),
    email            VARCHAR(320) NOT NULL UNIQUE,
    phone_num        VARCHAR(15)  NOT NULL,
    first_name       VARCHAR(128) NOT NULL,
    last_name        VARCHAR(128) NOT NULL,
    address          VARCHAR(128) NOT NULL,
    address_line_two VARCHAR(128),
    city             VARCHAR(128) NOT NULL,
    state            CHAR(2)      NOT NULL,
    zip_code         VARCHAR(16)  NOT NULL,
    deleted          BIT                   DEFAULT 0,
    invoice_count    INT          NOT NULL DEFAULT 0,
    updated          DATETIME              DEFAULT SYSDATETIME()
)
</code-block>

### InvoiceStatus
<code-block lang="sql">
CREATE TABLE S23916715.InvoiceStatus_ProfG_FP
(
    id     INT PRIMARY KEY IDENTITY (1,1),
    status VARCHAR(10) NOT NULL,
)
</code-block>

### PaymentAccount
<code-block lang="sql">
CREATE TABLE S23916715.PaymentAccount_ProfG_FP
(
    id      INT PRIMARY KEY IDENTITY (1,1),
    name    VARCHAR(128) NOT NULL,
    balance INT          NOT NULL DEFAULT 0,
    deleted BIT          NOT NULL DEFAULT 0
)
</code-block>