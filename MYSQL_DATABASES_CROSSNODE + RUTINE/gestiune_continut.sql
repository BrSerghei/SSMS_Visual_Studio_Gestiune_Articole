-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gazdă: 127.0.0.1
-- Timp de generare: mai 17, 2026 la 07:31 PM
-- Versiune server: 10.4.32-MariaDB
-- Versiune PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Bază de date: `gestiune_continut`
--

DELIMITER $$
--
-- Proceduri
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ETL_Snapshot_Articole` ()   BEGIN
DECLARE v_batch_id VARCHAR(36);
SET v_batch_id = CONCAT(DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '_ETL');
TRUNCATE TABLE etl_staging_articole;
INSERT INTO etl_staging_articole (
id_articol, titlu, slug, status,
id_autor, prenume_autor, nume_autor, rol_autor,
id_categorie, nume_categorie, data_publicarii,
numar_vizualizari, nr_comentarii, medie_evaluari, etl_batch_id
)
SELECT
a.id_articol, a.titlu, a.slug, UPPER(a.status),
u.id_utilizator, u.prenume, u.nume, r.denumire_rol,
c.id_categorie, c.nume_categorie, a.data_publicarii,
a.numar_vizualizari,
(SELECT COUNT(*) FROM gestiune_interactiuni.comentarii co
WHERE co.id_articol = a.id_articol AND co.aprobat = 1),
gestiune_interactiuni.fn_MedieEvaluariArticol(a.id_articol),
v_batch_id
FROM gestiune_continut.articole a
JOIN gestiune_utilizatori.utilizatori u ON a.id_autor = u.id_utilizator
JOIN gestiune_utilizatori.roluri r ON u.id_rol = r.id_rol
JOIN gestiune_continut.categorii c ON a.id_categorie = c.id_categorie
WHERE u.activ = 1;
SELECT
v_batch_id AS batch_id,
NOW() AS etl_timestamp,
COUNT(*) AS total_randuri_staging,
SUM(status = 'PUBLICAT') AS articole_publicate,
SUM(status = 'DRAFT') AS articole_draft,
SUM(status = 'ARHIVAT') AS articole_arhivate,
SUM(numar_vizualizari) AS total_vizualizari,
ROUND(AVG(medie_evaluari), 2) AS medie_globala_evaluari
FROM etl_staging_articole
WHERE etl_batch_id = v_batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetStatisticiAutor` (IN `p_id_autor` INT, OUT `p_nr_publicate` INT, OUT `p_total_vizualizari` BIGINT, OUT `p_medie_evaluari` DECIMAL(4,2))   BEGIN
SELECT COUNT(*)
INTO p_nr_publicate
FROM gestiune_continut.articole
WHERE id_autor = p_id_autor AND status = 'publicat';
SELECT IFNULL(SUM(numar_vizualizari), 0)
INTO p_total_vizualizari
FROM gestiune_continut.articole
WHERE id_autor = p_id_autor;
SELECT IFNULL(ROUND(AVG(e.nota), 2), 0.00)
INTO p_medie_evaluari
FROM gestiune_interactiuni.evaluari e
JOIN gestiune_continut.articole a ON e.id_articol = a.id_articol
WHERE a.id_autor = p_id_autor;
SELECT
u.prenume,
u.nume,
fn_GetDenumireRol(u.id_utilizator) AS rol,
p_nr_publicate AS articole_publicate,
p_total_vizualizari AS total_vizualizari,
p_medie_evaluari AS medie_evaluari
FROM gestiune_utilizatori.utilizatori u
WHERE u.id_utilizator = p_id_autor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_PublicaArticol` (IN `p_id_articol` INT, IN `p_id_autor` INT, OUT `p_mesaj` VARCHAR(200))   sp_main: BEGIN
DECLARE v_status       VARCHAR(20);
DECLARE v_are_permisie TINYINT;
DECLARE v_id_autor_art INT;
SELECT status, id_autor
INTO   v_status, v_id_autor_art
FROM   gestiune_continut.articole
WHERE  id_articol = p_id_articol;
IF v_status IS NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Articolul specificat nu exista.';
END IF;
SELECT COUNT(*) INTO v_are_permisie
FROM gestiune_utilizatori.permisiuni p
JOIN gestiune_utilizatori.utilizatori u ON u.id_rol = p.id_rol
WHERE u.id_utilizator = p_id_autor
AND p.actiune = 'publish_article' AND p.permis = 1;
IF v_are_permisie = 0 THEN
SET p_mesaj = 'EROARE: Utilizatorul nu are permisiunea publish_article.';
LEAVE sp_main;
END IF;
IF v_id_autor_art <> p_id_autor THEN
IF fn_GetDenumireRol(p_id_autor) <> 'administrator' THEN
SET p_mesaj = 'EROARE: Poti publica doar propriile articole.';
LEAVE sp_main;
END IF;
END IF;
IF v_status = 'publicat' THEN
SET p_mesaj = 'INFO: Articolul este deja publicat.';
ELSEIF v_status = 'arhivat' THEN
SET p_mesaj = 'EROARE: Articolele arhivate nu pot fi re-publicate direct.';
ELSE
UPDATE gestiune_continut.articole
SET status = 'publicat',
data_publicarii = IFNULL(data_publicarii, NOW())
WHERE  id_articol = p_id_articol;
SET p_mesaj = CONCAT('OK: Articolul id=', p_id_articol, ' publicat cu succes.');
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_RaportKPI_Categorie` (IN `p_id_categorie` INT)   BEGIN
SELECT
c.id_categorie,
c.nume_categorie,
COUNT(a.id_articol) AS nr_articole_total,
SUM(a.status = 'publicat') AS nr_articole_publicate,
SUM(a.status = 'draft') AS nr_articole_draft,
SUM(a.status = 'arhivat') AS nr_articole_arhivate,
IFNULL(SUM(a.numar_vizualizari),0) AS total_vizualizari,
IFNULL(AVG(a.numar_vizualizari),0) AS medie_vizualizari,
(SELECT COUNT(*) FROM gestiune_interactiuni.comentarii co
WHERE co.id_articol IN (SELECT id_articol FROM gestiune_continut.articole WHERE  id_categorie = c.id_categorie)) AS nr_comentarii_aprobate,
ROUND((SELECT IFNULL(AVG(ev.nota), 0)
FROM gestiune_interactiuni.evaluari ev
WHERE ev.id_articol IN (SELECT id_articol FROM gestiune_continut.articole WHERE  id_categorie = c.id_categorie)), 2) AS medie_evaluari
FROM gestiune_continut.categorii c
LEFT JOIN gestiune_continut.articole a ON a.id_categorie = c.id_categorie
WHERE (p_id_categorie IS NULL OR c.id_categorie = p_id_categorie)
GROUP BY c.id_categorie, c.nume_categorie
ORDER BY total_vizualizari DESC;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `articole`
--

