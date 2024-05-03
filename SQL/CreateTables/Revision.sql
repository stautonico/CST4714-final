-- TODO: IDK if I like this so I might remove it, we'll see
CREATE TABLE S23916715.Revision_ProfG_FP
(
    id        INT PRIMARY KEY IDENTITY (1,1),
    invoice   INT      NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT SYSDATETIME(),
    -- user?
)