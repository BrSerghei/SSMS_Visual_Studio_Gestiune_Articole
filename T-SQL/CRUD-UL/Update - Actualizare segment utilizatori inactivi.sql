UPDATE DIM_UTILIZATOR
SET SEGMENT_JSON = JSON_MODIFY(
                       JSON_MODIFY(SEGMENT_JSON,
                           '$.risc_abandon', 'critic'),
                       '$.comportament', 'inactiv_cronic')
WHERE ACTIV = 0
  AND (ULTIMA_AUTENTIFICARE IS NULL
       OR ULTIMA_AUTENTIFICARE < DATEADD(DAY,-90,GETDATE()));
GO
SELECT NUME, PRENUME, ACTIV,
       JSON_VALUE(SEGMENT_JSON,'$.risc_abandon') AS RISC,
       JSON_VALUE(SEGMENT_JSON,'$.comportament') AS COMPORTAMENT
FROM DIM_UTILIZATOR
WHERE ACTIV = 0;
GO