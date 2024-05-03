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