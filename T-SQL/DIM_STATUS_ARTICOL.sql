USE DWH_GestionareArticole;
GO
CREATE TABLE DIM_STATUS_ARTICOL (
    ID_STATUS        INT            IDENTITY(1,1) NOT NULL
                         CONSTRAINT PK_DIM_STATUS PRIMARY KEY,
    DENUMIRE_STATUS  VARCHAR(50)    NOT NULL
                         CONSTRAINT CK_STATUS_ENUM
                         CHECK (DENUMIRE_STATUS IN ('draft','publicat','arhivat')),
    DESCRIERE        TEXT           NULL,
    REGULI_JSON      NVARCHAR(MAX)  NULL
                         CONSTRAINT CK_STATUS_JSON
                         CHECK (ISJSON(REGULI_JSON) = 1)
);
GO