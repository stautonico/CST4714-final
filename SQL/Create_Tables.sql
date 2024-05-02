CREATE TABLE S23916715.Invoice_ProfG_FP
(
    id          INT PRIMARY KEY IDENTITY (1,1),
    num         INT UNIQUE  NOT NULL,
    created     DATETIME    NOT NULL DEFAULT SYSDATETIME(),
    updated     DATETIME    NOT NULL DEFAULT SYSDATETIME(),
    status      VARCHAR(10) NOT NULL DEFAULT 'DRAFT', -- Possible values: DRAFT, PAID, SENT, OVERDUE, CANCELED
    customer    INT         NOT NULL,
    description varchar(1024),

    FOREIGN KEY (customer) REFERENCES S23916715.Customer_ProfG_FP (id)
)

-- Table used for keeping track of application variables
CREATE TABLE S23916715.Variables_ProfgG_FP (
    id INT PRIMARY KEY IDENTITY (1,1),
    [key] VARCHAR(128) NOT NULL UNIQUE,
    value VARCHAR(128) NOT NULL
)

CREATE TABLE S23916715.Customer_ProfG_FP
(
    id               INT PRIMARY KEY IDENTITY (1,1),
    email            VARCHAR(320) NOT NULL UNIQUE,
    phone_num        VARCHAR(12)  NOT NULL,
    first_name       VARCHAR(128) NOT NULL,
    last_name        VARCHAR(128) NOT NULL,
    address          VARCHAR(128) NOT NULL,
    address_line_two VARCHAR(128),
    city             VARCHAR(128) NOT NULL,
    state            CHAR(2)      NOT NULL,
    zip_code         VARCHAR(16)  NOT NULL
)

CREATE TABLE S23916715.InvoicePaymentRecord_ProfG_FP
(
    id        INT PRIMARY KEY IDENTITY (1,1),
    invoice   INT      NOT NULL,
    amount    INT      NOT NULL,
    date      DATETIME NOT NULL DEFAULT SYSDATETIME(),
    method    INT      NOT NULL,
    check_num VARCHAR(32),

    FOREIGN KEY (invoice) REFERENCES S23916715.Invoice_ProfG_FP (id),
    FOREIGN KEY (method) REFERENCES S23916715.PaymentMethod_ProfG_FP (id)
)

CREATE TABLE S23916715.PaymentMethod_ProfG_FP
(
    id     INT PRIMARY KEY IDENTITY (1,1),
    method VARCHAR(20) NOT NULL, -- Possible values: CHECK, CASH, CREDIT, WIRE, CRYPTO
)

CREATE TABLE S23916715.Product_ProfG_FP
(
    id          INT PRIMARY KEY IDENTITY (1,1),
    name        VARCHAR(128) NOT NULL,
    description VARCHAR(1024),
    sku         VARCHAR(128) NOT NULL
)

CREATE TABLE S23916715.Price_ProfG_FP
(
    id      INT PRIMARY KEY IDENTITY (1,1),
    amount  INT NOT NULL,
    product INT NOT NULL,

    FOREIGN KEY (product) REFERENCES S23916715.Product_ProfG_FP (id)
)

CREATE TABLE S23916715.Discount_ProfG_FP
(
    id     INT PRIMARY KEY IDENTITY (1,1),
    amount INT NOT NULL,
    type   INT NOT NULL,

    FOREIGN KEY (type) REFERENCES S23916715.DiscountType_ProfG_FP (id)

)

CREATE TABLE S23916715.DiscountType_ProfG_FP
(
    id   INT PRIMARY KEY IDENTITY (1,1),
    type VARCHAR(7) -- Possible values: FIXED/PERCENT
)

CREATE TABLE S23916715.InvoiceLine_ProfG_FP
(
    id          INT PRIMARY KEY IDENTITY (1,1),
    invoice     INT NOT NULL,
    product     INT NOT NULL,
    price       INT NOT NULL,
    quantity    INT NOT NULL,
    discount    INT NOT NULL,
    description VARCHAR(1024),

    FOREIGN KEY (invoice) REFERENCES S23916715.Invoice_ProfG_FP (id),
    FOREIGN KEY (product) REFERENCES S23916715.Product_ProfG_FP (id),
    FOREIGN KEY (price) REFERENCES S23916715.Price_ProfG_FP (id),
    FOREIGN KEY (discount) REFERENCES S23916715.Discount_ProfG_FP (id),
)

-- TODO: IDK if I like this so I might remove it, we'll see
CREATE TABLE S23916715.Revision_ProfG_FP
(
    id        INT PRIMARY KEY IDENTITY (1,1),
    invoice   INT      NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT SYSDATETIME(),
    -- user?
)

CREATE TABLE S23916715.RevisionLine_ProfG_FP
(
    id          INT PRIMARY KEY IDENTITY (1,1),
    revision    INT           NOT NULL,
    description VARCHAR(1024),
    field       VARCHAR(64)   NOT NULL,
    old_value   VARCHAR(1024) NOT NULL,
    new_value   VARCHAR(1024) NOT NULL
        FOREIGN KEY (revision) REFERENCES S23916715.Revision_ProfG_FP (id)
)