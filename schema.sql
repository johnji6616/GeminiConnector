/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `audit`
--

CREATE TABLE IF NOT EXISTS `audit` (
  `timestamp` int(11) NOT NULL,
  `absoluteTimestamp` int(11) NOT NULL,
  `userInfo` varchar(256) DEFAULT NULL,
  `requestInfo` text NOT NULL,
  `controller` varchar(256) DEFAULT NULL,
  `action` varchar(256) DEFAULT NULL,
  `userId` int(11) DEFAULT NULL,
  `error` tinyint(1) NOT NULL DEFAULT '0',
  `clientIp` varchar(15) DEFAULT NULL,
  `method` varchar(6) DEFAULT NULL,
  `headers` text,
  `uri` varchar(1024) DEFAULT NULL,
  `body` text,
  KEY `timestamp_index` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `company`
--

CREATE TABLE IF NOT EXISTS `company` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(45) NOT NULL,
  `data` varchar(1024) DEFAULT NULL,
  `operatorid` int(11) DEFAULT NULL,
  `domain` varchar(3000) DEFAULT NULL,
  `vpc` varchar(64) DEFAULT NULL,
  `redirectDomain` text DEFAULT NULL,
  `internal` tinyint(1) default 0,
  FOREIGN KEY (`operatorid`) REFERENCES `operator`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `companyToAuthStrategy`
--

CREATE TABLE IF NOT EXISTS `companyToAuthStrategy` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `companyId` int(11) NOT NULL,
  `authStrategy` text NOT NULL,
  FOREIGN KEY (`companyId`) REFERENCES `company`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `externalIdToRole`
--

CREATE TABLE IF NOT EXISTS `externalIdToRole` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `externalUserId` text NOT NULL,
  `roleId` int(11) NOT NULL,
  `companyId` int(11) NOT NULL,
  FOREIGN KEY (`companyId`) REFERENCES `company`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`roleId`) REFERENCES `rolemanager`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `locale`
--

CREATE TABLE IF NOT EXISTS `locale` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `timezone` varchar(64) DEFAULT NULL,
  `timeFormat` varchar(11) DEFAULT NULL,
  `dateFormat` varchar(64) DEFAULT NULL,
  `currency` varchar(16) DEFAULT NULL,
  `decimalSymbol` tinytext,
  `numberGroupingSymbol` tinytext,
  `language` varchar(16) DEFAULT NULL,
  `firstDayOfWeek` tinyint(4) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `oauthConfig`
--

CREATE TABLE IF NOT EXISTS `oauthConfig` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` text NOT NULL,
  `type` tinytext NOT NULL,
  `clientId` text NOT NULL,
  `clientSecret` text NOT NULL,
  `redirectUrl` text NOT NULL,
  `urlAuthorize` text NOT NULL,
  `urlAccessToken` text NOT NULL,
  `oauthScopes` text NOT NULL,
  `companyId` int(11) NOT NULL,
  FOREIGN KEY (`companyId`) REFERENCES `company`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `operator`
--

CREATE TABLE IF NOT EXISTS `operator` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(45) NOT NULL,
  `type` enum('IP_BASED','HEADER_BASED') NOT NULL,
  `data` varchar(1024) DEFAULT NULL,
  `localeId` int(11) DEFAULT NULL,
  `preferencesId` int(11) DEFAULT NULL,
  `configuration` longtext DEFAULT NULL,
  `operatorViews` json DEFAULT NULL,
  FOREIGN KEY (`localeId`) REFERENCES `locale`(`id`),
  FOREIGN KEY (`preferencesId`) REFERENCES `preferences`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `preferences`
--

CREATE TABLE IF NOT EXISTS `preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `customerCare_userSearchParam` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `rolemanager`
--