CREATE TABLE `articole` (
  `id_articol` int(11) NOT NULL,
  `titlu` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `continut` longtext NOT NULL,
  `rezumat` text DEFAULT NULL,
  `imagine_principala` varchar(255) DEFAULT NULL,
  `data_publicarii` datetime DEFAULT NULL,
  `data_modificarii` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `id_autor` int(11) NOT NULL,
  `id_categorie` int(11) NOT NULL,
  `numar_vizualizari` int(11) NOT NULL DEFAULT 0,
  `status` enum('draft','publicat','arhivat') NOT NULL DEFAULT 'draft'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Eliminarea datelor din tabel `articole`
--

INSERT INTO `articole` (`id_articol`, `titlu`, `slug`, `continut`, `rezumat`, `imagine_principala`, `data_publicarii`, `data_modificarii`, `id_autor`, `id_categorie`, `numar_vizualizari`, `status`) VALUES
(1, 'Introducere in MySQL Distribuit', 'introducere-mysql-distribuit', 'Bazele de date distribuite permit stocarea datelor pe mai multe noduri simultan...', 'Ghid complet despre arhitectura MySQL în sisteme distribuite.', NULL, '2026-03-19 00:00:00', '2026-04-07 00:00:00', 1, 1, 57830, 'publicat'),
(2, 'Optimizarea Interogarilor SQL', 'optimizarea-interogarilor-sql', 'Performanța interogărilor SQL depinde de indecși, planuri de execuție și structura schemei...', 'Tehnici avansate pentru optimizarea query-urilor MySQL.', NULL, '2026-03-19 00:00:00', '2026-03-19 00:00:00', 2, 1, 21620, 'publicat'),
(3, 'Securitatea Bazelor de Date', 'securitatea-bazelor-de-date', 'Protejarea datelor sensibile prin criptare, roluri și politici de acces...', 'Practici esențiale de securitate pentru sisteme MySQL.', NULL, '2026-03-23 17:11:28', '2026-03-23 17:11:28', 1, 1, 0, 'publicat'),
(4, 'Data Science - Introducere', 'data-science-introducere-1773936674', '-', '-', NULL, '2026-03-19 17:11:14', '2026-03-19 18:11:14', 1, 1, 0, 'publicat'),
(5, 'BD - conceptual', 'bd-conceptual-1773938399', '-', '-', NULL, '2026-03-19 17:39:59', '2026-03-19 18:39:59', 1, 1, 0, 'publicat'),
(6, 'Tendinte Economice 2026', 'tendinte-economice-2026', 'Economia digitala redefineste modelele de business traditionale. Inteligenta artificiala automatizeaza procese, criptomonedele contesta sistemele financiare clasice, iar sustenabilitatea devine criteriu de investitie.', 'Analiza principalelor tendinte economice globale pentru 2026.', NULL, '2026-03-21 09:00:00', '2026-04-07 20:57:13', 2, 3, 8, 'publicat'),
(7, 'Nutritia Optima pentru Programatori', 'nutritia-programatori', 'Munca sedentara si orele prelungite in fata ecranului impun o atentie sporita asupra nutritiei. Proteinele sustin concentrarea, acizii grasi omega-3 protejeaza sanatatea creierului, iar hidratarea previne oboseala cognitiva.', 'Ghid de nutritie adaptat stilului de viata al dezvoltatorilor software.', NULL, '2026-03-21 14:00:00', '2026-04-07 20:57:13', 2, 5, 1, 'publicat'),
(8, 'Metode Moderne de Invatare', 'metode-moderne-invatare', 'Invatarea bazata pe proiecte, gamificarea si microlearning-ul transforma educatia traditionala. Platformele e-learning permit personalizarea traseului educational si invatarea in ritmul propriu al fiecarui cursant.', 'Tehnici pedagogice inovatoare pentru era digitala.', NULL, '2026-03-22 08:00:00', '2026-03-23 15:45:45', 3, 6, 4, 'publicat'),
(9, 'JSON in MySQL - Ghid Complet', 'json-mysql-ghid-complet', 'MySQL 5.7+ suporta tipul de date JSON nativ, permitand stocarea documentelor semistructurate in tabele relationale. Functiile JSON_OBJECT, JSON_ARRAYAGG si JSON_EXTRACT ofera flexibilitate fara a sacrifica consistenta datelor.', 'Utilizarea tipului JSON in MySQL: functii, indecsi si cazuri practice.', NULL, NULL, '2026-03-23 00:00:00', 4, 2, 1550, 'draft'),
(10, 'Inteligenta Artificiala in Medicina', 'ai-medicina', 'Modelele de machine learning analizeaza imagini medicale cu precizie comparabila specialistilor umani. Diagnosticul precoce al cancerului, interpretarea RMN si predictia evolutiei bolilor cronice sunt aplicatii reale implementate deja.', 'Cum transforma AI diagnosticul medical si tratamentul personalizat.', NULL, NULL, '2026-04-07 20:57:13', 2, 2, 0, 'draft'),
(11, 'Cultura Organizationala in Startup-uri', 'cultura-startup', 'Startup-urile de succes construiesc o cultura inainte de a construi un produs. Valorile comune, autonomia echipelor si toleranta fata de esec creeaza mediul propice inovatiei si retentiei talentelor.', 'Principiile culturii organizationale care diferentiaza startup-urile de succes.', NULL, NULL, '2026-03-23 15:45:45', 3, 4, 0, 'draft'),
(12, 'Ghid MySQL - Versiune Veche', 'ghid-mysql-56-vechi', 'Acest ghid a fost valabil pentru MySQL 5.6, versiune care nu mai primeste suport de securitate. Utilizatorii sunt incurajati sa migreze la MySQL 8.0 sau MariaDB 10.6+ pentru functionalitati imbunatatite si suport activ.', '', NULL, '2025-06-01 00:00:00', '2026-03-23 15:50:05', 1, 1, 0, 'arhivat'),
(13, 'Tranzactii SQL: COMMIT si ROLLBACK', 'tranzactii-sql-commit-rollback', 'Tranzactiile garanteaza consistenta datelor in scenarii multi-user. BEGIN, COMMIT si ROLLBACK formeaza tripleta fundamentala. Proprietatile ACID — Atomicitate, Consistenta, Izolare, Durabilitate — sunt pilonii oricarui sistem de baze de date de productie.', 'Ghid complet despre tranzactii SQL si proprietatile ACID.', NULL, '2026-03-20 00:00:00', '2026-03-23 00:00:00', 2, 2, 9464, 'publicat'),
(14, 'Indexuri in MySQL: B-Tree si Hash', 'indexuri-mysql-btree-hash', 'Indexurile B-Tree sunt potrivite pentru cautari pe intervale si sortari. Indexurile Hash sunt mai rapide pentru egalitati exacte dar nu suporta ORDER BY. Alegerea gresita a tipului de index poate transforma o interogare rapida intr-un full table scan.', 'Comparatie detaliata intre tipurile de indexuri MySQL.', NULL, '2026-03-20 00:00:00', '2026-03-23 00:00:00', 3, 2, 3374, 'publicat'),
(15, 'Normalizarea Bazelor de Date', 'normalizare-bd-1nf-2nf-3nf', 'Normalizarea elimina redundanta si anomaliile de actualizare. Prima forma normala elimina grupurile repetitive. A doua elimina dependentele partiale. A treia elimina dependentele tranzitive. Denormalizarea controlata este uneori justificata pentru performanta.', 'Cele trei forme normale explicate cu exemple practice.', NULL, '2026-03-20 00:00:00', '2026-03-23 00:00:00', 4, 2, 2189, 'publicat'),
(16, 'Proceduri Stocate in MariaDB', 'proceduri-stocate-mariadb', 'Procedurile stocate encapsuleaza logica de business direct in baza de date. Reduc traficul retea, imbunatatesc securitatea si permit reutilizarea codului. IN, OUT si INOUT definesc directia parametrilor. DELIMITER $$ separa definitia de executie.', 'Creare si utilizare proceduri stocate cu parametri in MariaDB.', NULL, '2026-03-20 11:00:00', '2026-03-23 16:02:46', 4, 1, 5, 'publicat'),
(17, 'Triggere MySQL: BEFORE si AFTER', 'triggere-mysql-before-after', 'Triggerele executa automat cod SQL la INSERT, UPDATE sau DELETE. BEFORE permite validarea sau modificarea datelor inainte de salvare. AFTER este potrivit pentru jurnalizare sau actualizarea tabelelor de audit. NEW si OLD refera valorile noii si vechii inregistrari.', 'Implementare triggere pentru validare automata si auditare.', NULL, '2026-03-21 08:00:00', '2026-03-23 16:02:46', 3, 1, 4, 'publicat'),
(18, 'Views in MySQL: Tabele Virtuale', 'views-mysql-tabele-virtuale', 'View-urile simplifica interogarile complexe si ascund detaliile de implementare. Un view updatable permite modificarea datelor sursa. View-urile materializate (simulate prin tabele) imbunatatesc performanta rapoartelor grele rulate frecvent.', 'Creare si utilizare view-uri simple si complexe in MySQL.', NULL, '2026-03-21 09:00:00', '2026-04-07 20:57:13', 2, 1, 3, 'publicat'),
(19, 'Blockchain: Concepte Fundamentale', 'blockchain-concepte-fundamentale', 'Blockchain-ul este un registru distribuit imutabil. Fiecare bloc contine hash-ul blocului anterior, creand un lant criptografic. Consensul distribuit elimina nevoia unui intermediar central. Bitcoin, Ethereum si smart contracts sunt aplicatiile cele mai cunoscute.', 'Introducere in blockchain: structura, consens si aplicatii.', NULL, '2026-03-21 00:00:00', '2026-03-23 00:00:00', 2, 3, 13430, 'publicat'),
(20, 'Microservicii vs Monolitic: Ghid de Alegere', 'microservicii-vs-monolitic', 'Arhitectura monolitica este simpla de dezvoltat initial dar dificil de scalat. Microserviciile ofera scalare independenta dar adauga complexitate operationala. Docker si Kubernetes au democratizat adoptia microserviciilor. Alegerea depinde de marimea echipei si complexitatea domeniului.', 'Criterii practice pentru alegerea intre monolitic si microservicii.', NULL, '2026-03-21 11:00:00', '2026-03-23 16:02:46', 3, 1, 8, 'publicat'),
(21, 'Git si Control Versiune pentru Baze de Date', 'git-control-versiune-baze-date', 'Migrarea schemei BD trebuie versionata ca si codul sursa. Flyway si Liquibase automatizeaza aplicarea migrarilor in ordine. Fiecare modificare de schema devine un fisier SQL numerotat. Rollback-ul migrarilor in productie necesita planificare atenta.', 'Strategii de versionare a schemei BD cu Flyway si Liquibase.', NULL, '2026-03-21 12:00:00', '2026-04-07 20:57:13', 2, 1, 6, 'publicat'),
(22, 'Analiza Financiara cu SQL', 'analiza-financiara-sql', 'SQL permite calcule financiare complexe: running totals cu SUM() OVER(), medii mobile cu AVG() OVER(ROWS), detectarea tendintelor cu LAG() si LEAD(). Window functions transforma SQL dintr-un limbaj de filtrare intr-un instrument de analiza financiara complet.', 'Window functions SQL pentru rapoarte si analize financiare.', NULL, '2026-03-21 00:00:00', '2026-03-23 00:00:00', 1, 3, 13572, 'publicat'),
(23, 'Inflatia si Dobanzile: Relatia Inversa', 'inflatie-dobanzi-relatie', 'Bancile centrale cresc dobanzile pentru a combate inflatia. Creditele devin mai scumpe, consumul scade, preturile se stabilizeaza. Mecanismul functioneaza cu un lag de 12-18 luni. Cursul valutar se apreciaza de obicei la cresterea dobanzilor.', 'Mecanismul prin care dobanzile controleaza inflatia.', NULL, '2026-03-21 14:00:00', '2026-04-07 20:57:13', 2, 3, 9, 'publicat'),
(24, 'Investitii Pasive: Index Funds', 'investitii-pasive-index-funds', 'Fondurile de index repliceaza performanta unui indice bursier cu costuri minime. S&P 500, MSCI World si alti indici globali ofera diversificare automata. Studiile arata ca 90% din fondurile active subperformeaza indexul pe termen lung dupa comisioane.', 'De ce fondurile pasive bat fondurile active pe termen lung.', NULL, '2026-03-22 08:00:00', '2026-03-23 16:02:46', 4, 3, 14, 'publicat'),
(25, 'Cinematografia Europeana Contemporana', 'cinematografie-europeana-contemporana', 'Cinematografia europeana ofera o alternativa narativa la blockbuster-ele hollywoodiene. Regizori ca Ruben Ostlund, Cristian Mungiu si Paolo Sorrentino exploreaza conditia umana cu mijloace minimaliste. Cannes, Berlin si Venetia raman termometrele calitatii cinematografice mondiale.', 'Tendinte si autori reprezentativi ai filmului european actual.', NULL, '2026-03-22 09:00:00', '2026-03-23 16:02:46', 3, 4, 5, 'publicat'),
(26, 'Literatura Sci-Fi: De la Asimov la Liu Cixin', 'literatura-scifi-asimov-liu-cixin', 'Asimov a definit robotica ficationala cu cele Trei Legi. Philip K. Dick a explorat identitatea si realitatea. Liu Cixin a adus perspectiva civilizatiei asiatice in SF cu trilogia Problema celor Trei Corpuri. Hard SF-ul actual integreaza astrofizica si informatica cuantice.', 'Evolutia literaturii SF de la clasici americani la autorii contemporani.', NULL, '2026-03-22 10:00:00', '2026-04-07 20:57:13', 2, 4, 7, 'publicat'),
(27, 'Yoga si Sanatatea Coloanei', 'yoga-sanatate-coloana', 'Munca la birou produce dezechilibre posturale care acumulate duc la hernii de disc si spondiloza. Yoga tinteste direct musculatura paravertebrala si flexibilitatea soldurilor. Asanele Cat-Cow, Child Pose si Downward Dog sunt elementare dar extrem de eficiente.', 'Rutina de yoga pentru programatori cu dureri de spate.', NULL, '2026-03-22 00:00:00', '2026-03-23 00:00:00', 1, 5, 18666, 'publicat'),
(28, 'Somnul: Impact asupra Performantei', 'somn-performanta-cognitiva', 'Privarea de somn reduce capacitatea de concentrare cu pana la 40% in 24 de ore. In faza REM creierul consolideaza memoria si elimina produsele reziduale metabolice. Programatorii care dorm sub 6 ore produc cu 50% mai multe bug-uri decat cei cu 8 ore de somn.', 'Stiinta somnului si impactul sau direct asupra calitatii codului.', NULL, '2026-03-22 00:00:00', '2026-03-23 00:00:00', 4, 4, 14872, 'publicat'),
(29, 'Design Thinking in Dezvoltarea Produselor', 'design-thinking-produse', 'Design Thinking este o metodologie centrata pe utilizator: Empathize, Define, Ideate, Prototype, Test. Prototiparea rapida reduce costul esecului. Testele cu utilizatori reali in faza timpurie previn construirea de functionalitati pe care nimeni nu le foloseste.', 'Aplicarea Design Thinking in ciclul de dezvoltare software.', NULL, '2026-03-22 13:00:00', '2026-04-07 20:57:13', 2, 6, 6, 'publicat'),
(30, 'Invatarea Limbilor Straine cu Spaced Repetition', 'invatare-limbi-spaced-repetition', 'Spaced repetition exploateaza curba uitarii a lui Ebbinghaus. Anki si SuperMemo calculeaza intervalul optim pentru fiecare card. Vocabularul unei limbi poate fi invatat eficient cu 20 de minute pe zi. Imersiunea activa combinata cu SRS produce rezultate superioare cursurilor traditionale.', 'Metoda stiintifica pentru invatarea vocabularului cu Anki.', NULL, '2026-03-22 14:00:00', '2026-03-23 16:02:46', 3, 6, 10, 'publicat'),
(31, 'Redis: Baza de Date In-Memory', 'redis-baza-date-in-memory', 'Redis stocheaza date in RAM pentru acces sub-milisecunda. Suporta structuri de date complexe: strings, hashes, lists, sets, sorted sets. Pub/Sub il transforma in message broker. Session storage, caching si leaderboard-uri sunt cazurile clasice de utilizare.', 'Redis ca layer de cache si session storage pentru aplicatii PHP.', NULL, NULL, '2026-03-23 16:02:46', 4, 1, 0, 'draft'),
(32, 'GraphQL vs REST: Comparatie Practica', 'graphql-vs-rest-comparatie', 'REST foloseste endpoint-uri multiple cu structuri fixe. GraphQL foloseste un singur endpoint cu query-uri flexibile. Over-fetching si under-fetching sunt problemele pe care GraphQL le rezolva. Complexitatea backend-ului creste insa semnificativ cu GraphQL.', 'Cand sa alegi GraphQL si cand REST ramane solutia optima.', NULL, NULL, '2026-03-23 16:02:46', 3, 1, 0, 'draft'),
(33, 'Machine Learning cu SQL: Window Functions Avansate', 'ml-sql-window-functions', 'SQL poate implementa algoritmi simpli de ML: regresia liniara cu AVG si STDDEV, clustering prin NTILE, detectia anomaliilor cu Z-score calculat inline. BigQuery si Snowflake extind SQL cu functii ML native fara cod Python.', 'Algoritmi de Machine Learning implementati direct in SQL.', NULL, NULL, '2026-03-23 16:02:46', 4, 1, 0, 'draft'),
(34, 'Schimbari Climatice: Date si Tendinte', 'schimbari-climatice-date', 'Concentratia de CO2 a depasit 420 ppm in 2023, cel mai ridicat nivel din ultimii 3 milioane de ani. Temperatura globala a crescut cu 1.1 grade fata de era preindustriala. Evenimentele meteorologice extreme s-au triplat ca frecventa in ultimii 50 de ani.', 'Analiza datelor climatice recente si proiectii pentru 2050.', NULL, NULL, '2026-04-07 20:57:13', 2, 2, 0, 'draft'),
(35, 'NFT si Proprietatea Digitala', 'nft-proprietate-digitala', 'NFT-urile (Non-Fungible Tokens) codifica proprietatea unica pe blockchain. Standardul ERC-721 defineste regulile pentru Ethereum. Piata NFT a scazut cu 97% fata de varful din 2022, dar cazurile de utilizare pentru drepturi digitale si ticketing persista.', 'Starea actuala a pietei NFT si cazuri de utilizare reale.', NULL, NULL, '2026-03-23 16:02:46', 3, 3, 0, 'draft'),
(36, 'Teatrul Contemporan: Regizori si Tendinte', 'teatru-contemporan-tendinte', 'Teatrul contemporan abandoneaza naratiunea liniara in favoarea experientei senzoriale. Regizori ca Robert Wilson si Krzysztof Warlikowski deconstruiesc textul dramatic. Site-specific theatre transforma spatii non-conventionale in scene. Publicul din Romania descopera treptat formatele experimentale.', 'Formatele experimentale care redefinesc teatrul in secolul XXI.', NULL, NULL, '2026-03-23 16:02:46', 4, 4, 0, 'draft'),
(37, 'Sanatatea Mintala a Developerilor', 'sanatate-mintala-developeri', 'Burnout-ul afecteaza 83% din developeri la un moment dat in cariera. Simptomele includ cinismul, detasarea emotionala si scaderea productivitatii. Tehnicile Pomodoro, limitarea meeting-urilor si separarea clara a orelor de lucru sunt interventii dovedite.', 'Recunoasterea si prevenirea burnout-ului in industria IT.', NULL, NULL, '2026-04-07 20:57:13', 2, 5, 0, 'draft'),
(38, 'Pedagogia Inversata: Flipped Classroom', 'pedagogia-inversata-flipped-classroom', 'In modelul flipped classroom elevii asimileaza teoria acasa prin video-uri si vin la scoala pentru aplicare practica. Profesorul devine facilitator in loc de transmitator de informatii. Rezultatele studiilor arata o crestere a motivatiei si a intelegerii profunde.', 'Implementarea modelului pedagogic inversat in clasele de informatica.', NULL, NULL, '2026-03-23 16:02:46', 3, 6, 0, 'draft'),
(39, 'Quantum Computing: Starea Actuala', 'quantum-computing-starea-actuala', 'Calculatoarele cuantice exploateaza superpoztia si entanglementul. IBM a atins 1000 de qubits in 2023 dar error rates raman ridicate. Algoritmul lui Shor poate sparge RSA-2048 teoretic dar necesita milioane de qubiti stabili. Criptografia post-cuantica se dezvolta in paralel.', 'Unde se afla quantum computing in 2026 si impactul potential.', NULL, NULL, '2026-03-23 16:02:46', 4, 2, 0, 'draft'),
(40, 'Economia Circulara si Sustenabilitatea IT', 'economie-circulara-it', 'Industria IT genereaza 50 milioane de tone de deseuri electronice anual. E-waste contine metale pretioase recuperabile: aur, argint, cobalt. Designul pentru longevitate, reparabilitate si reciclare devine obligatoriu in UE din 2025. Cloud computing reduce consumul energetic prin consolidare.', 'Impactul de mediu al industriei IT si solutii de sustenabilitate.', NULL, NULL, '2026-04-07 20:57:13', 2, 3, 0, 'draft'),
(41, 'PHP 5.6: Ghid de Migrare la PHP 8', 'php-56-migrare-php8', 'PHP 5.6 nu mai primeste suport din 2018. Migrarea la PHP 8 aduce JIT compiler, named arguments, union types si match expressions. Cel mai mare obstacol sunt extensiile deprecate si functiile mysql_ care nu mai exista. Rectorele automatizeaza o parte din migrare.', 'Ghid tehnic pentru migrarea aplicatiilor PHP 5.6 la PHP 8.', NULL, '2024-01-15 00:00:00', '2026-03-23 16:02:46', 1, 1, 0, 'arhivat'),
(42, 'Bootstrap 3: Tutorial', 'bootstrap-3-tutorial', 'Bootstrap 3 a fost frameworkul dominant intre 2013 si 2018. Sistemul de grid pe 12 coloane si componentele responsive au revolutionat dezvoltarea web. Bootstrap 5 a eliminat jQuery ca dependenta. Proiectele noi ar trebui sa foloseasca Bootstrap 5 sau Tailwind CSS.', 'Tutorial depasit pentru Bootstrap 3. Treceti la versiuni actuale.', NULL, '2023-06-01 00:00:00', '2026-03-23 16:02:46', 3, 1, 0, 'arhivat'),
(43, 'Flash si ActionScript: In Memoriam', 'flash-actionscript-in-memoriam', 'Adobe Flash a dominat web-ul interactiv intre 1996 si 2020. ActionScript 3 era un limbaj orientat obiect complet. Refuzul Apple de a suporta Flash pe iOS a inceput declinul. HTML5, CSS3 si JavaScript au preluat toate cazurile de utilizare. Adobe a oprit suportul pe 31 decembrie 2020.', 'Istoria si mostenirea Adobe Flash in dezvoltarea web.', NULL, '2021-01-05 00:00:00', '2026-03-23 16:02:46', 4, 1, 0, 'arhivat');

--
-- Declanșatori `articole`
--
DELIMITER $$
CREATE TRIGGER `trg_AFTER_UPDATE_status_articol` AFTER UPDATE ON `articole` FOR EACH ROW BEGIN
DECLARE v_mesaj_notif VARCHAR(300);
IF OLD.status <> NEW.status THEN
IF NEW.status = 'publicat' THEN
SET v_mesaj_notif = CONCAT('Articolul "', NEW.titlu, '" a fost publicat.');
ELSEIF NEW.status = 'arhivat' THEN
SET v_mesaj_notif = CONCAT('Articolul "', NEW.titlu, '" a fost arhivat.');
ELSE
SET v_mesaj_notif = CONCAT('Articolul "', NEW.titlu, '" a trecut din [', OLD.status, '] in [', NEW.status, '].');
END IF;
INSERT INTO gestiune_interactiuni.notificari (
id_destinatar, id_expeditor, tip, mesaj,
id_articol, citita, creat_la
) VALUES (
NEW.id_autor, NULL, 'articol_publicat',
v_mesaj_notif, NEW.id_articol, 0, NOW()
);
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `articole_etichete`
--

CREATE TABLE `articole_etichete` (
  `id_articol` int(11) NOT NULL,
  `id_eticheta` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Eliminarea datelor din tabel `articole_etichete`
--

INSERT INTO `articole_etichete` (`id_articol`, `id_eticheta`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(2, 1),
(2, 4),
(2, 5),
(2, 6),
(2, 7),
(2, 11),
(3, 1),
(3, 3),
(3, 4),
(3, 6),
(4, 10),
(4, 12),
(5, 3),
(5, 11),
(6, 10),
(7, 11),
(8, 12),
(9, 1),
(9, 2),
(9, 4),
(9, 5),
(10, 10),
(10, 12),
(11, 10),
(13, 1),
(13, 2),
(13, 4),
(13, 6),
(14, 1),
(14, 2),
(14, 5),
(15, 1),
(15, 2),
(19, 4),
(19, 5),
(19, 6),
(22, 6),
(27, 4),
(27, 5),
(28, 4),
(28, 5),
(28, 6);

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `categorii`
--

CREATE TABLE `categorii` (
  `id_categorie` int(11) NOT NULL,
  `nume_categorie` varchar(80) NOT NULL,
  `descriere` text DEFAULT NULL,
  `categorie_parinte` int(11) DEFAULT NULL,
  `activa` tinyint(1) NOT NULL DEFAULT 1,
  `creat_la` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Eliminarea datelor din tabel `categorii`
--

INSERT INTO `categorii` (`id_categorie`, `nume_categorie`, `descriere`, `categorie_parinte`, `activa`, `creat_la`) VALUES
(1, 'Tehnologie', 'Categorie importata din DIM_CATEGORIE; meta: {\"prioritate_strategica\":\"ridicata\",\"obiectiv_lunar\":10}', NULL, 1, '2026-03-19 15:29:56'),
(2, 'Știință', 'Categorie importata din DIM_CATEGORIE; meta: {\"prioritate_strategica\":\"medie\",\"obiectiv_lunar\":6}', NULL, 1, '2026-03-19 15:29:56'),
(3, 'Cultură', 'Categorie importata din DIM_CATEGORIE; meta: {\"prioritate_strategica\":\"medie\",\"obiectiv_lunar\":5}', NULL, 1, '2026-03-19 15:29:56'),
(4, 'Economie', 'Categorie importata din DIM_CATEGORIE; meta: {\"prioritate_strategica\":\"medie\",\"obiectiv_lunar\":5}', NULL, 1, '2026-03-19 15:29:56'),
(5, 'Sănătate', 'Categorie importata din DIM_CATEGORIE; meta: {\"prioritate_strategica\":\"medie\",\"obiectiv_lunar\":4}', NULL, 1, '2026-03-19 15:29:56'),
(6, 'Educatie', 'Categorie importata din DIM_CATEGORIE; meta: {\"prioritate_strategica\":\"scazuta\",\"obiectiv_lunar\":3}', NULL, 0, '2026-03-23 15:45:45');

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `etichete`
--

CREATE TABLE `etichete` (
  `id_eticheta` int(11) NOT NULL,
  `nume_eticheta` varchar(60) NOT NULL,
  `culoare` varchar(7) DEFAULT '#3B82F6'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Eliminarea datelor din tabel `etichete`
--

INSERT INTO `etichete` (`id_eticheta`, `nume_eticheta`, `culoare`) VALUES
(1, 'MySQL', '#F97316'),
(2, 'Python', '#3B82F6'),
(3, 'AI', '#8B5CF6'),
(4, 'Securitate', '#EF4444'),
(5, 'Tutorial', '#10B981'),
(6, 'Analiză', '#F59E0B'),
(7, 'Performanta', '#8B5CF6'),
(10, 'Cercetare', '#EC4899'),
(11, 'Ghid practic', '#F97316'),
(12, 'Inovatie', '#14B8A6');

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `etl_staging_articole`
--

CREATE TABLE `etl_staging_articole` (
  `etl_id` int(11) NOT NULL,
  `id_articol` int(11) NOT NULL,
  `titlu` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `status` varchar(20) NOT NULL,
  `id_autor` int(11) NOT NULL,
  `prenume_autor` varchar(50) DEFAULT NULL,
  `nume_autor` varchar(50) DEFAULT NULL,
  `rol_autor` varchar(20) DEFAULT NULL,
  `id_categorie` int(11) NOT NULL,
  `nume_categorie` varchar(80) DEFAULT NULL,
  `data_publicarii` datetime DEFAULT NULL,
  `numar_vizualizari` int(11) NOT NULL DEFAULT 0,
  `nr_comentarii` int(11) NOT NULL DEFAULT 0,
  `medie_evaluari` decimal(4,2) NOT NULL DEFAULT 0.00,
  `etl_timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  `etl_batch_id` varchar(36) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `versiuni_articole`
--

CREATE TABLE `versiuni_articole` (
  `id_versiune` int(11) NOT NULL,
  `id_articol` int(11) NOT NULL,
  `continut_vechi` longtext NOT NULL,
  `modificat_de` int(11) NOT NULL,
  `modificat_la` datetime NOT NULL DEFAULT current_timestamp(),
  `motiv` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexuri pentru tabele eliminate
--

--
-- Indexuri pentru tabele `articole`
--
ALTER TABLE `articole`
  ADD PRIMARY KEY (`id_articol`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `fk_art_cat` (`id_categorie`),
  ADD KEY `idx_autor` (`id_autor`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_publicat` (`data_publicarii`),
  ADD KEY `idx_slug` (`slug`);
ALTER TABLE `articole` ADD FULLTEXT KEY `idx_full_text` (`titlu`,`continut`);

--
-- Indexuri pentru tabele `articole_etichete`
--
ALTER TABLE `articole_etichete`
  ADD PRIMARY KEY (`id_articol`,`id_eticheta`),
  ADD KEY `fk_ae_et` (`id_eticheta`);

--
-- Indexuri pentru tabele `categorii`
--
ALTER TABLE `categorii`
  ADD PRIMARY KEY (`id_categorie`),
  ADD UNIQUE KEY `nume_categorie` (`nume_categorie`),
  ADD KEY `fk_cat_parinte` (`categorie_parinte`),
  ADD KEY `idx_activa` (`activa`);

--
-- Indexuri pentru tabele `etichete`
--
ALTER TABLE `etichete`
  ADD PRIMARY KEY (`id_eticheta`),
  ADD UNIQUE KEY `nume_eticheta` (`nume_eticheta`);

--
-- Indexuri pentru tabele `etl_staging_articole`
--
ALTER TABLE `etl_staging_articole`
  ADD PRIMARY KEY (`etl_id`);

--
-- Indexuri pentru tabele `versiuni_articole`
--
ALTER TABLE `versiuni_articole`
  ADD PRIMARY KEY (`id_versiune`),
  ADD KEY `idx_ver_art` (`id_articol`),
  ADD KEY `idx_ver_usr` (`modificat_de`);

--
-- AUTO_INCREMENT pentru tabele eliminate
--

--
-- AUTO_INCREMENT pentru tabele `articole`
--
ALTER TABLE `articole`
  MODIFY `id_articol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT pentru tabele `categorii`
--
ALTER TABLE `categorii`
  MODIFY `id_categorie` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pentru tabele `etichete`
--
ALTER TABLE `etichete`
  MODIFY `id_eticheta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT pentru tabele `etl_staging_articole`
--
ALTER TABLE `etl_staging_articole`
  MODIFY `etl_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pentru tabele `versiuni_articole`
--
ALTER TABLE `versiuni_articole`
  MODIFY `id_versiune` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constrângeri pentru tabele eliminate
--

--
-- Constrângeri pentru tabele `articole`
--
ALTER TABLE `articole`
  ADD CONSTRAINT `fk_art_cat` FOREIGN KEY (`id_categorie`) REFERENCES `categorii` (`id_categorie`) ON UPDATE CASCADE;

--
-- Constrângeri pentru tabele `articole_etichete`
--
ALTER TABLE `articole_etichete`
  ADD CONSTRAINT `fk_ae_art` FOREIGN KEY (`id_articol`) REFERENCES `articole` (`id_articol`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ae_et` FOREIGN KEY (`id_eticheta`) REFERENCES `etichete` (`id_eticheta`) ON DELETE CASCADE;

--
-- Constrângeri pentru tabele `categorii`
--
ALTER TABLE `categorii`
  ADD CONSTRAINT `fk_cat_parinte` FOREIGN KEY (`categorie_parinte`) REFERENCES `categorii` (`id_categorie`) ON DELETE SET NULL;

--
-- Constrângeri pentru tabele `versiuni_articole`
--
ALTER TABLE `versiuni_articole`
  ADD CONSTRAINT `fk_ver_art` FOREIGN KEY (`id_articol`) REFERENCES `articole` (`id_articol`) ON DELETE CASCADE;


--
-- Metadate
--
USE `phpmyadmin`;

--
-- Metadate pentru tabelul articole
--

--
-- Metadate pentru tabelul articole_etichete
--

--
-- Metadate pentru tabelul categorii
--

--
-- Metadate pentru tabelul etichete
--

--
-- Metadate pentru tabelul etl_staging_articole
--

--
-- Metadate pentru tabelul versiuni_articole
--

--
-- Metadate pentru baza de date gestiune_continut
--
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
