CREATE TABLE DIM_ARTICOL (
    ID_ARTICOL        INT            IDENTITY(1,1) NOT NULL
                          CONSTRAINT PK_DIM_ARTICOL PRIMARY KEY,
    TITLU             VARCHAR(255)   NOT NULL,
    SLUG              VARCHAR(255)   NOT NULL,
    STATUS            VARCHAR(20)    NOT NULL
                          CONSTRAINT CK_ART_STATUS
                          CHECK (STATUS IN ('draft','publicat','arhivat')),
    DATA_PUBLICARII   DATETIME       NULL,
    DATA_MODIFICARII  DATETIME       NULL,
    ATRIBUTE_JSON     NVARCHAR(MAX)  NULL
                          CONSTRAINT CK_ART_JSON
                          CHECK (ISJSON(ATRIBUTE_JSON) = 1)
);
GO