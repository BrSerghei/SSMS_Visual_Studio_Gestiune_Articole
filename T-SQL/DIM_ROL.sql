CREATE TABLE DIM_ROL (
    ID_ROL           INT            IDENTITY(1,1) NOT NULL
                         CONSTRAINT PK_DIM_ROL PRIMARY KEY,
    DENUMIRE_ROL     VARCHAR(20)    NOT NULL
                         CONSTRAINT CK_ROL_ENUM
                         CHECK (DENUMIRE_ROL IN ('administrator','redactor','cititor')),
    DESCRIERE        TEXT           NULL,
    PERMISIUNI_JSON  NVARCHAR(MAX)  NULL
                         CONSTRAINT CK_ROL_JSON
                         CHECK (ISJSON(PERMISIUNI_JSON) = 1)
);
GO