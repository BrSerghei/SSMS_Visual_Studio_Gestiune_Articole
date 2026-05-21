UPDATE DIM_AUTOR
SET PROFIL_JSON = JSON_MODIFY(
                     JSON_MODIFY(PROFIL_JSON,
                         '$.tinta_lunara', 10),
                     '$.experienta_ani', 5)
WHERE NUME = 'Ciobanu' AND PRENUME = 'Maria';
GO
SELECT NUME, PRENUME,
       JSON_VALUE(PROFIL_JSON,'$.tinta_lunara')  AS TINTA_NOUA,
       JSON_VALUE(PROFIL_JSON,'$.experienta_ani') AS EXP_ANI
FROM DIM_AUTOR
WHERE NUME = 'Ciobanu';
GO