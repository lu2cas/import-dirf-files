CREATE DATABASE IF NOT EXISTS `income_reports`;
USE `income_reports`;

CREATE TABLE `dirf` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`reference_year` year(4) NOT NULL,
	`calendar_year` year(4) NOT NULL,
	`rectification_indicator` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`receipt_number` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
	`layout_structure_id` varchar(7) COLLATE utf8_unicode_ci NOT NULL,
	`created` datetime NOT NULL,
	`modified` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `dirf_calendar_year` (`calendar_year`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Registro de identificação da declaração';

CREATE TABLE `respo` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`cpf` varchar(11) COLLATE utf8_unicode_ci NOT NULL,
	`name` varchar(60) COLLATE utf8_unicode_ci NOT NULL,
	`area_code` varchar(2) COLLATE utf8_unicode_ci NOT NULL,
	`phone_number` varchar(9) COLLATE utf8_unicode_ci NOT NULL,
	`phone_extension` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
	`fax` varchar(9) COLLATE utf8_unicode_ci DEFAULT NULL,
	`email` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
	`created` datetime NOT NULL,
	`modified` datetime NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Registro do responsável pelo preenchimento da DIRF';

CREATE TABLE `decpj` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`cnpj` varchar(14) COLLATE utf8_unicode_ci NOT NULL,
	`company_name` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
	`declarant_nature` enum('0','1','2','3','4','8') COLLATE utf8_unicode_ci NOT NULL,
	`responsible_cpf` varchar(11) COLLATE utf8_unicode_ci NOT NULL,
	`ostensive_partner` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`court_decision_depositary` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`investment_fund_institution` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`incomes_paid_abroad` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`private_healthcare` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`fifa_worldcups_payments` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`olympic_games_payments` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`special_situation` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`event_date` DATE DEFAULT NULL,
	`created` datetime NOT NULL,
	`modified` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `decpj_cnpj` (`cnpj`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Registro de identificação do declarante pessoa jurídica';

CREATE TABLE `idrec` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`revenue_code` varchar(4) COLLATE utf8_unicode_ci NOT NULL,
	`created` datetime NOT NULL,
	`modified` datetime NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Registro de identificação do código de receita';

CREATE TABLE `bpfdec` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`cpf` varchar(11) COLLATE utf8_unicode_ci NOT NULL,
	`name` varchar(60) COLLATE utf8_unicode_ci NOT NULL,
	`severe_disease_date` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
	`created` datetime NOT NULL,
	`modified` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `bpfdec_cpf` (`cpf`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Registro de beneficiário pessoa física do declarante';

CREATE TABLE `bpjdec` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`cnpj` varchar(14) COLLATE utf8_unicode_ci NOT NULL,
	`company_name` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
	`created` datetime NOT NULL,
	`modified` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `bpjdec_cnpj` (`cnpj`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Registro de beneficiário pessoa jurídica do declarante';

CREATE TABLE `monthly_incomes` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`dirf_id` int(10) unsigned NOT NULL,
	`respo_id` int(10) unsigned NOT NULL,
	`decpj_id` int(10) unsigned NOT NULL,
	`idrec_id` int(10) unsigned DEFAULT NULL,
	`bpfdec_id` int(10) unsigned DEFAULT NULL,
	`bpjdec_id` int(10) unsigned DEFAULT NULL,
	`type` enum('RTRT','RTPO','RTPP','RTDP','RTPA','RTIRF','CJAC','CJAA','ESRT','ESPO','ESPP','ESDP','ESPA','ESIR','ESDJ','RIDAC','RIIRP','RIAP','RIMOG','RIP65','RIVC','RIBMR','RICAP') COLLATE utf8_unicode_ci NOT NULL,
	`month` int(2) unsigned NOT NULL,
	`value` double unsigned NOT NULL,
	`created` datetime NOT NULL,
	`modified` datetime NOT NULL,
	PRIMARY KEY (`id`),
	CONSTRAINT `montlhy_incomes_dirf_id` FOREIGN KEY (`dirf_id`) REFERENCES `dirf` (`id`),
	CONSTRAINT `montlhy_incomes_respo_id` FOREIGN KEY (`respo_id`) REFERENCES `respo` (`id`),
	CONSTRAINT `montlhy_incomes_decpj_id` FOREIGN KEY (`decpj_id`) REFERENCES `decpj` (`id`),
	CONSTRAINT `montlhy_incomes_idrec_id` FOREIGN KEY (`idrec_id`) REFERENCES `idrec` (`id`),
	CONSTRAINT `montlhy_incomes_bpfdec_id` FOREIGN KEY (`bpfdec_id`) REFERENCES `bpfdec` (`id`),
	CONSTRAINT `montlhy_incomes_bpjdec_id` FOREIGN KEY (`bpjdec_id`) REFERENCES `bpjdec` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Registro de valores mensais';

CREATE TABLE `yearly_incomes` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`dirf_id` int(10) unsigned NOT NULL,
	`respo_id` int(10) unsigned NOT NULL,
	`decpj_id` int(10) unsigned NOT NULL,
	`idrec_id` int(10) unsigned DEFAULT NULL,
	`bpfdec_id` int(10) unsigned DEFAULT NULL,
	`type` enum('RIL96', 'RIPTS', 'RIO') COLLATE utf8_unicode_ci NOT NULL,
	`descpription` varchar(60) NULL,
	`value` double unsigned NOT NULL,
	`created` datetime NOT NULL,
	`modified` datetime NOT NULL,
	PRIMARY KEY (`id`),
	CONSTRAINT `yearly_incomes_dirf_id` FOREIGN KEY (`dirf_id`) REFERENCES `dirf` (`id`),
	CONSTRAINT `yearly_incomes_respo_id` FOREIGN KEY (`respo_id`) REFERENCES `respo` (`id`),
	CONSTRAINT `yearly_incomes_decpj_id` FOREIGN KEY (`decpj_id`) REFERENCES `decpj` (`id`),
	CONSTRAINT `yearly_incomes_idrec_id` FOREIGN KEY (`idrec_id`) REFERENCES `idrec` (`id`),
	CONSTRAINT `yearly_incomes_bpfdec_id` FOREIGN KEY (`bpfdec_id`) REFERENCES `bpfdec` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Registro de rendimentos anuais isentos';

CREATE TABLE `brpde` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`dirf_id` int(10) unsigned NOT NULL,
	`beneficiary_type` enum('1','2') COLLATE utf8_unicode_ci NOT NULL,
	`country_code` varchar(3) COLLATE utf8_unicode_ci NOT NULL,
	`nif` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
	`nif_dispensed_beneficiary` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`nif_dispensed_country` tinyint(1) unsigned NOT NULL DEFAULT 0,
	`cpf_cnpj` varchar(14) COLLATE utf8_unicode_ci DEFAULT NULL,
	`name` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
	`payer_beneficiary_relationship` varchar(3) COLLATE utf8_unicode_ci DEFAULT NULL,
	`street` varchar(60) COLLATE utf8_unicode_ci DEFAULT NULL,
	`number` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
	`complement` varchar(25) COLLATE utf8_unicode_ci DEFAULT NULL,
	`district` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
	`zip_code` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
	`city` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
	`state` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
	`phone_number` varchar(15) COLLATE utf8_unicode_ci DEFAULT NULL,
	`created` datetime NOT NULL,
	`modified` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `brpde_dirf_id` (`dirf_id`),
	CONSTRAINT `brpde_dirf_id` FOREIGN KEY (`dirf_id`) REFERENCES `dirf` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Registro de beneficiário dos rendimentos pagos a residentes ';

CREATE TABLE `vrpde` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`brpde_id` int(10) unsigned NOT NULL,
	`payment_date` varchar(8) COLLATE utf8_unicode_ci NOT NULL,
	`revenue_code` varchar(4) COLLATE utf8_unicode_ci NOT NULL,
	`income_type` varchar(3) COLLATE utf8_unicode_ci NOT NULL,
	`paid_income` int(11) NOT NULL,
	`withheald_tax` int(11) DEFAULT NULL,
	`taxation_mode` varchar(2) COLLATE utf8_unicode_ci NOT NULL,
	`created` datetime NOT NULL,
	`modified` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `vrpde_brpde_id` (`brpde_id`),
	CONSTRAINT `vrpde_brpde_id` FOREIGN KEY (`brpde_id`) REFERENCES `brpde` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Registro valores de rendimentos pagos a residentes exterior';

CREATE VIEW `monthly_incomes_view` AS
SELECT
	`df`.`id` AS `dirf_id`,
	`df`.`reference_year` AS `dirf_reference_year`,
	`df`.`calendar_year` AS `dirf_calendar_year`,
	`df`.`rectification_indicator` AS `dirf_rectification_indicator`,
	`df`.`receipt_number` AS `dirf_receipt_number`,
	`df`.`created` AS `dirf_created`,
	`rs`.`id` AS `respo_id`,
	`rs`.`name` AS `respo_name`,
	`rs`.`cpf` AS `respo_cpf`,
	`dj`.`id` AS `decpj_id`,
	`dj`.`cnpj` AS `decpj_cnpj`,
	`dj`.`company_name` AS `decpj_company_name`,
	`dj`.`declarant_nature` AS `decpj_declarant_nature`,
	`dj`.`responsible_cpf` AS `decpj_responsible_cpf`,
	`dj`.`ostensive_partner` AS `decpj_ostensive_partner`,
	`dj`.`court_decision_depositary` AS `decpj_court_decision_depositary`,
	`dj`.`investment_fund_institution` AS `decpj_investment_fund_insitution`,
	`dj`.`incomes_paid_abroad` AS `decpj_incomes_paid_abroad`,
	`dj`.`private_healthcare` AS `decpj_private_healthcare`,
	`dj`.`fifa_worldcups_payments` AS `decpj_fifa_worldcups_payments`,
	`dj`.`olympic_games_payments` AS `decpj_olympic_games_payments`,
	`dj`.`special_situation` AS `decpj_special_situation`,
	`dj`.`event_date` AS `decpj_event_date`,
	`ir`.`id` AS `idrec_id`,
	`ir`.`revenue_code` AS `idrec_revenue_code`,
	COALESCE(`pj`.`id`, `pf`.`id`) AS `beneficiary_id`,
	IF(`pj`.`id` IS NOT NULL, 'BPJDEC', 'BPFDEC') AS `beneficiary_type`,
	COALESCE(`pj`.`cnpj`, `pf`.`cpf`) AS `beneficiary_cpf_cnpj`,
	COALESCE(`pj`.`company_name`, `pf`.`name`) AS `beneficiary_name`,
	`mi`.`type` AS `monthly_incomes_type`,
	`mi`.`month` AS `monthly_incomes_month`,
	`mi`.`value` AS `monthly_incomes_value`
FROM
	`monthly_incomes` AS `mi`
LEFT JOIN
	`bpfdec` AS `pf`
ON
	`pf`.`id` = `mi`.`bpfdec_id`
LEFT JOIN
	`bpjdec` AS `pj`
ON
	`pj`.`id` = `mi`.`bpjdec_id`
INNER JOIN
	`idrec` AS `ir`
ON
	`ir`.`id` = `mi`.`idrec_id`
INNER JOIN
	`decpj` AS `dj`
ON
	`dj`.`id` = `mi`.`decpj_id`
INNER JOIN
	`respo` AS `rs`
ON
	`rs`.`id` = `mi`.`respo_id`
INNER JOIN
	`dirf` AS `df`
ON
	`df`.`id` = `mi`.`dirf_id`;

CREATE VIEW `yearly_incomes_view` AS
SELECT
	`df`.`id` AS `dirf_id`,
	`df`.`reference_year` AS `dirf_reference_year`,
	`df`.`calendar_year` AS `dirf_calendar_year`,
	`df`.`rectification_indicator` AS `dirf_rectification_indicator`,
	`df`.`receipt_number` AS `dirf_receipt_number`,
	`df`.`created` AS `dirf_created`,
	`rs`.`id` AS `respo_id`,
	`rs`.`name` AS `respo_name`,
	`rs`.`cpf` AS `respo_cpf`,
	`dj`.`id` AS `decpj_id`,
	`dj`.`cnpj` AS `decpj_cnpj`,
	`dj`.`company_name` AS `decpj_company_name`,
	`dj`.`declarant_nature` AS `decpj_declarant_nature`,
	`dj`.`responsible_cpf` AS `decpj_responsible_cpf`,
	`dj`.`ostensive_partner` AS `decpj_ostensive_partner`,
	`dj`.`court_decision_depositary` AS `decpj_court_decision_depositary`,
	`dj`.`investment_fund_institution` AS `decpj_investment_fund_insitution`,
	`dj`.`incomes_paid_abroad` AS `decpj_incomes_paid_abroad`,
	`dj`.`private_healthcare` AS `decpj_private_healthcare`,
	`dj`.`fifa_worldcups_payments` AS `decpj_fifa_worldcups_payments`,
	`dj`.`olympic_games_payments` AS `decpj_olympic_games_payments`,
	`dj`.`special_situation` AS `decpj_special_situation`,
	`dj`.`event_date` AS `decpj_event_date`,
	`ir`.`id` AS `idrec_id`,
	`ir`.`revenue_code` AS `idrec_revenue_code`,
	`pf`.`id` AS `beneficiary_id`,
	`pf`.`cpf` AS `beneficiary_cpf_cnpj`,
	`pf`.`name` AS `beneficiary_name`,
	`yi`.`type` AS `yearly_incomes_type`,
	`yi`.`description` AS `yearly_incomes_description`,
	`yi`.`value` AS `yearly_incomes_value`
FROM
	`yearly_incomes` AS `yi`
INNER JOIN
	`bpfdec` AS `pf`
ON
	`pf`.`id` = `yi`.`bpfdec_id`
INNER JOIN
	`idrec` AS `ir`
ON
	`ir`.`id` = `yi`.`idrec_id`
INNER JOIN
	`decpj` AS `dj`
ON
	`dj`.`id` = `yi`.`decpj_id`
INNER JOIN
	`respo` AS `rs`
ON
	`rs`.`id` = `yi`.`respo_id`
INNER JOIN
	`dirf` AS `df`
ON
	`df`.`id` = `yi`.`dirf_id`;

CREATE VIEW `vrpde_view` AS
SELECT
	`df`.`id` AS `dirf_id`,
	`df`.`reference_year` AS `dirf_reference_year`,
	`df`.`calendar_year` AS `dirf_calendar_year`,
	`df`.`rectification_indicator` AS `dirf_rectification_indicator`,
	`df`.`receipt_number` AS `dirf_receipt_number`,
	`vr`.`id` AS `vrpde_id`,
	`vr`.`payment_date` AS `vrpde_payment_date`,
	`vr`.`revenue_code` AS `vrpde_revenue_code`,
	`vr`.`income_type` AS `vrpde_income_type`,
	`vr`.`paid_income` AS `vrpde_paid_income`,
	`vr`.`withheald_tax` AS `vrpde_withheald_tax`,
	`vr`.`taxation_mode` AS `vrpde_taxation_mode`,
	`br`.`id` AS `brpde_id`,
	`br`.`beneficiary_type` AS `brpde_beneficiary_type`,
	`br`.`country_code` AS `brpde_country_code`,
	`br`.`nif` AS `brpde_nif`,
	`br`.`nif_dispensed_beneficiary` AS `brpde_nif_dispensed_beneficiary`,
	`br`.`nif_dispensed_country` AS `brpde_nif_dispensed_country`,
	`br`.`cpf_cnpj` AS `brpde_cpf_cnpj`,
	`br`.`name` AS `brpde_company_name`,
	`br`.`payer_beneficiary_relationship` AS `brpde_payer_beneficiary_relationship`,
	`br`.`street` AS `brpde_street`,
	`br`.`number` AS `brpde_number`,
	`br`.`complement` AS `brpde_complement`,
	`br`.`district` AS `brpde_district`,
	`br`.`zip_code` AS `brpde_zip_code`,
	`br`.`city` AS `brpde_city`,
	`br`.`state` AS `brpde_state`,
	`br`.`phone_number` AS `brpde_phone_number`
FROM
	`vrpde` AS `vr`
INNER JOIN
	`brpde` AS `br`
ON
	`br`.`id` = `vr`.`brpde_id`
INNER JOIN
	`dirf` AS `df`
ON
	`df`.`id` = `br`.`dirf_id`;