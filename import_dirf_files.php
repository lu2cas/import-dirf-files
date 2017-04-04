<?php

/**
 * @license GNU General Public License v3.0
 * @author  Luccas Carvalho Silveira
 *
 * Esta classe tem por objetivo realizar a importação dos arquivos de texto
 * disponibilizados pela receita federal contentodo os dados de de declaração
 * de imposto de renda retido na fonte
 */
class ImportDirfFiles {

	/**
	 * Dados de conexão com o banco de dados
	 */
	private $__databaseConfig;

	/**
	 * Handler do banco de dados
	 */
	private $__link;

	/**
	 * Caminho do diretório que contém os arquivos DIRF
	 */
	private $__dirfFilesDirectory;

	/**
	 * Fila de arquivos DIRF a serem importados
	 */
	private $__dirfFilesQueue;

	/**
	 * Posição do arquivo DIRF vigente na fila de importação
	 */
	private $__dirfFilesQueueCurrentPosition;

	/**
	 * Caminho absoluto do arquivo DIRF vigente
	 */
	private $__dirfFilePath;

	/**
	 * Quantidade de linhas do arquivo DIRF vigente
	 */
	private $__dirfFileLength;

	/**
	 * Linha vigente do arquivo DIRF vigente
	 */
	private $__dirfFileCurrentLineNumber;

	/**
	 * Caminho do arquivo de log
	 */
	private $__logFile;

	/**
	 * Resultados da importação
	 */
	private $__results;

	/**
	 * Id da DIRF vigente
	 */
	private $__dirfId;

	/**
	 * Id do responsável pelo preenchimento da DIRF vigente
	 */
	private $__respoId;

	/**
	 * Id do DECPJ vigente
	 */
	private $__decpjId;

	/**
	 * Id do IDREC vigente
	 */
	private $__idrecId;

	/**
	 * Id do BPFDEC vigente
	 */
	private $__bpfdecId;

	/**
	 * Id do BPJDEC vigente
	 */
	private $__bpjdecId;

	/**
	 * Id do BRPDE vigente
	 */
	private $__brpdeId;

	// Construtor
	public function __construct() {
		set_time_limit(0);

		define('APP_DIR', dirname(dirname(__FILE__)));
		define('DS', DIRECTORY_SEPARATOR);

		$this->__databaseConfig = json_decode(file_get_contents('database_config.json'), true);

		$this->__dirfFilesDirectory = dirname(__FILE__) . DS . 'dirf_files';

		$log_directory = dirname(__FILE__) . DS . 'log_files';
		if (!is_dir($log_directory)) {
			mkdir($log_directory);
		}

		$this->__logFile = $log_directory . DS . sprintf('log-%s.txt', date('dmYHis'));

		$this->__connectToDatabase();
	}

	/**
	 * Executa a importação de dados
	 *
	 * @access public
	 * @return void
	 */
	public function run() {
		$this->__dirfFilesQueue = array();

		// Lê a estrutura de diretórios que contém os arquivos de entrada e monta uma fila de importação
		if (is_dir($this->__dirfFilesDirectory)) {
			$years = scandir($this->__dirfFilesDirectory);
			foreach ($years as $year) {
				if (is_dir($this->__dirfFilesDirectory . DS . $year) && !in_array($year, array('.', '..'))) {
					$files = scandir($this->__dirfFilesDirectory . DS . $year);
					foreach ($files as $file) {
						if (is_file($this->__dirfFilesDirectory . DS . $year . DS . $file)) {
							$this->__dirfFilesQueue[] = $this->__dirfFilesDirectory . DS . $year . DS . $file;
						}
					}
				}
			}
		}

		if (!empty($this->__dirfFilesQueue)) {
			// Cria o arquivo de log da importação vigente
			$f = fopen($this->__logFile, 'a');
			fwrite($f, sprintf("Importação iniciada em: %s\n", date('d/m/Y H:i:s')));
			fclose($f);

			// Inicia a importação da fila
			foreach ($this->__dirfFilesQueue as $position => $dirf_file_path) {
				$this->__dirfFilePath = $dirf_file_path;

				$this->__dirfFilesQueueCurrentPosition = $position;

				// Reinicia os atributos de controle
				$this->__dirfId   = null;
				$this->__respoId  = null;
				$this->__decpjId  = null;
				$this->__idrecId  = null;
				$this->__bpfdecId = null;
				$this->__bpjdecId = null;
				$this->__brpdeId  = null;
				$this->__results  = array(
					'inserts_count' => 0,
					'updates_count' => 0,
					'fail_lines'    => array(),
					'ignored_lines' => array()
				);

				// Importa o arquivo DIRF vigente para o banco de dados
				$this->__importDirfFile();

				// Registra o log da importação do arquivo DIRF vigente
				$this->__recordDirfFileLog();
			}

			// Encerra a gravação do log
			$f = fopen($this->__logFile, 'a');
			fwrite($f, sprintf("Importação concluída em: %s \n", date('d/m/Y H:i:s')));
			fclose($f);

			printf("Importação concluída.\nConsulte o log para maiores informações.\n");
		} else {
			printf("Nenhum arquivo encontrado para realização da importação.\n");
		}
	}

