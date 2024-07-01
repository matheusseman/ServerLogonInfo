#!/bin/bash
##########################################################################################################################
#------------------------------------------------------------------------------------------------------------------------#
#--------------------------------------------------- INFORMAÇÕES---------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------#
# Arquivo ~~~~ serverLogonInfo.sh
# Descrição ~~ Script desenvolvido para exibição de informações importantes do host após o início de sessão.
# Autor ~~~~~~ Matheus Seman < mateusseman@gmail.com>
#------------------------------------------------------------------------------------------------------------------------#
##########################################################################################################################
#------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------ ARRAYS ----------------------------------------------------------#

# Arrays dinâmicos (Devem ser adicionados para se adequar a infraestrutura da rede) #------------------------------------#

declare -A PARTICOES=(
        [raiz]="/"
        [boot]="/boot"
) # Partições para verificação de espaço

declare -a SERVICOS=(
    "zabbix-server" "ssh" "apache2" "mysql"
) # Serviços para validação no servidor "serviço" "serviço"

# Arrays estáticos #-----------------------------------------------------------------------------------------------------#
declare -A CORES=( 
                [none]="\033[m"
                [preto]="\033[1;30m"
                [vermelho]="\033[1;31m"
                [verde]="\033[1;32m"
                [amarelo]="\033[1;33m"
                [azul]="\033[1;34m"
                [magenta]="\033[1;35m"
                [ciano]="\033[1;36m"
                [branco]="\033[1;37m"
) # Cores para melhor visualizaçao dos dados

declare -A DEPENDENCIAS=(
        [bc]="/usr/bin/bc"
        [curl]="/usr/bin/curl"
) # Dependencias necessárias para execução do script
#------------------------------------------------------------------------------------------------------------------------#
##########################################################################################################################
#------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------- VARIÁVEIS ---------------------------------------------------------#

# Variáveis dinâmicas #--------------------------------------------------------------------------------------------------#
DESCRICAO_SERVIDOR="Servidor de monitoramento de rede Zabbix." # Descrição da função do servidor
IMPACTO_SERVIDOR="${CORES[vermelho]}Alto${CORES[none]}" # Impacto do servidor na rede

# Variáveis estáticas #--------------------------------------------------------------------------------------------------#
VERSAO=v1.2 # Versão do script
HOST_NOME=$(hostname) # Armazena o hostname do host
ENDERECO_PUBLICO=$(curl -s ifconfig.me) # Endereço público do host
ENDERECO_LOCAL=$(hostname -I | awk '{print $1}') # Endereço local do host
SCRIPT=${0##*/} # Retorna o nome do script
SCRIPT_DIR=/usr/local/bin # Local aonde o script é armazenado
DISTRO_INFO="" # Armazena as informações da distribuição do host
PARTICOES_INFO="" # Armaza informações da raiz do sistema
SERVICOS_INFO="" # Armazena as informações dos serviços 
SERVICOS_QNT=0 # Armazena a quantidade dos serviços em execução
#------------------------------------------------------------------------------------------------------------------------#
##########################################################################################################################
#------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------- FUNÇOES -----------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------#
function _principal_() {
    #----------------------------------------------------------------------------------------------------------------------------#
    # Verifica as dependências do script #---------------------------------------------------------------------------------------#
    local instalacaoValidacao="false" # Variável de controle
    for dependencia in "${!DEPENDENCIAS[@]}" ; do 
        if [[ ! -e "${DEPENDENCIAS[$dependencia]}" ]] ; then # Caso a dependencia não esteja instalada
            if [[ $instalacaoValidacao = "false" ]] ; then
                read -p "Para execução do script, os pacotes bc e curl devem ser adicionados. Deseja prosseguir? [S/N]:" instalacaoForm
                case $instalacaoForm in 
                    "não" | "nao" | "Não" | "Nao" | "NÃO" | "NAO" | "n" | "N") 
                        echo -e "${CORES[branco]}[ ${CORES[amarelo]}!${CORES[none]} ${CORES[branco]}]${CORES[none]} ~ Cancelando instalação..." ; sleep 1
                        exit 0
                    ;;
                    "sim" | "Sim" | "SIM" | "s" | "S") 
                        instalacaoValidacao="true"
                    ;;
                    *)
                        echo -e "[ ${CORES[VERMELHO]}✖${CORES[NONE]} ] ~ Opção inválida..." ; sleep 1
                    ;;
                esac                
            fi
            if [[ $instalacaoValidacao = "true" ]] ; then
                echo -e "${CORES[branco]}[ ${CORES[amarelo]}!${CORES[none]} ${CORES[branco]}]${CORES[none]} ~ Baixando/instalando pacote $dependencia..." ; sleep 1
                apt-get install $dependencia -y # Faz a instalação das dependencias
                if [[ $? = 1 ]] ; then
                    echo -e "[ ${CORES[VERMELHO]}✖${CORES[NONE]} ] ~ Falha na instalação dos pacotes, abortando..." ; sleep 1
                fi
            fi
        fi
    done
    
    # Levantamento de informações do S.O #--------------------------------------------------------------------------------------#
    for particao in "${!PARTICOES[@]}" ; do
        _verifParticao_ $(df ${PARTICOES[$particao]} | grep -v Filesystem | awk '{print $1}')
    done 

    _verifDistro_ 
    _verifServicos_
    
    # Saída principal do script #-----------------------------------------------------------------------------------------------#
    clear ; _divisor_ "-"   
    echo -e "
    ${CORES[vermelho]}\t\t\t  ACESSO RESTRITO${CORES[none]} 

    Este servidor é exclusivo da empresa XYZ seguindo as diretrizes 
    \t\t\t   de segurança.

    Apenas pessoal autorizado tem acesso, e todas as atividades são 
    \tregistradas para garantir a conformidade e segurança.
    "
    _divisor_ "-"
    echo -e "\nServidor: $HOST_NOME (${CORES[amarelo]}Ligado há $uptimeServidor${CORES[none]})"
    echo -e "Distribuição: $DISTRO_INFO"
    echo -e "Função: $DESCRICAO_SERVIDOR"
    echo -e "Impacto infraestrutura: $IMPACTO_SERVIDOR"
    echo -e "Endereço local: $ENDERECO_LOCAL"
    echo -e "Endereço público: $ENDERECO_PUBLICO"
    echo -e "$PARTICOES_INFO"
    echo -e "Estado serviços (${CORES[amarelo]}$SERVICOS_QNT${CORES[none]}): \n$SERVICOS_INFO"
    _divisor_ "-"
    #----------------------------------------------------------------------------------------------------------------------------#
} # Funçao para exibição das informações

