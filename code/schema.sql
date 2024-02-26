CREATE TABLE `lctable` (
  `ID` varchar(100) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `LastName` varchar(100) NOT NULL,
  `FieldA` varchar(255) NOT NULL,
  `FieldB` varchar(255) NOT NULL,
  `FieldC` varchar(255) NOT NULL,
  KEY `ID` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;