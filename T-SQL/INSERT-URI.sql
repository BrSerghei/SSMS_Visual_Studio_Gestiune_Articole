USE DWH_GestionareArticole;
GO
INSERT INTO DIM_TIMP VALUES
(1,'2026-03-19',19,3,'Martie',1,1,2026,'Joi',      1),
(2,'2026-03-20',20,3,'Martie',1,1,2026,'Vineri',   1),
(3,'2026-03-21',21,3,'Martie',1,1,2026,'Sambata',  0),
(4,'2026-03-22',22,3,'Martie',1,1,2026,'Duminica', 0),
(5,'2026-03-23',23,3,'Martie',1,1,2026,'Luni',     1);
GO
SET IDENTITY_INSERT DIM_CATEGORIE ON;
INSERT INTO DIM_CATEGORIE
    (ID_CATEGORIE, NUME_CATEGORIE, CATEGORIE_PARINTE, ACTIVA, META_JSON)
VALUES
(1,'Tehnologie', NULL, 1, '{"prioritate_strategica":"ridicata","obiectiv_lunar":10}'),
(2,'Stiinta',    NULL, 1, '{"prioritate_strategica":"medie","obiectiv_lunar":6}'),
(3,'Cultura',    NULL, 1, '{"prioritate_strategica":"medie","obiectiv_lunar":5}'),
(4,'Economie',   NULL, 1, '{"prioritate_strategica":"medie","obiectiv_lunar":5}'),
(5,'Sanatate',   NULL, 1, '{"prioritate_strategica":"medie","obiectiv_lunar":4}'),
(6,'Educatie',   NULL, 0, '{"prioritate_strategica":"scazuta","obiectiv_lunar":3}');
SET IDENTITY_INSERT DIM_CATEGORIE OFF;
GO
SET IDENTITY_INSERT DIM_STATUS_ARTICOL ON;
INSERT INTO DIM_STATUS_ARTICOL
    (ID_STATUS, DENUMIRE_STATUS, DESCRIERE, REGULI_JSON)
VALUES
(1,'publicat','Articol publicat live pe platforma',
 '{"aprobari_necesare":1,"timp_mediu_aprobare_ore":2}'),
(2,'draft','Articol in redactare, nevizibil public',
 '{"aprobari_necesare":2,"timp_mediu_aprobare_ore":24}'),
(3,'arhivat','Articol scos din activ, nevizibil public',
 '{"aprobari_necesare":0,"timp_mediu_aprobare_ore":0}');
SET IDENTITY_INSERT DIM_STATUS_ARTICOL OFF;
GO
SET IDENTITY_INSERT DIM_ETICHETA ON;
INSERT INTO DIM_ETICHETA
    (ID_ETICHETA, NUME_ETICHETA, CULOARE, META_JSON)
VALUES
(1,'MySQL',      '#F97316', '{"popularitate":"ridicata","trend":"stabil"}'),
(2,'Python',     '#3B82F6', '{"popularitate":"ridicata","trend":"ascendent"}'),
(3,'AI',         '#8B5CF6', '{"popularitate":"ridicata","trend":"ascendent"}'),
(4,'Securitate', '#EF4444', '{"popularitate":"medie","trend":"ascendent"}'),
(5,'Tutorial',   '#10B981', '{"popularitate":"ridicata","trend":"stabil"}'),
(6,'Analiza',    '#F59E0B', '{"popularitate":"medie","trend":"stabil"}');
SET IDENTITY_INSERT DIM_ETICHETA OFF;
GO
SET IDENTITY_INSERT DIM_ARTICOL ON;
INSERT INTO DIM_ARTICOL
    (ID_ARTICOL, TITLU, SLUG, STATUS,
     DATA_PUBLICARII, DATA_MODIFICARII, ATRIBUTE_JSON)
VALUES
(1,'Introducere in MySQL Distribuit','introducere-mysql-distribuit',
 'publicat','2026-03-19','2026-04-07',
 '{"nivel":"intermediar","format":"tutorial","cuvinte_cheie":["MySQL","Distributed"]}'),
(2,'Optimizarea Interogarilor SQL','optimizarea-interogarilor-sql',
 'publicat','2026-03-19','2026-03-19',
 '{"nivel":"avansat","format":"analiza","cuvinte_cheie":["SQL","Performance"]}'),
(13,'Tranzactii SQL: COMMIT si ROLLBACK','tranzactii-sql-commit-rollback',
 'publicat','2026-03-20','2026-03-23',
 '{"nivel":"intermediar","format":"tutorial","cuvinte_cheie":["SQL","ACID"]}'),
