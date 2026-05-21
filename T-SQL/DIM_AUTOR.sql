CREATE TABLE DIM_AUTOR (
    ID_AUTOR           INT            IDENTITY(1,1) NOT NULL
                           CONSTRAINT PK_DIM_AUTOR PRIMARY KEY,
    NUME               VARCHAR(50)    NOT NULL,
    PRENUME            VARCHAR(50)    NOT NULL,
    EMAIL              VARCHAR(100)   NOT NULL,
    ROL                VARCHAR(20)    NOT NULL
                           CONSTRAINT CK_AUTOR_ROL
                           CHECK (ROL IN ('administrator','redactor')),
    DATA_INREGISTRARE  DATETIME       NOT NULL,
    PROFIL_JSON        NVARCHAR(MAX)  NULL
                           CONSTRAINT CK_AUTOR_JSON
                           CHECK (ISJSON(PROFIL_JSON) = 1)
);
GO