	/**
	 * Conecta com o banco de dados
	 *
	 * @access private
	 * @return void
	 */
	private function __connectToDatabase() {
		try {
			$this->__link = new PDO(
				sprintf(
					'mysql:dbname=%s;host=%s',
					$this->__databaseConfig['database'],
					$this->__databaseConfig['host']
				),
				$this->__databaseConfig['user'],
				$this->__databaseConfig['password']
			);

			$this->__link->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		} catch(PDOException $e) {
			echo 'Exception: ' . $e->getMessage() . "\n";
			exit();
		}
	}

	/**
	 * Lê e realiza o parse de um arquivo DIRF
	 *
	 * @access private
	 * @return array $data Dados do arquivo
	 */
	private function __readDirfFile() {
		try {
			@$f = fopen($this->__dirfFilePath, 'r');
			if ($f) {
				while ($line = trim(fgets($f, 1024))) {
					if ($line == 'FIMDIRF|') {
						break;
					}
					$data[] = explode('|', $line);
				}
				fclose($f);

				return $data;
			} else {
				throw new Exception(sprintf('Falha na leitura do arquivo \'%s\'', $file_path));
			}
		} catch(Exception $e) {
			echo $e->getMessage();
			exit();
		}
	}

	/**
	 * Exibe uma barra de carregamento no console
	 *
	 * @access private
	 * @return void
	 */
	private function __printProgressBar() {
		// Calcula da porcentagem de linhas importadas do arquivo vigente
		$percentage = floor(($this->__dirfFileCurrentLineNumber * 100) / $this->__dirfFileLength);

		// Recua o cursor para o início da linha
		$progress_bar = "\033[1;1H";

		// Monta a barra de progresso
		$progress_bar .= sprintf("Importando arquivo %d/%d: [", $this->__dirfFilesQueueCurrentPosition + 1, count($this->__dirfFilesQueue));
		$progress_bar .= str_repeat('#', floor($percentage / 2));
		$progress_bar .= str_repeat(' ', 50 - floor($percentage / 2));
		$progress_bar .= sprintf("] %d%%", $percentage);

		// Limpa a tela no início da exibição
		if ($this->__dirfFilesQueueCurrentPosition == 0 && $this->__dirfFileCurrentLineNumber == 1) {
			$progress_bar = "\033[2J" . $progress_bar;
		}

		// Exibe a barra de progresso
		printf("%s  \n", $progress_bar);
		flush();
	}