(14,'Indexuri in MySQL: B-Tree si Hash','indexuri-mysql-btree-hash',
 'publicat','2026-03-20','2026-03-23',
 '{"nivel":"avansat","format":"analiza","cuvinte_cheie":["MySQL","Index"]}'),
(15,'Normalizarea Bazelor de Date','normalizare-bd-1nf-2nf-3nf',
 'publicat','2026-03-20','2026-03-23',
 '{"nivel":"intermediar","format":"tutorial","cuvinte_cheie":["BD","Normalizare"]}'),
(19,'Blockchain: Concepte Fundamentale','blockchain-concepte-fundamentale',
 'publicat','2026-03-21','2026-03-23',
 '{"nivel":"incepator","format":"tutorial","cuvinte_cheie":["Blockchain","Crypto"]}'),
(22,'Analiza Financiara cu SQL','analiza-financiara-sql',
 'publicat','2026-03-21','2026-03-23',
 '{"nivel":"avansat","format":"analiza","cuvinte_cheie":["SQL","Finance"]}'),
(27,'Yoga si Sanatatea Coloanei','yoga-sanatate-coloana',
 'publicat','2026-03-22','2026-03-23',
 '{"nivel":"incepator","format":"ghid","cuvinte_cheie":["Yoga","Sanatate"]}'),
(28,'Somnul: Impact asupra Performantei','somn-performanta-cognitiva',
 'publicat','2026-03-22','2026-03-23',
 '{"nivel":"incepator","format":"analiza","cuvinte_cheie":["Somn","Productivitate"]}'),
(9,'JSON in MySQL - Ghid Complet','json-mysql-ghid-complet',
 'draft',NULL,'2026-03-23',
 '{"nivel":"avansat","format":"tutorial","cuvinte_cheie":["JSON","MySQL"]}');
SET IDENTITY_INSERT DIM_ARTICOL OFF;
GO
SET IDENTITY_INSERT DIM_AUTOR ON;
INSERT INTO DIM_AUTOR
    (ID_AUTOR, NUME, PRENUME, EMAIL, ROL,
     DATA_INREGISTRARE, PROFIL_JSON)
VALUES
(1,'Brodovoi','Serghei','admin@portal.md',   'administrator','2026-03-19',
 '{"specializare":"BD","tinta_lunara":5,"experienta_ani":10}'),
(2,'Ciobanu', 'Maria',  'redactor@portal.md','redactor',     '2026-03-19',
 '{"specializare":"Tehnologie","tinta_lunara":8,"experienta_ani":4}'),
(3,'Rusu',    'Andrei', 'andrei@portal.md',  'redactor',     '2026-03-19',
 '{"specializare":"Sanatate_Educatie","tinta_lunara":8,"experienta_ani":3}'),
(4,'Munteanu','Elena',  'elena@portal.md',   'redactor',     '2026-03-19',
 '{"specializare":"Economie_Stiinta","tinta_lunara":6,"experienta_ani":2}');
SET IDENTITY_INSERT DIM_AUTOR OFF;
GO
SET IDENTITY_INSERT DIM_UTILIZATOR ON;
INSERT INTO DIM_UTILIZATOR
    (ID_UTILIZATOR, NUME, PRENUME, ROL, ACTIV,
     DATA_INREGISTRARE, ULTIMA_AUTENTIFICARE, SEGMENT_JSON)
VALUES
(1,'Brodovoi','Serghei','administrator',1,'2026-03-19','2026-04-07',
 '{"comportament":"foarte_activ","risc_abandon":"minim"}'),
(2,'Ciobanu', 'Maria',  'redactor',    1,'2026-03-19','2026-04-07',
 '{"comportament":"activ","risc_abandon":"scazut"}'),
(3,'Rusu',    'Andrei', 'redactor',    1,'2026-03-19','2026-04-07',
 '{"comportament":"activ","risc_abandon":"scazut"}'),
(4,'Munteanu','Elena',  'redactor',    1,'2026-03-19',NULL,
 '{"comportament":"ocazional","risc_abandon":"mediu"}'),
(6,'Grama',   'Vasile', 'redactor',    0,'2025-05-20',NULL,
 '{"comportament":"inactiv","risc_abandon":"ridicat"}'),
(10,'Sirbu',  'Ana',    'cititor',     0,'2025-11-20',NULL,
 '{"comportament":"inactiv","risc_abandon":"ridicat"}');
SET IDENTITY_INSERT DIM_UTILIZATOR OFF;
GO
SET IDENTITY_INSERT DIM_ROL ON;
INSERT INTO DIM_ROL
    (ID_ROL, DENUMIRE_ROL, DESCRIERE, PERMISIUNI_JSON)