function _versaoScript_() {
    #------------------------------------------------------------------------------------------------------------------------#
    echo -e "Script desenvolvido para exibição de informações importantes do host após o início de sessão. (GNU Linux) - ${CORES[amarelo]}$SCRIPT $VERSAO${CORES[none]}"               
    echo "Copyright (C) 2024 Free Software Foundation."                                                              
    echo "Este software é livre, você é livre para alterá-lo e redistribuí-lo."                                      
    echo -e "Escrito e desenvolvido por ${CORES[amarelo]}Matheus Seman${CORES[none]}."                                              
    #------------------------------------------------------------------------------------------------------------------------#
} # Funçao para informações sobre a versao do script

function _ajudaScript_() {
    #--------------------------------------------------------------------------------------------------------------------#
    echo "
    Uso: ./$SCRIPT 
    GNU "$SCRIPT" foi desenvolvido para exibição de informações importantes após o login do usuário...

    Exemplos:

        Opções de argumento:

            --help | -help | help | -h                       Fornece uma lista de ajuda;

            --version | -version | version | -v              Exibe Informações de versionamento e licença do script;

    Enviar report de bugs para < mateusseman@gmail.com >.
    "
    #--------------------------------------------------------------------------------------------------------------------#
} # Função para ajuda na execução script

function _divisor_() {
    #----------------------------------------------------------------------------------------------------------------------------#
    echo -e "${CORES[amarelo]}#${CORES[branco]}----------------------------------------------------------------------${CORES[amarelo]}#${CORES[none]}"
    #----------------------------------------------------------------------------------------------------------------------------#
} # Função para exibição do separador de texto

function _verifDistro_() {
    #------------------------------------------------------------------------------------------------------------------------#
    # Validação de distribuição #--------------------------------------------------------------------------------------------#
    if [ -f /etc/os-release ] ; then # Se houver /etc/os-release
        source /etc/os-release # Usando /etc/os-release para obter informações
        DISTRO_INFO+="$NAME"
        DISTRO_INFO+=" $VERSION"

    # Família Redhat #-------------------------------------------------------------------------------------------------------#
    elif [ -f /etc/redhat-release ] ; then # Se houver /etc/redhat-release (para distribuições Red Hat)
        DISTRO_INFO+=$(cat /etc/redhat-release)
    
    # Família Debian #-------------------------------------------------------------------------------------------------------#
    elif [ -f /etc/debian_version ] ; then # Se houver /etc/debian_version (para distribuições Debian)
        DISTRO_INFO+="Debian"
        DISTRO_INFO+=$(cat /etc/debian_version)

    # Desconhecido #-------------------------------------------------------------------------------------------------------#
    else
        DISTRO_INFO+="Não foi possível identificar a distribuição."
    fi
    # Variáveis internas de controle #-----------------------------------------------------------------------------------#
    uptimeServidor=$(echo $(uptime) | awk '{print $3}' | tr -d ',') # Obtém o tempo de atividade do servidor
    uptimeUnid=$(uptime | awk '{print $4}' | tr -d ',') # Obtém a unidade de tempo (min, day, days, etc.)
    case $uptimeUnid in # Verifica a unidade de tempo e formata a string uptimeServidor adequadamente
        "min")
            uptimeServidor+=" minutos"
            ;;
        "day" | "days")
            uptimeServidor+=" dia"
            if [[ $uptimeServidor != "1" ]]; then
                uptimeServidor+="s"
            fi
            ;;
        *)
            uptimeServidor+=" horas"
            ;;
    esac
    #------------------------------------------------------------------------------------------------------------------------#
} # Função para levantamento de informações da distribuição