	/**
	 * Grava os registros referentes aos resultados de importação de um arquivo DIRF
	 *
	 * @access private
	 * @return void
	 */
	private function __recordDirfFileLog() {
		$f = fopen($this->__logFile, 'a');

		$fail_lines_count = count($this->__results['fail_lines']);
		$ignored_lines_count = count($this->__results['ignored_lines']);

		fwrite($f, sprintf("Arquivo %d/%d: %s\n", $this->__dirfFilesQueueCurrentPosition + 1, count($this->__dirfFilesQueue), $this->__dirfFilePath));
		fwrite($f, sprintf("Total de registros inseridos a partir do arquivo: %d\n", $this->__results['inserts_count']));
		fwrite($f, sprintf("Total de registros atualizados a partir do arquivo: %d\n", $this->__results['updates_count']));
		fwrite($f, sprintf("Total de falhas durante a importação do arquivo: %d\n", $fail_lines_count));
		if ($fail_lines_count > 0) {
			fwrite($f, sprintf("Linhas com falha na importação do arquivo: %s\n", implode(', ', $this->__results['fail_lines'])));
		}
		fwrite($f, sprintf("Total de linhas ignoradas durante a importação do arquivo: %d\n", $ignored_lines_count));
		if ($ignored_lines_count > 0) {
			fwrite($f, sprintf("Linhas ignoradas durante a importação do arquivo: %s\n", implode(', ', $this->__results['ignored_lines'])));
		}
		$status = $fail_lines_count > 0 ? 'algumas falhas' : 'sucesso';
		fwrite($f, sprintf("Status: Arquivo importado com %s.\n", $status));

		fclose($f);
	}

	/**
	 * Seleciona o Id de um registro com base em um conjunto de condições
	 *
	 * @param string $table Tabela a ser consultada
	 * @param array $conditions Conjunto de condições restritivas
	 * @access private
	 * @return void
	 */
	private function __selectRecordId($table, $conditions) {
		$id = null;

		$bind_parameters = array();

		$where_clause = array();
		foreach ($conditions as $field => $value) {
			if (is_null($value)) {
				$where_clause[] = sprintf('%s.%s IS NULL', $table, $field);
			} else {
				$where_clause[] = sprintf('%s.%s = ?', $table, $field);
				$bind_parameters[] = $value;
			}
		}

		$where_clause = !empty($where_clause) ? implode(' AND ', $where_clause) : '1 = 1';

		$statement = sprintf(
			'SELECT %s.id FROM %s WHERE %s;',
			$table,
			$table,
			$where_clause
		);

		$prepared_statement = $this->__link->prepare($statement);

		$prepared_statement->execute(array_values($bind_parameters));

		if ($result = $prepared_statement->fetch()) {
			$id = intval($result['id']);
		}

		return $id;
	}

	/**
	 * Insere um registro no banco de dados
	 *
	 * @param array $table Tabela a ser atualizada
	 * @param array $data Dados referentes ao registro a ser atualizado
	 * @access private
	 * @return void
	 */
	private function __insertRecord($table, $data) {
		try {
			$this->__link->beginTransaction();

			$fields = implode(', ', array_keys($data));
			$placeholders = implode(', ', array_fill(0, count($data), '?'));
			$statement = sprintf('INSERT INTO %s(%s) VALUES(%s);', $table, $fields, $placeholders);

			$prepared_statement = $this->__link->prepare($statement);

			$prepared_statement->execute(array_values($data));

			$this->__link->commit();

			$this->__results['inserts_count']++;
		} catch(Exception $e) {
			$this->__link->rollBack();
			$this->__results['fail_lines'][] = $this->__dirfFileCurrentLineNumber;
		}
	}

	/**
	 * Atualiza um registro no banco de dados
	 *
	 * @param array $table Tabela a ser atualizada
	 * @param array $data Dados atualizados
	 * @param array $conditions Condições para a atualização de registros
	 * @access private
	 * @return void
	 */
	private function __updateRecord($table, $data, $conditions) {
		try {
			$this->__link->beginTransaction();

			$fields = array();
			foreach (array_keys($data) as $field) {
				$fields[] = sprintf('%s = ?', $field);
			}

			$where_clause = array();
			foreach ($conditions as $field => $value) {
				if (is_null($value)) {
					unset($conditions[$field]);
					$where_clause[] = sprintf('%s IS NULL', $field);
				} else {
					$where_clause[] = sprintf('%s = ?', $field);
				}
			}

			$statement = sprintf('UPDATE %s SET %s WHERE %s;', $table, implode(', ', $fields), implode(' AND ', $where_clause));

			$prepared_statement = $this->__link->prepare($statement);

			$bind_parameters = array_merge(array_values($data), array_values($conditions));

			$prepared_statement->execute($bind_parameters);

			$this->__link->commit();

			$this->__results['updates_count']++;
		} catch(Exception $e) {
			$this->__link->rollBack();
			$this->__results['fail_lines'][] = $this->__dirfFileCurrentLineNumber;
		}
	}