VALUES
(1,'administrator','Acces complet: CRUD pe toate entitatile, gestionare utilizatori',
 '{"poate_modera":true,"nivel_acces":3,"actiuni":["publish","delete","manage_users","view_analytics"]}'),
(2,'redactor','Poate crea, edita, publica si arhiva articole proprii',
 '{"poate_modera":false,"nivel_acces":2,"actiuni":["create","edit","publish","archive"]}'),
(3,'cititor','Poate vizualiza articole publicate si lasa comentarii si evaluari',
 '{"poate_modera":false,"nivel_acces":1,"actiuni":["read","comment","evaluate"]}');
SET IDENTITY_INSERT DIM_ROL OFF;
GO
INSERT INTO FACT_DWH_GESTIUNE_ARTICOLE
(ID_TIMP,ID_ARTICOL,ID_AUTOR,ID_CATEGORIE,ID_UTILIZATOR,
 ID_ETICHETA,ID_ROL,ID_STATUS,
 NR_VIZUALIZARI,DURATA_MEDIE_SEC,RATA_VIZUALIZARE,
 NR_ARTICOLE_PUBLICATE,NR_ARTICOLE_CREATE,RATA_PUBLICARE,
 NR_COMENTARII,RATA_COMENTARE,MEDIE_EVALUARE,
 NR_ARTICOLE_CATEGORIE,NR_VERSIUNI,RATA_ACTUALIZARE,
 NR_SESIUNI_ACTIVE,RATA_AUTENTIFICARE,RATA_RETENTIE,
 KPI_METADATA_JSON)
VALUES
(1,1,2,1,2,1,2,1,
 20,170.00,0.0980,
 8,12,0.6667,
 4,0.2000,4.50,
 18,0,0.0000,
 1,0.1667,0.6667,
 '{"articol":"Introducere MySQL Distribuit","luna":"Martie_2026"}'),
(1,2,2,1,3,1,2,1,
 0,320.00,0.0000,
 8,12,0.6667,
 1,0.0000,5.00,
 18,0,0.0000,
 1,0.1667,0.6667,
 '{"articol":"Optimizarea Interogarilor SQL","luna":"Martie_2026"}'),
(2,13,3,1,3,1,2,1,
 7,264.33,0.0343,
 8,12,0.6667,
 3,0.4286,4.67,
 18,0,0.0000,
 1,0.1667,0.6667,
 '{"articol":"Tranzactii SQL COMMIT ROLLBACK","luna":"Martie_2026"}'),
(2,14,4,1,4,1,2,1,
 12,245.00,0.0588,
 6,11,0.5455,
 4,0.3333,4.33,
 18,0,0.0000,
 1,0.1667,0.5000,
 '{"articol":"Indexuri MySQL B-Tree Hash","alerte":["comentariu_spam_detectat"]}'),
(2,15,3,1,3,1,2,1,
 9,210.00,0.0441,
 8,12,0.6667,
 0,0.0000,3.67,
 18,0,0.0000,
 1,0.1667,0.6667,
 '{"articol":"Normalizarea BD 1NF 2NF 3NF","luna":"Martie_2026"}'),
(3,19,4,2,4,6,2,1,
 15,198.00,0.0735,
 6,11,0.5455,
 2,0.1333,4.00,
 6,0,0.0000,
 1,0.1667,0.5000,
 '{"articol":"Blockchain Concepte Fundamentale","luna":"Martie_2026"}'),
(3,22,4,3,4,6,2,1,
 11,225.00,0.0539,
 6,11,0.5455,
 1,0.0909,4.67,
 11,0,0.0000,
 1,0.1667,0.5000,
 '{"articol":"Analiza Financiara cu SQL","luna":"Martie_2026"}'),
(4,27,3,5,3,5,2,1,
 18,312.00,0.0882,
 8,12,0.6667,
 1,0.0556,5.00,
 4,0,0.0000,
 1,0.1667,0.6667,
 '{"articol":"Yoga Sanatatea Coloanei","luna":"Martie_2026"}'),
(4,28,4,5,4,5,2,1,
 22,289.00,0.1078,
 6,11,0.5455,
 0,0.0000,4.67,
 4,0,0.0000,
 1,0.1667,0.5000,
 '{"articol":"Somnul Impact Performanta Cognitiva","luna":"Martie_2026"}'),
