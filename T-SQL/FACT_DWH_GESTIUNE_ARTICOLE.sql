CREATE TABLE FACT_DWH_GESTIUNE_ARTICOLE (
    ID_FAPT_DWH            INT            IDENTITY(1,1) NOT NULL
                               CONSTRAINT PK_FACT_DWH PRIMARY KEY,
    ID_TIMP                INT            NOT NULL,
    ID_ARTICOL             INT            NOT NULL,
    ID_AUTOR               INT            NOT NULL,
    ID_CATEGORIE           INT            NOT NULL,
    ID_UTILIZATOR          INT            NOT NULL,
    ID_ETICHETA            INT            NOT NULL,
    ID_ROL                 INT            NOT NULL,
    ID_STATUS              INT            NOT NULL,
    NR_VIZUALIZARI         INT            NOT NULL
                               CONSTRAINT DF_FACT_VIZ DEFAULT 0
                               CONSTRAINT CK_FACT_VIZ
                               CHECK (NR_VIZUALIZARI >= 0),
    DURATA_MEDIE_SEC       DECIMAL(10,2)  NULL
                               CONSTRAINT CK_FACT_DUR
                               CHECK (DURATA_MEDIE_SEC >= 0),
    RATA_VIZUALIZARE       DECIMAL(8,4)   NULL
                               CONSTRAINT CK_FACT_RVIZ
                               CHECK (RATA_VIZUALIZARE BETWEEN 0 AND 1),
    NR_ARTICOLE_PUBLICATE  INT            NOT NULL
                               CONSTRAINT DF_FACT_PUB DEFAULT 0
                               CONSTRAINT CK_FACT_PUB
                               CHECK (NR_ARTICOLE_PUBLICATE >= 0),
    NR_ARTICOLE_CREATE     INT            NOT NULL
                               CONSTRAINT DF_FACT_CRE DEFAULT 0
                               CONSTRAINT CK_FACT_CRE
                               CHECK (NR_ARTICOLE_CREATE >= 0),
    RATA_PUBLICARE         DECIMAL(5,4)   NULL
                               CONSTRAINT CK_FACT_RPUB
                               CHECK (RATA_PUBLICARE BETWEEN 0 AND 1),
    NR_COMENTARII          INT            NOT NULL
                               CONSTRAINT DF_FACT_COM DEFAULT 0
                               CONSTRAINT CK_FACT_COM
                               CHECK (NR_COMENTARII >= 0),
    RATA_COMENTARE         DECIMAL(5,4)   NULL
                               CONSTRAINT CK_FACT_RCOM
                               CHECK (RATA_COMENTARE BETWEEN 0 AND 1),
    MEDIE_EVALUARE         DECIMAL(3,2)   NULL
                               CONSTRAINT CK_FACT_MEV
                               CHECK (MEDIE_EVALUARE BETWEEN 1 AND 5),
    NR_ARTICOLE_CATEGORIE  INT            NOT NULL
                               CONSTRAINT DF_FACT_CAT DEFAULT 0
                               CONSTRAINT CK_FACT_CAT
                               CHECK (NR_ARTICOLE_CATEGORIE >= 0),
    NR_VERSIUNI            INT            NOT NULL
                               CONSTRAINT DF_FACT_VER DEFAULT 0
                               CONSTRAINT CK_FACT_VER
                               CHECK (NR_VERSIUNI >= 0),
    RATA_ACTUALIZARE       DECIMAL(5,4)   NULL
                               CONSTRAINT CK_FACT_RACT
                               CHECK (RATA_ACTUALIZARE >= 0),
    NR_SESIUNI_ACTIVE      INT            NOT NULL
                               CONSTRAINT DF_FACT_SES DEFAULT 0
                               CONSTRAINT CK_FACT_SES
                               CHECK (NR_SESIUNI_ACTIVE >= 0),
    RATA_AUTENTIFICARE     DECIMAL(5,4)   NULL
                               CONSTRAINT CK_FACT_RAUT
                               CHECK (RATA_AUTENTIFICARE BETWEEN 0 AND 1),
    RATA_RETENTIE          DECIMAL(5,4)   NULL
                               CONSTRAINT CK_FACT_RRET
                               CHECK (RATA_RETENTIE BETWEEN 0 AND 1),
    KPI_METADATA_JSON      NVARCHAR(MAX)  NULL
                               CONSTRAINT CK_FACT_JSON
                               CHECK (ISJSON(KPI_METADATA_JSON) = 1)
);
GO