function _verifParticao_() {
    # Variáveis internas de controle #-----------------------------------------------------------------------------------#
    local infoParticao="$1" # Argumento passado na chamada da função _verifParticao_ $1
    local pontoMontagem=$(df -h | grep $infoParticao | awk {'print $6'}) # Obtem o ponto de montagem da partição passada como parametro
    local particaoTotal=$(df -h "$infoParticao" | awk 'NR==2 {print $2}') # Obtem a quantidade total de espaço da partição
    local particaoLivre=$(df -h "$infoParticao" | awk 'NR==2 {print $4}') # Obtem a quantidade livre de espaço da partição
    local particaoLivrePorc=$(df -h "$infoParticao" | awk 'NR==2 {print $5}') # Obtem a disponibilidade de espaço em % na partição
    local particaoPorcForm=$(df -h "$infoParticao" | awk 'NR==2 {print $5}' | tr -d "%") # Obtem a disponibilidade de espaço em % na partição formata para melhor visualização
    local criticidadePorc="${CORES[none]}" # Cor da saída stout

    # Validação de espaço disponível #----------------------------------------------------------------------------------#
    if (( $(echo "$particaoPorcForm < 70" | bc -l) )); then # Caso a disponibilidade de espaço na partição em % seja menor que 70%
        criticidadePorc="${CORES[verde]}"  # Verde
    elif (( $(echo "$particaoPorcForm >= 70 && $particaoPorcForm <= 85" | bc -l) )); then # Caso a disponibilidade de espaço na partição em % enteja entre 70% e 85%
        criticidadePorc="${CORES[amarelo]}"  # Amarelo
    else # Caso a disponibilidade de espaço na partição em % seja maior que 85%
        criticidadePorc="${CORES[vermelho]}"  # Vermelho
    fi

    # Envio dos parametros para variável global #----------------------------------------------------------------------------------#
    PARTICOES_INFO+="\nInformações partição ${CORES[amarelo]}$pontoMontagem${CORES[none]}:\n" 
    PARTICOES_INFO+=" ⤷ total: $particaoTotal\n" 
    PARTICOES_INFO+=" ⤷ livre: $particaoLivre\n"
    PARTICOES_INFO+=" ⤷ utilizado: $criticidadePorc$particaoLivrePorc${CORES[none]}\n"
} # Função para levantamento de informações das partições

function _verifServicos_() {   
    #----------------------------------------------------------------------------------------------------------------------------#
    for servico in "${SERVICOS[@]}"; do # Listagem do array SERVICOS
        ((SERVICOS_QNT++)) 
        servicoNome=$servico
        if [[ $(command -v systemctl) ]] ; then # Se o systemctl estiver disponível (sistema que usa systemd)
            servicoStatus=$(systemctl is-active "$servicoNome" &>/dev/null)
            if [[ $? = 0 ]] ; then
                servicoStatus="${CORES[verde]}Ativo${CORES[none]}"
            else
                servicoStatus="${CORES[vermelho]}Inativo${CORES[none]}"
            fi
        elif [[ -e "/etc/init.d/$servicoNome" ]] ; then # Se o init.d estiver presente (sistema que não usa systemd)
            servicoStatus=$(/etc/init.d/"$servicoNome" status | grep -q "active")
            if [[ $? = 0 ]] ; then
                servicoStatus="${CORES[verde]}Ativo${CORES[none]}"
            else
                servicoStatus="${CORES[vermelho]}Inativo${CORES[none]}"
            fi
        else
            servicoStatus="${CORES[vermelho]}Desconhecido${CORES[none]}"
        fi
        SERVICOS_INFO+=" ⤷ $servicoNome: $servicoStatus\n"
    done
    #----------------------------------------------------------------------------------------------------------------------------#
} # Função para verificação de status de serviços em execução no servidor

#------------------------------------------------------------------------------------------------------------------------#
case $1 in 
    "--version" | "--versao" | "version" | "versao" | "-v") # Opção para versionamento do script
        _versaoScript_
    ;;
    "--help" | "-help" | "help" |"-h") # Opção para ajuda
        _ajudaScript_
    ;;
    *) # Opção principal, quando não passado parametros
        _principal_
    ;;
esac