	/**
	 * Importa os dados de um arquivo DIRF
	 *
	 * @access private
	 * @return void
	 */
	private function __importDirfFile() {
		/*
		 * @todo Abortar importação e fazer rollback dos registros modificados em caso de qualquer falha de inserção
		 */

		$dirf_file = $this->__readDirfFile();

		$this->__dirfFileLength = count($dirf_file);

		$this->__dirfFileCurrentLineNumber = 1;

		/*
		 * Percorre as linhas do arquivo e executa o método de importação adequado de
		 * acordo com o identificador da linha vigente
		 */
		foreach ($dirf_file as $line) {
			$this->__printProgressBar();

			$identifier = strtoupper($line[0]);

			switch ($identifier) {
				case 'DIRF':
					$this->__importDirfHeader($line);
					break;
				case 'RESPO':
					$this->__importRespo($line);
					break;
				case 'DECPJ':
					$this->__importDecpj($line);
					break;
				case 'IDREC':
					$this->__importIdrec($line);
					break;
				case 'BPFDEC':
					$this->__importBpfdec($line);
					break;
				case 'BPJDEC':
					$this->__importBpjdec($line);
					break;
				case 'RTRT':
				case 'RTPO':
				case 'RTPP':
				case 'RTDP':
				case 'RTPA':
				case 'RTIRF':
				case 'CJAC':
				case 'CJAA':
				case 'ESRT':
				case 'ESPO':
				case 'ESPP':
				case 'ESDP':
				case 'ESPA':
				case 'ESIR':
				case 'ESDJ':
				case 'RIDAC':
				case 'RIIRP':
				case 'RIAP':
				case 'RIMOG':
				case 'RIP65':
				case 'RIVC':
				case 'RIBMR':
				case 'RICAP':
				case 'RIL96':
				case 'RIPTS':
				case 'RIO':
					$this->__importIncomes($line);
					break;
				case 'BRPDE':
					$this->__importBrpde($line);
					break;
				case 'VRPDE':
					$this->__importVrpde($line);
					break;
				default:
					$this->__results['ignored_lines'][] = $this->__dirfFileCurrentLineNumber;
			}

			$this->__dirfFileCurrentLineNumber++;
		}
	}

	/**
	 * Importa dados referentes ao header do DIRF
	 *
	 * @param int $line Linha do arquivo DIRF
	 * @access private
	 * @return void
	 */
	private function __importDirfHeader($line) {
		// Configura os dados da linha vigente de acordo com as respectivas colunas da tabela "dirf" do banco de dados
		$data = array(
			'reference_year'          => !empty($line[1]) ? $line[1]              : null,
			'calendar_year'           => !empty($line[2]) ? $line[2]              : null,
			'rectification_indicator' => $line[3] == 'S'  ? 1                     : 0,
			'receipt_number'          => !empty($line[4]) ? $line[4]              : null,
			'layout_structure_id'     => !empty($line[5]) ? utf8_decode($line[5]) : null,
			'modified'                => date('Y-m-d H:i:s')
		);

		// Verifica a existência de registro equivalente na tabela "dirf" do banco de dados
		$this->__dirfId = $this->__selectRecordId(
			'dirf',
			array(
				'reference_year'          => $data['reference_year'],
				'calendar_year'           => $data['calendar_year'],
				'rectification_indicator' => $data['rectification_indicator'],
				'receipt_number'          => $data['receipt_number'],
				'layout_structure_id'     => $data['layout_structure_id']
			)
		);
		// Se o registro já existe, o mesmo é atualizado. Caso contrário, um registro novo é criado
		if (!is_null($this->__dirfId)) {
			$this->__updateRecord('dirf', $data, array('id' => $this->__dirfId));
		} else {
			$data['created'] = $data['modified'];

			$this->__insertRecord('dirf', $data);

			// Configura o atributo "__dirfId" após realizar a inserção do registro
			$this->__dirfId = $this->__selectRecordId(
				'dirf',
				array(
					'reference_year'          => $data['reference_year'],
					'calendar_year'           => $data['calendar_year'],
					'rectification_indicator' => $data['rectification_indicator'],
					'receipt_number'          => $data['receipt_number'],
					'layout_structure_id'     => $data['layout_structure_id']
				)
			);
		}
	}

