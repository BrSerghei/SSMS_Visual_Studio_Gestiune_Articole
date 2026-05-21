CREATE TABLE DIM_CATEGORIE (
    ID_CATEGORIE      INT            IDENTITY(1,1) NOT NULL
                          CONSTRAINT PK_DIM_CATEGORIE PRIMARY KEY,
    NUME_CATEGORIE    VARCHAR(100)   NOT NULL,
    CATEGORIE_PARINTE INT            NULL,
    ACTIVA            TINYINT        NOT NULL
                          CONSTRAINT DF_CATEG_ACTIVA DEFAULT 1
                          CONSTRAINT CK_CATEG_ACTIVA
                          CHECK (ACTIVA IN (0, 1)),
    META_JSON         NVARCHAR(MAX)  NULL
                          CONSTRAINT CK_CATEG_JSON
                          CHECK (ISJSON(META_JSON) = 1)
);
GO