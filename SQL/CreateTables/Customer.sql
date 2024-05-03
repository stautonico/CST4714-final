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
    zip_code         VARCHAR(16)  NOT NULL
)