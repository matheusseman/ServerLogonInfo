# serverLogonInfo.sh

## Descrição
Este script foi desenvolvido para exibir informações detalhadas após o logon em servidores Linux. Inicialmente, foi criado para funcionar em sistemas da família Debian, sendo implementado, neste exemplo específico, em um servidor Ubuntu Server 22.04 com Zabbix instalado para monitoramento.

![exemplo](https://github.com/matheusseman/ServerLogonInfo/assets/119596051/c89745ea-2974-4022-84c4-f46ae0aac937)

## Configuração
O script deve ser alocado no diretório `/usr/local/bin` e sua execução deve ser adicionada ao arquivo `.bashrc` de cada usuário para exibir as informações após o login.

## Funcionalidades
Na sua versão inicial, o script fornece as seguintes informações após o login do usuário:

- Nome do servidor
- Tempo ligado (uptime)
- Distribuição Linux
- Descrição da função do servidor
- Impacto na infraestrutura de rede
- Endereço IP local
- Endereço IP público
- Informações sobre partições
- Estado dos serviços do servidor

## Dependências
O script depende dos seguintes pacotes:
- `bc`
- `curl`

Se estas dependências não estiverem instaladas, o script solicitará a permissão para instalá-las automaticamente.

## Personalização
Para configurar o script no servidor, é necessário realizar algumas alterações no script base:

- Atualize o array `SERVICOS` com os nomes dos serviços dos quais deseja exibir o estado.
- Atualize o array `PARTICOES` com as partições ao qual deseja exibir informações.
- Atualize a variável `DESCRICAO_SERVIDOR` com uma descrição sucinta do servidor.
- Atualize a variável `IMPACTO_SERVIDOR` com:
  - Nível de criticidade do servidor em relação à infraestrutura.
  - Cor, dependendo do nível de criticidade (Alto=vermelho, Médio=amarelo, Baixo=azul).

## Uso
O script oferece algumas opções de argumento para facilitar seu uso:

### Opções de argumento:
- `--help` | `-help` | `help` | `-h`: Fornece uma lista de ajuda;
- `--version` | `-version` | `version` | `-v`: Exibe informações de versionamento e licença do script;

### Exemplos de uso:
- Para exibir a ajuda:
  ```bash
  ./serverLogonInfo.sh --help

## Futuras Implementações
Está prevista a adição de informações sobre rotinas de backup Veeam ao script. Essas informações serão apresentadas de outro repositório que será adicionado ao GitHub, incluindo o script responsável por obter as informações das rotinas de backup, as alterações necessárias no script `serverLogonInfo.sh` e a posterior configuração do monitoramento Zabbix para tais informações.
