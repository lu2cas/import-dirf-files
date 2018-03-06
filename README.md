# import-dirf-files
Estrutura de dados e script de importação dos arquivos de declaração de imposto de renda retido na fonte (DIRF) disponibilizados pela Receita Federal Brasileira

## Dependências:
  * PHP 5+
  * MySQL 5+

## Modo de uso:

### Banco de dados:
Um banco de dados MySQL deve ser criado a partir do arquivo `database_schema.sql`. Exemplo:
`mysql -uroot -p -h127.0.0.1 < database_schema.sql`.

Em seguida o arquivo `database_config.json` deve ser atualizado com os dados do banco de dados recém criado.

### Estruturação dos arquivos DIRF:
O diretório `/dirf_files` deve ser criado na raiz do projeto contendo subdiretórios nomeados de acordo com o ano calendário dos arquivos DIRF neles contidos. Exemplo:

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
Finalmente o script `import_dirf_files.php` pode ser executado no console de sua preferência. Exemplo: 
`php import_dirf_files.php`.
