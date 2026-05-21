UPDATE DIM_CATEGORIE
SET META_JSON = JSON_MODIFY(
                    JSON_MODIFY(META_JSON,
                        '$.obiectiv_lunar', 15),
                    '$.prioritate_strategica', 'foarte_ridicata')
WHERE NUME_CATEGORIE = 'Tehnologie';
GO

SELECT NUME_CATEGORIE,
       JSON_VALUE(META_JSON,'$.obiectiv_lunar')        AS OBIECTIV_NOU,
       JSON_VALUE(META_JSON,'$.prioritate_strategica') AS PRIORITATE_NOUA
FROM DIM_CATEGORIE
WHERE NUME_CATEGORIE = 'Tehnologie';
GO