	/**
	 * Importa dados referentes ao responsável pelo preenchimento
	 *
	 * @param int $line Linha do arquivo DIRF
	 * @access private
	 * @return void
	 */
	private function __importRespo($line) {
		// Configura os dados da linha vigente de acordo com as respectivas colunas da tabela "respo" no banco de dados
		$data = array(
			'cpf'             => !empty($line[1]) ? $line[1]              : null,
			'name'            => !empty($line[2]) ? utf8_decode($line[2]) : null,
			'area_code'       => !empty($line[3]) ? $line[3]              : null,
			'phone_number'    => !empty($line[4]) ? $line[4]              : null,
			'phone_extension' => !empty($line[5]) ? $line[5]              : null,
			'fax'             => !empty($line[6]) ? $line[6]              : null,
			'email'           => !empty($line[7]) ? utf8_decode($line[7]) : null,
			'modified'        => date('Y-m-d H:i:s')
		);

		// Verfica a existência de registro equivalente na tabela "respo" do banco de dados
		$this->__respoId = $this->__selectRecordId(
			'respo',
			array(
				'cpf' => $data['cpf']
			)
		);

		// Se o registro já existe, o mesmo é atualizado. Caso contrário, um registro novo é criado
		if (!is_null($this->__respoId)) {
			$this->__updateRecord('respo', $data, array('id' => $this->__respoId));
		} else {
			$data['created'] = $data['modified'];

			$this->__insertRecord('respo', $data);

			// Configura o id do responsável recém inserido
			$this->__respoId = $this->__selectRecordId(
				'respo',
				array(
					'cpf' => $data['cpf']
				)
			);
		}
	}

	/**
	 * Importa dados referentes ao declarante pessoa jurídica
	 *
	 * @param int $line Linha do arquivo DIRF
	 * @access private
	 * @return void
	 */
	private function __importDecpj($line) {
		// Configura os dados da linha vigente de acordo com as respectivas colunas da tabela "decpj" no banco de dados
		$event_date = null;
		if (!empty($line[13])) {
			$event_date = sprintf(
				'%d-%d-%d',
				substr($line[13], 4, 4),
				substr($line[13], 2, 2),
				substr($line[13], 0, 2)
			);
		}

		$data = array(
			'cnpj'                        => !empty($line[1]) ? $line[1]              : null,
			'company_name'                => !empty($line[2]) ? utf8_decode($line[2]) : null,
			'declarant_nature'            => intval($line[3]),
			'responsible_cpf'             => !empty($line[4]) ? $line[4]              : null,
			'ostensive_partner'           => $line[5] == 'S'  ? 1                     : 0,
			'court_decision_depositary'   => $line[6] == 'S'  ? 1                     : 0,
			'investment_fund_institution' => $line[7] == 'S'  ? 1                     : 0,
			'incomes_paid_abroad'         => $line[8] == 'S'  ? 1                     : 0,
			'private_healthcare'          => $line[9] == 'S'  ? 1                     : 0,
			'fifa_worldcups_payments'     => $line[10] == 'S' ? 1                     : 0,
			'olympic_games_payments'      => $line[11] == 'S' ? 1                     : 0,
			'special_situation'           => $line[12] == 'S' ? 1                     : 0,
			'event_date'                  => $event_date,
			'modified'                    => date('Y-m-d H:i:s')
		);

		// Verfica a existência de registro equivalente na tabela "decpj" do banco de dados
		$this->__decpjId = $this->__selectRecordId(
			'decpj',
			array(
				'cnpj' => $data['cnpj']
			)
		);

		// Se o registro já existe, o mesmo é atualizado. Caso contrário, um registro novo é criado.
		if (!is_null($this->__decpjId)) {
			$this->__updateRecord('decpj', $data, array('id' => $this->__decpjId));
		} else {
			$data['created'] = $data['modified'];

			$this->__insertRecord('decpj', $data);

			// Configura o atributo "__decpjId" após realizar a inserção do registro
			$this->__decpjId = $this->__selectRecordId(
				'decpj',
				array(
					'cnpj' => $data['cnpj']
				)
			);
		}
	}