CREATE TABLE IF NOT EXISTS `rolemanager` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(255) NOT NULL,
  `companyId` int(11) NOT NULL,
  `jsonSerializedRoles` longtext NOT NULL,
  `homePage` varchar(255) NOT NULL DEFAULT 'landing',
  `canBeShared` tinyint(1) DEFAULT '0',
  UNIQUE KEY `name_company_UNIQUE` (`name`,`companyId`),
  FOREIGN KEY (`companyId`) REFERENCES `company`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `rolesToExternalGroups`
--

CREATE TABLE IF NOT EXISTS `rolesToExternalGroups` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `roleId` int(11) NOT NULL,
  `companyId` int(11) NOT NULL,
  `externalGroupId` text NOT NULL,
  FOREIGN KEY (`companyId`) REFERENCES `company`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`roleId`) REFERENCES `rolemanager`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `targetcompanyaccess`
--

CREATE TABLE IF NOT EXISTS `targetcompanyaccess` (
  `sourceCompanyId` int(11) NOT NULL,
  `targetCompanyId` int(11) NOT NULL,
  PRIMARY KEY (`sourceCompanyId`, `targetCompanyId`),
  FOREIGN KEY (`sourceCompanyId`) REFERENCES `company`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`targetCompanyId`) REFERENCES `company`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(256) NOT NULL,
  `email` varchar(128) NOT NULL UNIQUE,
  `companyId` int(11) NOT NULL,
  `password` varchar(256) NOT NULL,
  `accessLevel` tinyint(1) NOT NULL DEFAULT '0',
  `loginAttempts` tinyint(1) NOT NULL DEFAULT '0',
  `accountState` enum('PENDING','ACTIVE') NOT NULL DEFAULT 'PENDING',
  `localeId` int(11) DEFAULT NULL,
  `preferencesId` int(11) DEFAULT NULL,
  `externalUserId` varchar(256) DEFAULT NULL UNIQUE,
  FOREIGN KEY (`localeId`) REFERENCES `locale`(`id`),
  FOREIGN KEY (`preferencesId`) REFERENCES `preferences`(`id`),
  FOREIGN KEY (`companyId`) REFERENCES `company`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `userpermissions`
--

CREATE TABLE IF NOT EXISTS `userpermissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `userId` int(11) NOT NULL,
  `companyId` int(11) NOT NULL,
  `roleId` int(11) NOT NULL,
  UNIQUE KEY `userCompanyUnique` (`userId`, `companyId`),
  FOREIGN KEY (`roleId`) REFERENCES `rolemanager`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`userId`) REFERENCES `user`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`companyId`) REFERENCES `company`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `operator_features`
--

CREATE TABLE IF NOT EXISTS `operator_features` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `company_id` int(11) NOT NULL,
  `feature_key` varchar(64) NOT NULL
);

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

CREATE TABLE IF NOT EXISTS `Sessions` (`sid` VARCHAR(36) , `expires` DATETIME, `data` TEXT, `createdAt` DATETIME NOT NULL, `updatedAt` DATETIME NOT NULL, PRIMARY KEY (`sid`));

CREATE TABLE `layoutPage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pageId` varchar(100) NOT NULL,
  `operatorId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `layoutJSON` JSON DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `layoutpagetooperatorid` (`operatorid`),
  CONSTRAINT `layoutpagetooperatorid` FOREIGN KEY (`operatorid`) REFERENCES `operator` (`id`),
    KEY `layoutpagetouserid` (`userid`),
  CONSTRAINT `layoutpagetouserid` FOREIGN KEY (`userid`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `operatorLayoutConfig`
--
CREATE TABLE `operatorLayoutConfig` (
  `id` int NOT NULL AUTO_INCREMENT,
  `operatorId` int DEFAULT NULL,
  `operatorLayoutConfigJSON` JSON DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `operatorId_UNIQUE` (`operatorId`),
  KEY `operatorlayoutconfigtooperatorid` (`operatorid`),
  CONSTRAINT `operatorlayoutconfigtooperatorid` FOREIGN KEY (`operatorid`) REFERENCES `operator` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
