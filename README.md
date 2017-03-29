# ImportDirfFiles
Estrutura de dados e script de importação dos arquivos de declaração de imposto de renda retido na fonte (DIRF) disponibilizados pela Receita Federal Brasileira

## Dependências:
  * PHP 5+
  * MySQL 5+

## Modo de uso:

### Banco de dados:
Um banco de dados MySQL deve ser criado através do arquivo `database_schema.sql`. Exemplo:
`mysql -uroot -p -h127.0.0.1 < database_schema.sql`.

### Estruturação dos arquivos DIRF:
Na raiz do projeto deve ser criado o diretório `/dirf_files` contendo subdiretórios nomeados de acordo com o ano calendário dos arquivos DIRF neles contidos. Exemplo:

```
/ImportDirfFiles/
│
└───dirf_files/
│   │
│   └───2015/
│   │   │
│   │   └─── dirf_file_2015a.txt
│   │   │
│   │   └─── dirf_file_2015b.txt
│   │   │
│   │   └─── dirf_file_2015c.txt   
│   └───2016/
│   │   │   
│   │   └─── dirf_file_2016a.txt
│   │   │   
│   │   └─── dirf_file_2016b.txt
│   └───2017/
│   │   │
│   │   └─── dirf_file_2017a.txt

```

Obs.: Os nomes dos arquivos DIRF são irrelevantes.

### Execução do script de importação de dados:
Em seguida basta executar o script `import_dirf_files.php` no console de sua preferência. Exemplo: 
`php import_dirf_files.php`