(5,9,4,1,4,1,2,2,
 0,NULL,0.0000,
 6,11,0.5455,
 0,0.0000,NULL,
 18,0,0.0000,
 0,0.0000,0.5000,
 '{"articol":"JSON in MySQL Ghid Complet","alerte":["nepublicat","draft_activ"]}'),
(1,1,1,1,1,1,1,1,
 20,170.00,0.0980,
 3,5,0.6000,
 4,0.2000,4.50,
 18,0,0.0000,
 2,0.3333,0.5000,
 '{"autor":"Brodovoi_Serghei","rol":"administrator","luna":"Martie_2026"}'),
(2,2,2,1,2,1,2,1,
 0,320.00,0.0000,
 8,12,0.6667,
 1,0.0000,5.00,
 18,0,0.0000,
 2,0.3333,0.6667,
 '{"autor":"Ciobanu_Maria","rol":"redactor","luna":"Martie_2026"}'),
(3,13,3,1,3,1,2,1,
 7,264.33,0.0343,
 8,12,0.6667,
 3,0.4286,4.67,
 18,0,0.0000,
 2,0.3333,0.6667,
 '{"autor":"Rusu_Andrei","rol":"redactor","luna":"Martie_2026"}'),
(4,14,4,1,4,1,2,1,
 12,245.00,0.0588,
 6,11,0.5455,
 4,0.3333,4.33,
 18,0,0.0000,
 0,0.0000,0.5000,
 '{"autor":"Munteanu_Elena","alerte":["ultima_auth_null","risc_abandon_mediu"]}'),
(1,1,2,1,3,1,3,1,
 20,170.00,0.0980,
 18,24,0.7500,
 12,0.0667,4.17,
 18,0,0.0000,
 2,0.3333,0.6667,
 '{"categorie":"Tehnologie","tip_agregare":"lunar","luna":"Martie_2026"}'),
(3,19,4,2,4,6,3,1,
 15,198.00,0.0735,
 2,4,0.5000,
 2,0.1333,4.00,
 6,0,0.0000,
 2,0.3333,0.5000,
 '{"categorie":"Stiinta","tip_agregare":"lunar","luna":"Martie_2026"}'),
(3,22,4,3,4,6,3,1,
 11,225.00,0.0539,
 11,15,0.7333,
 1,0.0909,4.17,
 11,0,0.0000,
 2,0.3333,0.5000,
 '{"categorie":"Cultura","tip_agregare":"lunar","luna":"Martie_2026"}'),
(4,27,3,5,3,5,3,1,
 18,312.00,0.0882,
 4,6,0.6667,
 1,0.0556,4.83,
 4,0,0.0000,
 2,0.3333,0.6667,
 '{"categorie":"Sanatate","tip_agregare":"lunar","luna":"Martie_2026"}'),
(5,1,1,1,1,1,1,1,
 20,170.00,0.0980,
 3,5,0.6000,
 4,0.2000,4.50,
 18,0,0.0000,
 3,0.2000,0.2000,
 '{"sesiuni_total":3,"sesiuni_active":2,"utilizatori_total":15,"utilizatori_activi":3,"luna":"Martie_2026"}'),
(5,9,4,1,4,1,2,2,
 0,NULL,0.0000,
 6,11,0.5455,
 0,0.0000,NULL,
 18,0,0.0000,
 3,0.2000,0.2000,
 '{"sesiuni_total":3,"sesiuni_active":2,"utilizatori_total":15,"utilizatori_activi":3,"alerte":["retentie_scazuta_20%"]}');
GO
SELECT 'DIM_TIMP'                   AS TABEL, COUNT(*) AS RANDURI FROM DIM_TIMP
UNION ALL
SELECT 'DIM_CATEGORIE',                       COUNT(*) FROM DIM_CATEGORIE
UNION ALL
SELECT 'DIM_STATUS_ARTICOL',                  COUNT(*) FROM DIM_STATUS_ARTICOL
UNION ALL
SELECT 'DIM_ETICHETA',                        COUNT(*) FROM DIM_ETICHETA
UNION ALL
SELECT 'DIM_ARTICOL',                         COUNT(*) FROM DIM_ARTICOL
UNION ALL
SELECT 'DIM_AUTOR',                           COUNT(*) FROM DIM_AUTOR
UNION ALL
SELECT 'DIM_UTILIZATOR',                      COUNT(*) FROM DIM_UTILIZATOR
UNION ALL
SELECT 'DIM_ROL',                             COUNT(*) FROM DIM_ROL
UNION ALL
SELECT 'FACT_DWH_GESTIUNE_ARTICOLE',          COUNT(*) FROM FACT_DWH_GESTIUNE_ARTICOLE;
GO