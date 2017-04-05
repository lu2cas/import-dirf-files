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
	PRIMARY KEY (`id`),
	KEY `respo_cpf` (`cpf`)
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
	`description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
	`created` datetime NOT NULL,
	`modified` datetime NOT NULL,
	PRIMARY KEY (`id`),
	KEY `idrec_revenue_code` (`revenue_code`)
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

CREATE TABLE `incomes` (
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`dirf_id` int(10) unsigned NOT NULL,
	`respo_id` int(10) unsigned NOT NULL,
	`decpj_id` int(10) unsigned NOT NULL,
	`idrec_id` int(10) unsigned DEFAULT NULL,
	`bpfdec_id` int(10) unsigned DEFAULT NULL,
	`bpjdec_id` int(10) unsigned DEFAULT NULL,
	`type` enum('RTRT','RTPO','RTPP','RTDP','RTPA','RTIRF','CJAC','CJAA','ESRT','ESPO','ESPP','ESDP','ESPA','ESIR','ESDJ','RIDAC','RIIRP','RIAP','RIMOG','RIP65','RIVC','RIBMR','RICAP','RIL96','RIPTS','RIO') COLLATE utf8_unicode_ci NOT NULL,
	`description` varchar(60) NULL,
	`month` int(2) unsigned NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Registro de rendimentos mensais e anuais';

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

CREATE VIEW `incomes_view` AS
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
	`ir`.`description` AS `idrec_description`,
	COALESCE(`pj`.`id`, `pf`.`id`) AS `beneficiary_id`,
	IF(`pj`.`id` IS NOT NULL, 'BPJDEC', 'BPFDEC') AS `beneficiary_type`,
	COALESCE(`pj`.`cnpj`, `pf`.`cpf`) AS `beneficiary_cpf_cnpj`,
	COALESCE(`pj`.`company_name`, `pf`.`name`) AS `beneficiary_name`,
	`in`.`type` AS `incomes_type`,
	`in`.`description` AS `incomes_description`,
	`in`.`month` AS `incomes_month`,
	`in`.`value` AS `incomes_value`
FROM
	`incomes` AS `in`
LEFT JOIN
	`bpfdec` AS `pf`
ON
	`pf`.`id` = `in`.`bpfdec_id`
LEFT JOIN
	`bpjdec` AS `pj`
ON
	`pj`.`id` = `in`.`bpjdec_id`
INNER JOIN
	`idrec` AS `ir`
ON
	`ir`.`id` = `in`.`idrec_id`
INNER JOIN
	`decpj` AS `dj`
ON
	`dj`.`id` = `in`.`decpj_id`
INNER JOIN
	`respo` AS `rs`
ON
	`rs`.`id` = `in`.`respo_id`
INNER JOIN
	`dirf` AS `df`
ON
	`df`.`id` = `in`.`dirf_id`;

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

INSERT INTO	`idrec`
	(`revenue_code`, `description`, `created`, `modified`)
VALUES
	('0561', 'Trabalho assalariado no país e ausentes no exterior a serviço do país', now(), now()),
	('0588', 'Trabalho sem vínculo empregatício', now(), now()),
	('1889', 'Rendimentos acumulados - Art. 12-A da lei nº 7.713, de 22 de dezembro de 1988', now(), now()),
	('3533', 'Proventos de aposentadoria, reserva, reforma ou pensão pagos pela previdência pública', now(), now()),
	('3562', 'Participação nos lucros ou resultados (PLR)', now(), now()),
	('3223', 'Resgate de previdência complementar - Modalidade contribuição definida/variável - Não optante pela tributação exclusiva', now(), now()),
	('3540', 'Benefício de previdência complementar - Não optante pela tributação exclusiva', now(), now()),
	('3556', 'Resgate de previdência complementar - Modalidade benefício definido - Não optante pela tributação exclusiva', now(), now()),
	('5565', 'Benefício de previdência complementar - Optante pela tributação exclusiva', now(), now()),
	('3579', 'Resgate de previdência complementar - Optante pela tributação exclusiva', now(), now()),
	('3208', 'Aluguéis, royalties e juros pagos a pessoa física', now(), now()),
	('6904', 'Indenizações por danos morais', now(), now()),
	('6891', 'Benefício ou resgate de seguro de vida com cláusula de cobertura por sobrevivência - Não optante pela tributação exclusiva', now(), now()),
	('8053', 'Aplicações financeiras de renda fixa, exceto em fundos de investimento - Pessoa física', now(), now()),
	('1708', 'Remuneração de serviços profissionais prestados por pessoa jurídica (art. 52 da lei nº 7.450, de 1985)', now(), now()),
	('3280', 'Remuneração de serviços pessoais prestados por associados de cooperativas de trabalho (art. 45 da lei nº 8.541, de 1992)', now(), now()),
	('3426', 'Aplicações financeiras de renda fixa, exceto em fundos de investimento - Pessoa jurídica', now(), now()),
	('3746', 'Retenção na fonte sobre pagamentos referentes à aquisição de autopeças à pessoa jurídica contribuinte da Cofins', now(), now()),
	('3770', 'Retenção na fonte sobre pagamentos referentes à aquisição de autopeças à pessoa jurídica contribuinte do PIS/Pasep', now(), now()),
	('5944', 'Pagamentos de pessoa jurídica a pessoa jurídica por serviços de assessoria creditícia, mercadológica, gestão de crédito, seleção e riscos e administração de contas a pagar e a receber', now(), now()),
	('5952', 'Retenção na fonte sobre pagamentos a pessoa jurídica contribuinte da CSLL, da Cofins e da contribuição para o PIS/Pasep', now(), now()),
	('5960', 'Retenção de Cofins sobre pagamentos efetuados por pessoas jurídicas de direito privado', now(), now()),
	('5979', 'Retenção de PIS/Pasep sobre pagamentos efetuados por pessoas jurídicas de direito privado', now(), now()),
	('5987', 'Retenção de CSLL sobre pagamentos efetuados por pessoas jurídicas de direito privado', now(), now()),
	('4085', 'Retenção de CSLL, cofins e PIS/Pasep sobre pagamentos efetuados por órgãos, autarquias e fundações dos estados, Distrito Federal e municípios', now(), now()),
	('4397', 'Retenção de CSLL sobre pagamentos efetuados por órgãos, autarquias e fundações dos estados, Distrito Federal e municípios', now(), now()),
	('4407', 'Retenção de Cofins sobre pagamentos efetuados por órgãos, autarquias e fundações dos estados, Distrito Federal e municípios', now(), now()),
	('4409', 'Retenção de PIS/Pasep sobre pagamentos efetuados por órgãos, autarquias e fundações dos estados, Distrito Federal e municípios', now(), now()),
	('8045', 'Serviços de propaganda prestados por pessoa jurídica - Comissões e corretagens pagas a pessoa jurídica', now(), now()),
	('0916', 'Prêmios e sorteios em geral, títulos de capitalização, prêmios de proprietários e criadores de cavalos de corrida e prêmios em bens e serviços', now(), now()),
	('8673', 'Jogos de bingo permanente ou eventual - Prêmios em bens e serviços', now(), now()),
	('0924', 'Fundo de investimento cultural e artístico (Ficart) e demais rendimentos do capital', now(), now()),
	('3277', 'Rendimentos de partes beneficiárias ou de fundador', now(), now()),
	('5204', 'Juros e indenizações por lucros cessantes', now(), now()),
	('5232', 'Fundos de investimento imobiliário', now(), now()),
	('5273', 'Operações de SWAP', now(), now()),
	('5706', 'Juros sobre o capital próprio', now(), now()),
	('5928', 'Rendimentos decorrentes de decisões da justiça federal, exceto o disposto no art. 12-A da lei nº 7.713, de 1988', now(), now()),
	('5936', 'Rendimentos decorrentes de decisões da justiça do trabalho, exceto o disposto no art. 12-A da lei nº 7.713, de 1988', now(), now()),
	('1895', 'Rendimentos decorrentes de decisão da justiça dos estados/Distrito Federal, exceto o disposto no art. 12-A da lei nº 7.713, de 1988', now(), now()),
	('6800', 'Fundos de investimento e fundos de investimento em quotas de fundos de investimento', now(), now()),
	('6813', 'Fundos de investimento em ações e fundo de investimento em quotas de fundos de investimento em ações', now(), now()),
	('8468', 'Operações day trade', now(), now()),
	('9385', 'Multas e vantagens', now(), now()),
	('5557', 'Mercado de renda variável', now(), now()),
	('0422', 'Royalties e pagamentos de assistência técnica', now(), now()),
	('0490', 'Aplicações em fundos de conversão de débitos externos', now(), now()),
	('0481', 'Juros e comissões em geral', now(), now()),
	('9453', 'Juros sobre o capital próprio', now(), now()),
	('9478', 'Aluguel e arrendamento', now(), now()),
	('5286', 'Aplicações financeiras/entidades de investimento coletivo', now(), now()),
	('0473', 'Rendas e proventos de qualquer natureza', now(), now()),
	('9412', 'Fretes internacionais', now(), now()),
	('0610', 'Transporte rodoviário internacional de carga - Sociedade unipessoal', now(), now()),
	('9466', 'Previdência privada e Fapi', now(), now()),
	('9427', 'Remuneração de direitos', now(), now()),
	('5192', 'Obras audiovisuais', now(), now());