	/**
	 * Importa dados referentes ao registro de identificação do código de receita
	 *
	 * @param int $line Linha do arquivo DIRF
	 * @access private
	 * @return void
	 */
	private function __importIdrec($line) {
		$sql_command = null;

		// Configura os dados da linha vigente de acordo com as respectivas colunas da tabela "idrec" no banco de dados
		$data = array(
			'revenue_code' => !empty($line[1]) ? $line[1] : null,
			'modified'     => date('Y-m-d H:i:s')
		);

		// Verfica a existência de registro equivalente na tabela "idrec" do banco de dados
		$this->__idrecId = $this->__selectRecordId(
			'idrec',
			array(
				'revenue_code' => $data['revenue_code']
			)
		);

		// Se o registro já existe, o mesmo é atualizado. Caso contrário, um registro novo é criado.
		if (!is_null($this->__idrecId)) {
			$this->__updateRecord('idrec', $data, array('id' => $this->__idrecId));
		} else {
			$data['created'] = $data['modified'];

			$this->__insertRecord('idrec', $data);

			// Configura o atributo "__idrecId" após realizar a inserção do registro
			$this->__idrecId = $this->__selectRecordId(
				'idrec',
				array(
					'revenue_code' => $data['revenue_code']
				)
			);
		}
	}

	/**
	 * Importa dados referentes ao beneficiário pessoa física do declarante
	 *
	 * @param int $line Linha do arquivo DIRF
	 * @access private
	 * @return void
	 */
	private function __importBpfdec($line) {
		/*
		 * Configura o atributo "__bpjdecId" como nulo para que subsequentemente, na execução do método
		 * "__importIncomes()", os registros de valores mensais de rendimentos e imposto retido na fonte
		 * possam ser identificados como pertencentes a um beneficiario pessoa física
		 */
		$this->__bpjdecId = null;

		// Configura os dados da linha vigente de acordo com as respectivas colunas da tabela "bpfdec" no banco de dados
		$data = array(
			'cpf'                 => !empty($line[1]) ? $line[1]              : null,
			'name'                => !empty($line[2]) ? utf8_decode($line[2]) : null,
			'severe_disease_date' => !empty($line[3]) ? $line[3]              : null,
			'modified'            => date('Y-m-d H:i:s')
		);

		// Verfica a existência de registro equivalente na tabela "bpfdec" do banco de dados
		$this->__bpfdecId = $this->__selectRecordId(
			'bpfdec',
			array(
				'cpf' => $data['cpf']
			)
		);

		// Se o registro já existe, o mesmo é atualizado. Caso contrário, um registro novo é criado
		if (!is_null($this->__bpfdecId)) {
			$this->__updateRecord('bpfdec', $data, array('id' => $this->__bpfdecId));
		} else {
			$data['created'] = $data['modified'];

			$this->__insertRecord('bpfdec', $data);

			// Configura o atributo "__bpfdecId" após realizar a inserção do registro
			$this->__bpfdecId = $this->__selectRecordId(
				'bpfdec',
				array(
					'cpf' => $data['cpf']
				)
			);
		}
	}

	/**
	 * Importa dados referentes ao beneficiário pessoa jurídica do declarante
	 *
	 * @param int $line Linha do arquivo DIRF
	 * @access private
	 * @return void
	 */
	private function __importBpjdec($line) {
		/*
		 * Configura o atributo "__bpfdecId" como nulo para que subsequentemente, na execução do método
		 * "__importIncomes()", os registros de valores mensais de rendimentos e imposto retido na fonte
		 * possam ser identificados como pertencentes a um beneficiario pessoa jurídica
		 */
		$this->__bpfdecId = null;

		// Configura os dados da linha vigente de acordo com as respectivas colunas da tabela "bpjdec" no banco de dados
		$data = array(
			'cnpj'         => !empty($line[1]) ? $line[1]              : null,
			'company_name' => !empty($line[2]) ? utf8_decode($line[2]) : null,
			'modified'     => date('Y-m-d H:i:s')
		);

		// Verfica a existência de registro equivalente na tabela "bpjdec" do banco de dados
		$this->__bpjdecId = $this->__selectRecordId(
			'bpjdec',
			array(
				'cnpj' => $data['cnpj']
			)
		);

		// Se o registro já existe, o mesmo é atualizado. Caso contrário, um registro novo é criado
		if (!is_null($this->__bpjdecId)) {
			$this->__updateRecord('bpjdec', $data, array('id' => $this->__bpjdecId));
		} else {
			$data['created'] = $data['modified'];

			$this->__insertRecord('bpjdec', $data);

			// Configura o atributo "__bpjdecId" após realizar a inserção do registro
			$this->__bpjdecId = $this->__selectRecordId(
				'bpjdec',
				array(
					'cnpj' => $data['cnpj']
				)
			);
		}
	}

