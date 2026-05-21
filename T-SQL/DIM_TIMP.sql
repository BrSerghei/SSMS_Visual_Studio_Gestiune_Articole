CREATE TABLE DIM_TIMP (
    ID_TIMP              INT           NOT NULL
                             CONSTRAINT PK_DIM_TIMP PRIMARY KEY,
    DATA_COMPLETA        DATE          NOT NULL,
    ZI                   INT           NOT NULL
                             CONSTRAINT CK_TIMP_ZI
                             CHECK (ZI BETWEEN 1 AND 31),
    LUNA                 INT           NOT NULL
                             CONSTRAINT CK_TIMP_LUNA
                             CHECK (LUNA BETWEEN 1 AND 12),
    DENUMIRE_LUNA        VARCHAR(15)   NOT NULL,
    TRIMESTRU            INT           NOT NULL
                             CONSTRAINT CK_TIMP_TRIM
                             CHECK (TRIMESTRU BETWEEN 1 AND 4),
    SEMESTRU             INT           NOT NULL
                             CONSTRAINT CK_TIMP_SEM
                             CHECK (SEMESTRU IN (1, 2)),
    AN                   INT           NOT NULL,
    ZI_SAPTAMANA         VARCHAR(15)   NOT NULL,
    ESTE_ZI_LUCRATOARE   TINYINT       NOT NULL
                             CONSTRAINT DF_TIMP_Zlucr DEFAULT 1
                             CONSTRAINT CK_TIMP_Zlucr
                             CHECK (ESTE_ZI_LUCRATOARE IN (0, 1))
);
GO