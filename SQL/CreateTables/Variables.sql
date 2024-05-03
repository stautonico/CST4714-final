-- Table used for keeping track of application variables
CREATE TABLE S23916715.Variables_ProfG_FP
(
    id    INT PRIMARY KEY IDENTITY (1,1),
    [key] VARCHAR(128) NOT NULL UNIQUE,
    value VARCHAR(128) NOT NULL
)