	/**
	 * Importa dados referentes ao registro de valores mensais e/ou anuais de rendimentos e imposto retido na fonte
	 *
	 * @param int $line Linha do arquivo DIRF
	 * @access private
	 * @return void
	 */
	private function __importIncomes($line) {

		/*
		 * Configura os valores em comum entre os rendimentos mensais e anuais de acordo com as colunas
		 * da tabela "incomes" do banco de dados
		 */
		$type = utf8_decode($line[0]);
		$common_data = array(
			'dirf_id'   => $this->__dirfId,
			'respo_id'  => $this->__respoId,
			'decpj_id'  => $this->__decpjId,
			'idrec_id'  => $this->__idrecId,
			'bpfdec_id' => $this->__bpfdecId,
			'bpjdec_id' => $this->__bpjdecId,
			'type'      => $type,
			'modified'  => date('Y-m-d H:i:s')
		);

		/*
		 * Verifica se o registro é referente a um rendimento mensal ou anual e configura, formata
		 * o registro de acordo com seu tipo e o insere em buffer de inserção/atualização no banco
		 * de dados
		 */
		$buffer = array();
		if (!in_array($type, array('RIL96', 'RIPTS', 'RIO'))) {
			// Rendimentos mensais
			for ($c = 1; $c <= 13; $c++) {
				$value = !empty($line[$c]) ? floatval(intval($line[$c]) / 100) : 0;
				$specific_data = array(
					'month'       => $c,
					'description' => null,
					'value'       => $value
				);

				$buffer[] = array_merge($common_data, $specific_data);
			}
		} else {
			// Rendimentos anuais
			$value = !empty($line[1]) ? floatval(intval($line[1]) / 100) : 0;
			$specific_data = array(
				'month'       => null,
				'description' => !empty($line[2]) ? utf8_decode($line[2]) : null,
				'value'       => $value
			);

			$buffer[] = array_merge($common_data, $specific_data);
		}

		// Percorre o buffer criado para realizar as interações com o banco de dados
		foreach ($buffer as $record) {
			// Verfica a existência de registro equivalente na tabela "incomes" do banco de dados
			$conditions = array(
				'dirf_id'   => $this->__dirfId,
				'respo_id'  => $this->__respoId,
				'decpj_id'  => $this->__decpjId,
				'idrec_id'  => $this->__idrecId,
				'bpfdec_id' => $this->__bpfdecId,
				'bpjdec_id' => $this->__bpjdecId,
				'type'      => $record['type'],
				'month'     => $record['month']
			);

			$incomes_id = $this->__selectRecordId('incomes', $conditions);

			// Se o registro já existe, o mesmo é atualizado. Caso contrário, um registro novo é criado
			if (!is_null($incomes_id)) {
				$this->__updateRecord('incomes', $record, array('id' => $incomes_id));
			} else {
				$record['created'] = $record['modified'];

				$this->__insertRecord('incomes', $record);
			}
		}
	}

