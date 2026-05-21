-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gazdă: 127.0.0.1
-- Timp de generare: mai 17, 2026 la 07:32 PM
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
-- Bază de date: `gestiune_interactiuni`
--

DELIMITER $$
--
-- Funcții
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_MedieEvaluariArticol` (`p_id_articol` INT) RETURNS DECIMAL(4,2) DETERMINISTIC READS SQL DATA BEGIN
DECLARE v_medie DECIMAL(4,2) DEFAULT 0.00;
SELECT ROUND(AVG(nota), 2)
INTO   v_medie
FROM   evaluari
WHERE  id_articol = p_id_articol;
RETURN IFNULL(v_medie, 0.00);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `comentarii`
--

CREATE TABLE `comentarii` (
  `id_comentariu` int(11) NOT NULL,
  `id_articol` int(11) NOT NULL,
  `id_utilizator` int(11) NOT NULL,
  `text_comentariu` text NOT NULL,
  `data_comentariu` datetime NOT NULL DEFAULT current_timestamp(),
  `comentariu_parinte` int(11) DEFAULT NULL,
  `aprobat` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Eliminarea datelor din tabel `comentarii`
--

INSERT INTO `comentarii` (`id_comentariu`, `id_articol`, `id_utilizator`, `text_comentariu`, `data_comentariu`, `comentariu_parinte`, `aprobat`) VALUES
(1, 1, 3, 'Articol excelent! M-a ajutat să înțeleg replica MySQL.', '2026-03-19 15:35:07', NULL, 1),
(2, 1, 9, 'Aș vrea mai multe exemple practice despre noduri.', '2026-03-19 15:35:07', NULL, 1),
(3, 2, 3, 'Tehnicile de optimizare descrise sunt foarte utile.', '2026-03-19 15:35:07', NULL, 1),
(4, 1, 2, 'Mulțumesc! Voi adăuga exemple în curând.', '2026-03-19 15:35:07', 1, 1),
(16, 13, 7, 'In sfarsit un articol care explica clar diferenta dintre SAVEPOINT si ROLLBACK complet. Multumesc!', '2026-03-20 09:00:00', NULL, 1),
(17, 13, 9, 'O intrebare: daca conexiunea cade in timpul unei tranzactii, se face rollback automat?', '2026-03-20 10:00:00', NULL, 1),
(18, 13, 8, 'Da Petre, MySQL face rollback automat la inchiderea conexiunii daca tranzactia nu a fost comisa.', '2026-03-20 10:30:00', 17, 1),
(19, 14, 8, 'Am redus timpul unui SELECT de la 4 secunde la 12 milisecunde adaugand un index compus. Articolul acesta m-a ajutat direct.', '2026-03-20 11:00:00', NULL, 1),
(20, 14, 7, 'Atentie la indexurile pe coloane cu cardinalitate mica (gen sex M/F). MySQL le ignora uneori in favoarea full scan.', '2026-03-20 12:00:00', NULL, 1),
(21, 14, 9, 'Cum verifici daca MySQL foloseste efectiv indexul? EXPLAIN arata POSSIBLE_KEYS dar nu garanteaza utilizarea.', '2026-03-20 13:00:00', NULL, 1),
(22, 14, 8, 'EXPLAIN FORMAT=JSON iti arata exact ce face query optimizer-ul si de ce alege sau nu alege indexul.', '2026-03-20 14:00:00', 21, 1),
(23, 19, 9, 'Articol bun dar lipseste sectiunea despre consumul energetic al proof-of-work. Bitcoin consuma cat Austria.', '2026-03-21 11:00:00', NULL, 1),
(24, 19, 7, 'Proof-of-stake rezolva partial problema energetica. Ethereum a redus consumul cu 99.95% dupa The Merge.', '2026-03-21 12:00:00', 23, 1),
(25, 22, 8, 'Window functions sunt subevaluate in Romania. Majoritatea developerilor nici nu stiu ca exista LAG si LEAD.', '2026-03-21 14:00:00', NULL, 1),
(26, 27, 9, 'Dupa 3 luni de yoga zilnica am scapat de durerea lombara cronica. Recomand oricui sta mult la calculator.', '2026-03-22 12:00:00', NULL, 1),
(27, 14, 7, 'Cumparati cursul meu de optimizare MySQL la reducere 80%! Link in bio!!!', '2026-03-22 15:00:00', NULL, 0);

--
-- Declanșatori `comentarii`
--
DELIMITER $$
CREATE TRIGGER `trg_BEFORE_INSERT_comentariu` BEFORE INSERT ON `comentarii` FOR EACH ROW BEGIN
IF NEW.text_comentariu REGEXP '(cumparati|reducere [0-9]+%|link in bio|click here|free money)' THEN
SET NEW.aprobat = 0;
END IF;
IF CHAR_LENGTH(NEW.text_comentariu) > 1000 THEN
SET NEW.text_comentariu = CONCAT(LEFT(NEW.text_comentariu, 997), '...');
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `evaluari`
--

CREATE TABLE `evaluari` (
  `id_evaluare` int(11) NOT NULL,
  `id_articol` int(11) NOT NULL,
  `id_utilizator` int(11) NOT NULL,
  `nota` tinyint(4) NOT NULL CHECK (`nota` between 1 and 5),
  `data_evaluare` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Eliminarea datelor din tabel `evaluari`
--

INSERT INTO `evaluari` (`id_evaluare`, `id_articol`, `id_utilizator`, `nota`, `data_evaluare`) VALUES
(1, 1, 3, 5, '2026-03-19 15:35:07'),
(2, 1, 8, 4, '2026-03-19 15:35:07'),
(3, 2, 3, 5, '2026-03-19 15:35:07'),
(20, 13, 7, 5, '2026-03-20 09:30:00'),
(21, 13, 8, 4, '2026-03-20 10:30:00'),
(22, 13, 9, 5, '2026-03-20 11:30:00'),
(23, 14, 7, 5, '2026-03-20 12:00:00'),
(24, 14, 8, 4, '2026-03-20 13:00:00'),
(25, 14, 9, 4, '2026-03-20 14:00:00'),
(26, 15, 7, 4, '2026-03-20 15:00:00'),
(27, 15, 8, 3, '2026-03-20 16:00:00'),
(28, 15, 9, 4, '2026-03-20 17:00:00'),
(29, 16, 7, 4, '2026-03-20 18:00:00'),
(30, 16, 9, 4, '2026-03-21 08:00:00'),
(31, 17, 8, 4, '2026-03-21 08:30:00'),
(32, 17, 9, 3, '2026-03-21 09:00:00'),
(33, 18, 7, 3, '2026-03-21 09:30:00'),
(34, 18, 8, 3, '2026-03-21 10:00:00'),
(35, 19, 7, 4, '2026-03-21 11:00:00'),
(36, 19, 8, 5, '2026-03-21 11:30:00'),
(37, 19, 9, 3, '2026-03-21 12:00:00'),
(38, 20, 7, 5, '2026-03-21 12:30:00'),
(39, 20, 8, 4, '2026-03-21 13:00:00'),
(40, 21, 7, 4, '2026-03-21 13:30:00'),
(41, 21, 8, 3, '2026-03-21 14:00:00'),
(42, 21, 9, 4, '2026-03-21 14:30:00'),
(43, 22, 7, 5, '2026-03-21 15:00:00'),
(44, 22, 8, 5, '2026-03-21 15:30:00'),
(45, 22, 9, 4, '2026-03-21 16:00:00'),
(46, 23, 7, 3, '2026-03-21 16:30:00'),
(47, 23, 8, 4, '2026-03-21 17:00:00'),
(48, 23, 9, 3, '2026-03-21 17:30:00'),
(49, 24, 7, 5, '2026-03-22 08:30:00'),
(50, 24, 8, 5, '2026-03-22 09:00:00'),
(51, 24, 9, 4, '2026-03-22 09:30:00'),
(52, 25, 7, 4, '2026-03-22 09:30:00'),
(53, 25, 9, 4, '2026-03-22 10:00:00'),
(54, 26, 8, 5, '2026-03-22 10:30:00'),
(55, 26, 9, 4, '2026-03-22 11:00:00'),
(56, 27, 7, 5, '2026-03-22 11:30:00'),
(57, 27, 8, 5, '2026-03-22 12:00:00'),
(58, 27, 9, 5, '2026-03-22 12:30:00'),
(59, 28, 7, 5, '2026-03-22 13:00:00'),
(60, 28, 8, 5, '2026-03-22 13:30:00'),
(61, 28, 9, 4, '2026-03-22 14:00:00'),
(62, 29, 7, 4, '2026-03-22 14:30:00'),
(63, 29, 9, 4, '2026-03-22 15:00:00'),
(64, 30, 8, 5, '2026-03-22 15:30:00'),
(65, 30, 9, 4, '2026-03-22 16:00:00');

--
-- Declanșatori `evaluari`
--
DELIMITER $$
CREATE TRIGGER `trg_AFTER_INSERT_evaluare` AFTER INSERT ON `evaluari` FOR EACH ROW BEGIN
INSERT INTO kpi_medie_evaluari_articole
(id_articol, nr_evaluari, suma_note, medie_evaluari)
VALUES
(NEW.id_articol, 1, NEW.nota, NEW.nota)
ON DUPLICATE KEY UPDATE
nr_evaluari = nr_evaluari + 1,
suma_note = suma_note + NEW.nota,
medie_evaluari = ROUND((suma_note + NEW.nota) / (nr_evaluari + 1), 2);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `kpi_medie_evaluari_articole`
--

CREATE TABLE `kpi_medie_evaluari_articole` (
  `id_articol` int(11) NOT NULL,
  `nr_evaluari` int(11) NOT NULL DEFAULT 0,
  `suma_note` int(11) NOT NULL DEFAULT 0,
  `medie_evaluari` decimal(4,2) NOT NULL DEFAULT 0.00,
  `ultima_actualizare` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `notificari`
--

CREATE TABLE `notificari` (
  `id_notificare` int(11) NOT NULL,
  `id_destinatar` int(11) NOT NULL,
  `id_expeditor` int(11) DEFAULT NULL,
  `tip` enum('comentariu_nou','raspuns_comentariu','articol_publicat','evaluare_noua','sistem') NOT NULL,
  `mesaj` text NOT NULL,
  `id_articol` int(11) DEFAULT NULL,
  `id_comentariu` int(11) DEFAULT NULL,
  `citita` tinyint(1) NOT NULL DEFAULT 0,
  `creat_la` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `statistici_zilnice`
--

CREATE TABLE `statistici_zilnice` (
  `id_stat` int(11) NOT NULL,
  `data_stat` date NOT NULL,
  `id_articol` int(11) NOT NULL,
  `vizualizari_zi` int(11) NOT NULL DEFAULT 0,
  `comentarii_zi` int(11) NOT NULL DEFAULT 0,
  `evaluari_zi` int(11) NOT NULL DEFAULT 0,
  `medie_nota` decimal(3,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Eliminarea datelor din tabel `statistici_zilnice`
--

INSERT INTO `statistici_zilnice` (`id_stat`, `data_stat`, `id_articol`, `vizualizari_zi`, `comentarii_zi`, `evaluari_zi`, `medie_nota`) VALUES
(1, '2026-03-19', 1, 7760, 300, 5, 4.61),
(2, '2026-03-19', 2, 4900, 176, 3, 4.77),
(3, '2026-03-19', 13, 1500, 45, 1, 4.30),
(4, '2026-03-19', 15, 700, 12, 1, 3.00),
(5, '2026-03-19', 19, 6000, 195, 3, 4.27),
(6, '2026-03-19', 22, 900, 22, 1, 3.60),
(7, '2026-03-19', 27, 9150, 307, 4, 4.40),
(8, '2026-03-19', 28, 4200, 139, 2, 4.35),
(9, '2026-03-20', 1, 10300, 350, 3, 4.80),
(10, '2026-03-20', 2, 8950, 305, 4, 4.80),
(11, '2026-03-20', 13, 7, 3, 1, 4.67),
(12, '2026-03-20', 14, 2082, 44, 4, 3.41),
(13, '2026-03-20', 15, 1009, 14, 3, 3.02),
(14, '2026-03-20', 22, 3250, 103, 2, 4.20),
(15, '2026-03-20', 27, 5100, 175, 2, 4.60),
(16, '2026-03-20', 28, 1450, 42, 1, 4.00),
(17, '2026-03-21', 1, 10800, 367, 4, 4.62),
(18, '2026-03-21', 2, 2650, 88, 1, 4.50),
(19, '2026-03-21', 9, 810, 9, 2, 2.55),
(20, '2026-03-21', 13, 7, 3, 1, 4.67),
(21, '2026-03-21', 14, 760, 18, 1, 3.40),
(22, '2026-03-21', 19, 5530, 179, 5, 4.12),
(23, '2026-03-21', 22, 3672, 121, 4, 4.31),
(24, '2026-03-21', 28, 6450, 211, 3, 4.40),
(25, '2026-03-22', 1, 19900, 683, 6, 4.78),
(26, '2026-03-22', 2, 5120, 159, 3, 3.80),
(27, '2026-03-22', 13, 4600, 143, 3, 4.10),
(28, '2026-03-22', 14, 12, 4, 1, 4.33),
(29, '2026-03-22', 27, 616, 11, 3, 4.21),
(30, '2026-03-22', 28, 2772, 84, 3, 4.19),
(31, '2026-03-23', 1, 9070, 316, 4, 4.68),
(32, '2026-03-23', 9, 740, 7, 2, 2.45),
(33, '2026-03-23', 13, 3350, 107, 2, 4.15),
(34, '2026-03-23', 14, 520, 8, 1, 2.80),
(35, '2026-03-23', 15, 480, 7, 1, 2.60),
(36, '2026-03-23', 19, 1900, 61, 1, 4.20),
(37, '2026-03-23', 22, 5750, 186, 3, 4.27),
(38, '2026-03-23', 27, 3800, 130, 1, 4.90);

-- --------------------------------------------------------

--
-- Structură tabel pentru tabel `vizualizari`
--

CREATE TABLE `vizualizari` (
  `id_vizualizare` int(11) NOT NULL,
  `id_articol` int(11) NOT NULL,
  `id_utilizator` int(11) DEFAULT NULL,
  `ip_adresa` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `durata_sec` int(11) DEFAULT NULL,
  `data_vizualizare` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Eliminarea datelor din tabel `vizualizari`
--

INSERT INTO `vizualizari` (`id_vizualizare`, `id_articol`, `id_utilizator`, `ip_adresa`, `user_agent`, `durata_sec`, `data_vizualizare`) VALUES
(1, 1, 3, '192.168.1.10', NULL, 240, '2026-03-19 15:35:07'),
(2, 1, 8, '192.168.1.11', NULL, 180, '2026-03-19 15:35:07'),
(3, 1, NULL, '203.0.113.42', NULL, 90, '2026-03-19 15:35:07'),
(4, 2, 3, '192.168.1.10', NULL, 320, '2026-03-19 15:35:07'),
(5, 13, 7, '192.168.1.10', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', 310, '2026-03-20 08:30:00'),
(6, 13, 8, '192.168.1.11', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15)', 285, '2026-03-20 09:00:00'),
(7, 13, 9, '10.0.0.5', 'Mozilla/5.0 (Android 13; Mobile)', 198, '2026-03-20 09:30:00'),
(8, 13, NULL, '51.15.10.200', 'Googlebot/2.1', 44, '2026-03-20 11:00:00'),
(9, 14, 7, '192.168.1.10', 'Mozilla/5.0 (Windows NT 10.0)', 420, '2026-03-20 09:00:00'),
(10, 14, 8, '192.168.1.11', 'Mozilla/5.0 (Macintosh)', 395, '2026-03-20 10:00:00'),
(11, 14, 9, '10.0.0.5', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0)', 340, '2026-03-20 10:30:00'),
(12, 14, NULL, '66.249.66.1', 'Googlebot/2.1', 28, '2026-03-20 12:00:00'),
(13, 14, NULL, '78.24.100.5', 'AhrefsBot/7.0', 18, '2026-03-21 07:00:00'),
(14, 14, 2, '10.0.1.1', 'Mozilla/5.0 (Windows NT 10.0)', 260, '2026-03-21 08:00:00'),
(15, 15, 7, '192.168.1.10', 'Mozilla/5.0 (Windows NT 10.0)', 380, '2026-03-20 11:00:00'),
(16, 15, 9, '10.0.0.5', 'Mozilla/5.0 (Android 13)', 290, '2026-03-20 12:00:00'),
(17, 15, NULL, '45.33.12.50', 'Googlebot/2.1', 35, '2026-03-20 14:00:00'),
(18, 19, 7, '192.168.1.10', 'Mozilla/5.0 (Windows NT 10.0)', 510, '2026-03-21 10:30:00'),
(19, 19, 8, '192.168.1.11', 'Mozilla/5.0 (Macintosh)', 480, '2026-03-21 11:00:00'),
(20, 19, 9, '10.0.0.5', 'Mozilla/5.0 (Android 13)', 430, '2026-03-21 11:30:00'),
(21, 19, NULL, '89.42.15.100', 'SemrushBot/7~bl', 52, '2026-03-21 12:00:00'),
(22, 19, NULL, '154.20.12.88', 'python-requests/2.28.0', 19, '2026-03-22 03:00:00'),
(23, 19, 2, '10.0.1.1', 'Mozilla/5.0 (Windows NT 10.0)', 320, '2026-03-22 08:30:00'),
(24, 20, 8, '192.168.1.11', 'Mozilla/5.0 (Macintosh)', 370, '2026-03-21 11:30:00'),
(25, 20, 7, '192.168.1.10', 'Mozilla/5.0 (Windows NT 10.0)', 315, '2026-03-21 12:00:00'),
(26, 20, NULL, '66.249.66.5', 'Googlebot/2.1', 30, '2026-03-21 14:00:00'),
(27, 20, 9, '10.0.0.5', 'Mozilla/5.0 (iPhone)', 280, '2026-03-22 09:00:00'),
(28, 22, 7, '192.168.1.10', 'Mozilla/5.0 (Windows NT 10.0)', 445, '2026-03-21 13:30:00'),
(29, 22, 8, '192.168.1.11', 'Mozilla/5.0 (Macintosh)', 390, '2026-03-21 14:00:00'),
(30, 22, 9, '10.0.0.5', 'Mozilla/5.0 (Android 13)', 360, '2026-03-21 15:00:00'),
(31, 22, NULL, '185.191.171.4', 'AhrefsBot/7.0', 22, '2026-03-22 01:00:00'),
(32, 24, 7, '192.168.1.10', 'Mozilla/5.0 (Windows NT 10.0)', 490, '2026-03-22 08:30:00'),
(33, 24, 8, '192.168.1.11', 'Mozilla/5.0 (Macintosh)', 460, '2026-03-22 09:00:00'),
(34, 24, 9, '10.0.0.5', 'Mozilla/5.0 (Android 13)', 410, '2026-03-22 09:30:00'),
(35, 24, NULL, '67.43.156.10', 'Twitterbot/1.0', 25, '2026-03-22 04:00:00'),
(36, 24, NULL, '66.249.66.8', 'Googlebot/2.1', 33, '2026-03-22 06:00:00'),
(37, 27, 7, '192.168.1.10', 'Mozilla/5.0 (Windows NT 10.0)', 530, '2026-03-22 11:30:00'),
(38, 27, 8, '192.168.1.11', 'Mozilla/5.0 (Macintosh)', 515, '2026-03-22 12:00:00'),
(39, 27, 9, '10.0.0.5', 'Mozilla/5.0 (iPhone)', 480, '2026-03-22 12:30:00'),
(40, 27, NULL, '45.33.12.200', 'Googlebot/2.1', 40, '2026-03-22 05:00:00'),
(41, 27, NULL, '89.42.15.55', 'facebookexternalhit/1.1', 12, '2026-03-22 07:00:00'),
(42, 28, 7, '192.168.1.10', 'Mozilla/5.0 (Windows NT 10.0)', 560, '2026-03-22 12:30:00'),
(43, 28, 9, '10.0.0.5', 'Mozilla/5.0 (Android 13)', 490, '2026-03-22 13:00:00'),
(44, 28, NULL, '216.58.12.50', 'Twitterbot/1.0', 15, '2026-03-22 08:00:00'),
(45, 28, 2, '10.0.1.1', 'Mozilla/5.0 (Windows NT 10.0)', 420, '2026-03-22 14:00:00');

--
-- Indexuri pentru tabele eliminate
--

--
-- Indexuri pentru tabele `comentarii`
--
ALTER TABLE `comentarii`
  ADD PRIMARY KEY (`id_comentariu`),
  ADD KEY `fk_com_parinte` (`comentariu_parinte`),
  ADD KEY `idx_com_art` (`id_articol`),
  ADD KEY `idx_com_util` (`id_utilizator`),
  ADD KEY `idx_com_aprobat` (`aprobat`);

--
-- Indexuri pentru tabele `evaluari`
--
ALTER TABLE `evaluari`
  ADD PRIMARY KEY (`id_evaluare`),
  ADD UNIQUE KEY `uq_eval_art_util` (`id_articol`,`id_utilizator`),
  ADD KEY `idx_ev_art` (`id_articol`),
  ADD KEY `idx_ev_util` (`id_utilizator`);

--
-- Indexuri pentru tabele `kpi_medie_evaluari_articole`
--
ALTER TABLE `kpi_medie_evaluari_articole`
  ADD PRIMARY KEY (`id_articol`);

--
-- Indexuri pentru tabele `notificari`
--
ALTER TABLE `notificari`
  ADD PRIMARY KEY (`id_notificare`),
  ADD KEY `fk_not_com` (`id_comentariu`),
  ADD KEY `idx_not_dest` (`id_destinatar`),
  ADD KEY `idx_not_citit` (`citita`),
  ADD KEY `idx_not_data` (`creat_la`);

--
-- Indexuri pentru tabele `statistici_zilnice`
--
ALTER TABLE `statistici_zilnice`
  ADD PRIMARY KEY (`id_stat`),
  ADD UNIQUE KEY `uq_stat_data_art` (`data_stat`,`id_articol`),
  ADD KEY `idx_stat_data` (`data_stat`),
  ADD KEY `idx_stat_art` (`id_articol`);

--
-- Indexuri pentru tabele `vizualizari`
--
ALTER TABLE `vizualizari`
  ADD PRIMARY KEY (`id_vizualizare`),
  ADD KEY `idx_viz_art` (`id_articol`),
  ADD KEY `idx_viz_data` (`data_vizualizare`),
  ADD KEY `idx_viz_util` (`id_utilizator`);

--
-- AUTO_INCREMENT pentru tabele eliminate
--

--
-- AUTO_INCREMENT pentru tabele `comentarii`
--
ALTER TABLE `comentarii`
  MODIFY `id_comentariu` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT pentru tabele `evaluari`
--
ALTER TABLE `evaluari`
  MODIFY `id_evaluare` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;

--
-- AUTO_INCREMENT pentru tabele `notificari`
--
ALTER TABLE `notificari`
  MODIFY `id_notificare` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pentru tabele `statistici_zilnice`
--
ALTER TABLE `statistici_zilnice`
  MODIFY `id_stat` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT pentru tabele `vizualizari`
--
ALTER TABLE `vizualizari`
  MODIFY `id_vizualizare` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- Constrângeri pentru tabele eliminate
--

--
-- Constrângeri pentru tabele `comentarii`
--
ALTER TABLE `comentarii`
  ADD CONSTRAINT `fk_com_parinte` FOREIGN KEY (`comentariu_parinte`) REFERENCES `comentarii` (`id_comentariu`) ON DELETE CASCADE;

--
-- Constrângeri pentru tabele `notificari`
--
ALTER TABLE `notificari`
  ADD CONSTRAINT `fk_not_com` FOREIGN KEY (`id_comentariu`) REFERENCES `comentarii` (`id_comentariu`) ON DELETE SET NULL;


--
-- Metadate
--
USE `phpmyadmin`;

--
-- Metadate pentru tabelul comentarii
--

--
-- Metadate pentru tabelul evaluari
--

--
-- Metadate pentru tabelul kpi_medie_evaluari_articole
--

--
-- Metadate pentru tabelul notificari
--

--
-- Metadate pentru tabelul statistici_zilnice
--

--
-- Metadate pentru tabelul vizualizari
--

--
-- Metadate pentru baza de date gestiune_interactiuni
--
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
