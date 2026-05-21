CREATE TABLE DIM_UTILIZATOR (
    ID_UTILIZATOR         INT            IDENTITY(1,1) NOT NULL
                              CONSTRAINT PK_DIM_UTILIZATOR PRIMARY KEY,
    NUME                  VARCHAR(50)    NOT NULL,
    PRENUME               VARCHAR(50)    NOT NULL,
    ROL                   VARCHAR(20)    NOT NULL
                              CONSTRAINT CK_UTIL_ROL
                              CHECK (ROL IN ('administrator','redactor','cititor')),
    ACTIV                 TINYINT        NOT NULL
                              CONSTRAINT DF_UTIL_ACTIV DEFAULT 1
                              CONSTRAINT CK_UTIL_ACTIV
                              CHECK (ACTIV IN (0, 1)),
    DATA_INREGISTRARE     DATETIME       NOT NULL,
    ULTIMA_AUTENTIFICARE  DATETIME       NULL,
    SEGMENT_JSON          NVARCHAR(MAX)  NULL
                              CONSTRAINT CK_UTIL_JSON
                              CHECK (ISJSON(SEGMENT_JSON) = 1)
);
GO