	/**
	 * Importa dados referentes ao registo de beneficiário dos rendimentos
	 * pagos a residentes ou domiciliados no exterior
	 *
	 * @param int $line Linha do arquivo DIRF
	 * @access private
	 * @return void
	 */
	private function __importBrpde($line) {
		$sql_command = null;

		// Configura os dados da linha vigente de acordo com as respectivas colunas da tabela "brpde" no banco de dados
		$data = array(
			'dirf_id'                        => $this->__dirfId,
			'beneficiary_type'               => !empty($line[1])  ? $line[1]               : null,
			'country_code'                   => !empty($line[2])  ? $line[2]               : null,
			'nif'                            => !empty($line[3])  ? utf8_decode($line[3])  : null,
			'nif_dispensed_beneficiary'      => $line[4] == 'S'   ? 1                      : 0,
			'nif_dispensed_country'          => $line[5] == 'S'   ? 1                      : 0,
			'cpf_cnpj'                       => !empty($line[6])  ? $line[6]               : null,
			'name'                           => !empty($line[7])  ? utf8_decode($line[7])  : null,
			'payer_beneficiary_relationship' => !empty($line[8])  ? $line[8]               : null,
			'street'                         => !empty($line[9])  ? utf8_decode($line[9])  : null,
			'number'                         => !empty($line[10]) ? utf8_decode($line[10]) : null,
			'complement'                     => !empty($line[11]) ? utf8_decode($line[11]) : null,
			'district'                       => !empty($line[12]) ? utf8_decode($line[12]) : null,
			'zip_code'                       => !empty($line[13]) ? $line[13]              : null,
			'city'                           => !empty($line[14]) ? utf8_decode($line[14]) : null,
			'state'                          => !empty($line[15]) ? utf8_decode($line[15]) : null,
			'phone_number'                   => !empty($line[16]) ? $line[16]              : null,
			'modified' => date('Y-m-d H:i:s')
		);

		// Verfica a existência de registro equivalente na tabela "brpde" do banco de dados
		$this->__brpdeId = $this->__selectRecordId(
			'brpde',
			array(
				'dirf_id' => $this->__dirfId,
				'name'    => $data['name']
			)
		);

		// Se o registro já existe, o mesmo é atualizado. Caso contrário, um registro novo é criado
		if (!is_null($this->__brpdeId)) {
			$this->__updateRecord('brpde', $data, array('id' => $this->__brpdeId));
		} else {
			$data['created'] = $data['modified'];

			$this->__insertRecord('brpde', $data);

			// Configura o atributo "__brpdeId" após realizar a inserção do registro
			$this->__brpdeId = $this->__selectRecordId(
				'brpde',
				array(
					'dirf_id' => $this->__dirfId,
					'name'    => $data['name']
				)
			);
		}
	}

	/**
	 * Importa dados referentes ao registro de valores de rendimentos pagos a
	 * residentes ou domiciliados no exterior
	 *
	 * @param int $line Linha do arquivo DIRF
	 * @access private
	 * @return void
	 */
	private function __importVrpde($line) {
		$sql_command = null;

		// Configura os dados da linha vigente de acordo com as respectivas colunas da tabela "vrpde" no banco de dados
		$data = array(
			'brpde_id'      => $this->__brpdeId,
			'payment_date'  => !empty($line[1]) ? $line[1]              : null,
			'revenue_code'  => !empty($line[2]) ? utf8_decode($line[2]) : null,
			'income_type'   => !empty($line[3]) ? utf8_decode($line[3]) : null,
			'paid_income'   => !empty($line[4]) ? intval($line[4])      : null,
			'withheald_tax' => !empty($line[5]) ? intval($line[5])      : null,
			'taxation_mode' => !empty($line[6]) ? utf8_decode($line[6]) : null,
			'modified'      => date('Y-m-d H:i:s')
		);

		// Verfica a existência de registro equivalente na tabela "vrpde" do banco de dados
		$vrpde_id = $this->__selectRecordId(
			'vrpde',
			array(
				'brpde_id'     => $data['brpde_id'],
				'revenue_code' => $data['revenue_code'],
				'income_type'  => $data['income_type']
			)
		);

		// Se o registro já existe, o mesmo é atualizado. Caso contrário, um registro novo é criado
		if (!is_null($vrpde_id)) {
			$this->__updateRecord('vrpde', $data, array('id' => $vrpde_id));
		} else {
			$data['created'] = $data['modified'];
			$this->__insertRecord('vrpde', $data);
		}
	}

	// Destrutor
	public function __destruct() {
		// Encerra a conexão com o banco de dados
		$this->__link = null;
	}
}

$import = new ImportDirfFiles();
$import->run();
?>