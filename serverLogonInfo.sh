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
# Adicionar última atualização do servidor (update/upgrade)
#------------------------------------------------------------------------------------------------------------------------#
##########################################################################################################################
#------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------ ARRAYS ----------------------------------------------------------#
# Arrays dinâmicos (Devem ser alterados/adicionados para se adequar a infraestrutura da rede) #--------------------------#
declare -A PARTICOES=(
        [raiz]="/"
        [boot]="/boot"
) # Partições para verificação de, adicione mais no formato [descricao]="mountpoint"

declare -a SERVICOS=(
    "zabbix-server" "ssh" "apache2" "mysql"
) # Serviços para validação no servidor, adicione mais no formato "serviçoA" "serviçoB" (deve se utilizar o nome exato do serviço)

# Arrays estáticos #-----------------------------------------------------------------------------------------------------#
declare -A CORES=( 
                [none]="\033[m"
                [vermelho]="\033[1;31m"
                [verde]="\033[1;32m"
                [amarelo]="\033[1;33m"
                [azul]="\033[1;34m"
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
VERSAO=v1.3 # Versão do script
HOST_NOME=$(hostname) # Armazena o hostname do host
ENDERECO_PUBLICO=$(curl -s ifconfig.me 2>/dev/null) # Endereço público do host
ENDERECO_LOCAL=$(hostname -I | awk '{print $1}') # Endereço local do host
SCRIPT=${0##*/} # Retorna o nome do script
SCRIPT_DIR=/usr/local/bin # Local aonde o script é armazenado
FUNC_SERVIDOR="" # Descrição da função do servidor
IMPAC_SERVIDOR="" # Impacto do servidor na rede
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
    #--------------------------------------------------------------------------------------------------------------------#
    # Verificações de dependências #-------------------------------------------------------------------------------------#
    _verifInstalacao_ 

    # Levantamento de informações do S.O #-------------------------------------------------------------------------------#
    for particao in "${!PARTICOES[@]}" ; do # Percorre o array PARTICOES
        _verifParticao_ $(df ${PARTICOES[$particao]} | grep -v Filesystem | awk '{print $1}')
    done 

    _verifDistro_ 
    _verifServicos_

    # Saída principal do script #----------------------------------------------------------------------------------------#
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
    echo -e "Função: $FUNC_SERVIDOR"
    echo -e "Impacto infraestrutura: $IMPAC_SERVIDOR"
    echo -e "Endereço local: $ENDERECO_LOCAL"
    echo -e "Endereço público: $ENDERECO_PUBLICO"
    echo -e "$PARTICOES_INFO"
    echo -e "Estado serviços (${CORES[amarelo]}$SERVICOS_QNT${CORES[none]}): \n$SERVICOS_INFO"
    _divisor_ "-"
    #--------------------------------------------------------------------------------------------------------------------#
} # Funçao para exibição das informações

function _versaoScript_() {
    #--------------------------------------------------------------------------------------------------------------------#
    echo -e "Script desenvolvido para exibição de informações importantes do host após o início de sessão. (GNU Linux) - ${CORES[amarelo]}$SCRIPT $VERSAO${CORES[none]}"               
    echo "Copyright (C) 2024 Free Software Foundation."                                                              
    echo "Este software é livre, você é livre para alterá-lo e redistribuí-lo."                                      
    echo -e "Escrito e desenvolvido por ${CORES[amarelo]}Matheus Seman${CORES[none]}."                                              
    #--------------------------------------------------------------------------------------------------------------------#
} # Funçao para informações sobre a versão do script

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
    #--------------------------------------------------------------------------------------------------------------------#
    echo -e "${CORES[amarelo]}#${CORES[branco]}----------------------------------------------------------------------${CORES[amarelo]}#${CORES[none]}"
    #--------------------------------------------------------------------------------------------------------------------#
} # Função para exibição do separador de texto

function _verifInstalacao_() {
    #--------------------------------------------------------------------------------------------------------------------#
    # Validação de dependências #----------------------------------------------------------------------------------------#
    local instalacaoValidacao="false" # Variável de controle
    for dependencia in "${!DEPENDENCIAS[@]}" ; do # Percorre o array com as dependências do script
        if [[ ! -e "${DEPENDENCIAS[$dependencia]}" ]] ; then # Caso a dependencia não esteja instalada
            if [[ $instalacaoValidacao = "false" ]] ; then
                while true ; do
                    read -p "Para execução do script, os pacotes bc e curl devem ser adicionados. Deseja prosseguir? [S/N]: " instalacaoForm
                    case $instalacaoForm in 
                        "não" | "nao" | "Não" | "Nao" | "NÃO" | "NAO" | "n" | "N") 
                            echo -e "${CORES[branco]}[ ${CORES[amarelo]}!${CORES[none]} ${CORES[branco]}]${CORES[none]} ~ Cancelando instalação..." ; sleep 1 ; exit 0                        
                        ;;
                        "sim" | "Sim" | "SIM" | "s" | "S") 
                            instalacaoValidacao="true"
                            break
                        ;;
                        *)
                            echo -e "[ ${CORES[vermelho]}✖${CORES[none]} ] ~ Opção inválida..." ; sleep 1
                        ;;
                    esac
                done
            fi     

            #------------------------------------------------------------------------------------------------------------#
            # Instalação da dependência #--------------------------------------------------------------------------------#
            if [[ $instalacaoValidacao = "true" ]] ; then
                if [ "$(id -u)" != "0" ] ; then # Caso o usuário não seja administrador
                    echo -e "[ ${CORES[vermelho]}✖${CORES[none]} ] ~ Operação permitida apenas para administradores, abortando..." ; exit 0
                else
                    echo -e "\n${CORES[branco]}[ ${CORES[amarelo]}!${CORES[none]} ${CORES[branco]}]${CORES[none]} ~ Baixando/instalando pacote $dependencia..." ; sleep 1

                    # Em distribuições de família Debian #---------------------------------------------------------------#
                    if [[ -e "/usr/bin/apt" ]] ; then
                        apt-get install $dependencia -y ; echo # Faz a instalação das dependencias
                        if [[ $? = 1 ]] ; then
                            echo -e "[ ${CORES[vermelho]}✖${CORES[none]} ] ~ Falha na instalação dos pacotes, abortando..." ; sleep 1 ; exit 0                
                        fi

                    # Em distribuições de família RedHat #---------------------------------------------------------------#
                    elif [[ -e "/usr/bin/yum" ]] ; then
                        yum install $dependencia -y ; echo # Faz a instalação das dependencias
                        if [[ $? = 1 ]] ; then
                            echo -e "[ ${CORES[vermelho]}✖${CORES[none]} ] ~ Falha na instalação dos pacotes, abortando..." ; sleep 1 ; exit 0                
                        fi
                    fi
                fi
            fi
        fi
    done

    # Ações para primeira execução do script #---------------------------------------------------------------------------#
    if [[ $instalacaoValidacao = "true" ]] ; then  
        # Função do servidor #-------------------------------------------------------------------------------------------#
        _divisor_ "-" ; echo

        while true ; do
            read -p "Descreva de forma sucinta a função do servidor: " funcServidor
            if [[ ! -z $funcServidor ]] ; then
                sed -i "s/^FUNC_SERVIDOR=.*/FUNC_SERVIDOR=\"$funcServidor\"/" "$0" ; break
                break 
            else
                echo -e "[ ${CORES[vermelho]}✖${CORES[none]} ] ~ Valor inválido! Informe a função do servidor.\n" ; sleep 1                
            fi
        done

        # Impacto do servidor #------------------------------------------------------------------------------------------#
        while true; do
            local regexpImpacto='^[AMB]' # Expressão regular para verificar a primeira letra (A, M, B)
            read -p "Qual o impacto do mesmo na rede ao qual está instalado? [Alto, Médio, Baixo]: " impacServidor 

            local impactServidorForm=$(echo "${impacServidor:0:1}" | tr '[:lower:]' '[:upper:]') # Obtém o primeiro caractere da variável e formata para maiúsculo
            if [[ $impactServidorForm =~ $regexpImpacto ]]; then # Verifica se o primeiro caractere corresponde à expressão regular
                # Cria um arquivo temporário para a atualização
                case $impactServidorForm in 
                    "A")
                        sed -i "s/^IMPAC_SERVIDOR=.*/IMPAC_SERVIDOR=\"\${CORES[vermelho]}Alto\${CORES[none]}\"/" "$0" ; break
                    ;;
                    "M")
                        sed -i "s/^IMPAC_SERVIDOR=.*/IMPAC_SERVIDOR=\"\${CORES[amarelo]}Médio\${CORES[none]}\"/" "$0" ; break
                    ;;
                    "B")
                        sed -i "s/^IMPAC_SERVIDOR=.*/IMPAC_SERVIDOR=\"\${CORES[azul]}Baixo\${CORES[none]}\"/" "$0" ; break
                    ;;
                esac
            else
                echo -e "[ ${CORES[vermelho]}✖${CORES[none]} ] ~ Valor inválido, preencha com Alto, Médio ou Baixo." ; sleep 1             
            fi
        done

        # Finalização da instalação/configuração #-----------------------------------------------------------------------#
        echo ; _divisor_ "-"

        echo -e "\n[ ${CORES[verde]}✓${CORES[none]} ] ~ Instalação finalizada!"
        echo -e "[ ${CORES[amarelo]}!${CORES[none]} ] ~ Adicione manualmente a execução do script ao arquivo .bashrc dos usuários."
        echo -e "  Exemplo: "
        echo -e "   [ Conteúdo arquivo /home/usuario/.bashrc ]\n"
        echo -e "       [ ... ] # Conteúdo já existente no arquivo\n"
        echo -e "       # Script para amostra de informações no login"
        echo -e "       /usr/loca/bin/serverLogonInfo.sh\n"
        exit 0
    fi
    #--------------------------------------------------------------------------------------------------------------------#
} # Função para instalação personalizada do script

function _verifDistro_() {
    #--------------------------------------------------------------------------------------------------------------------#
    # Validação de distribuição #----------------------------------------------------------------------------------------#
    if [ -f /etc/os-release ] ; then # Se houver /etc/os-release
        source /etc/os-release # Usando /etc/os-release para obter informações
        DISTRO_INFO+="$NAME"
        DISTRO_INFO+=" $VERSION"

    # Família Redhat #---------------------------------------------------------------------------------------------------#
    elif [ -f /etc/redhat-release ] ; then # Se houver /etc/redhat-release (para distribuições Red Hat)
        DISTRO_INFO+=$(cat /etc/redhat-release)
    
    # Família Debian #---------------------------------------------------------------------------------------------------#
    elif [ -f /etc/debian_version ] ; then # Se houver /etc/debian_version (para distribuições Debian)
        DISTRO_INFO+="Debian"
        DISTRO_INFO+=$(cat /etc/debian_version)

    # Desconhecido #-----------------------------------------------------------------------------------------------------#
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
    #--------------------------------------------------------------------------------------------------------------------#
} # Função para levantamento de informações da distribuição

function _verifParticao_() {
    # Variáveis internas de controle #-----------------------------------------------------------------------------------#
    local particao="$1" # Argumento passado na chamada da função _verifParticao_ $1
    local pontoMontagem=$(df -h | grep $particao | awk {'print $6'}) # Obtem o ponto de montagem da partição passada como parametro
    local particaoTotal=$(df -h "$particao" | awk 'NR==2 {print $2}') # Obtem a quantidade total de espaço da partição
    local particaoLivre=$(df -h "$particao" | awk 'NR==2 {print $4}') # Obtem a quantidade livre de espaço da partição
    local particaoLivrePorc=$(df -h "$particao" | awk 'NR==2 {print $5}') # Obtem a disponibilidade de espaço em % na partição
    local particaoPorcForm=$(df -h "$particao" | awk 'NR==2 {print $5}' | tr -d "%") # Obtem a disponibilidade de espaço em % na partição formata para melhor visualização
    local criticidadePorc="${CORES[none]}" # Cor da saída stout

    # Validação de espaço disponível #----------------------------------------------------------------------------------#
    if (( $(echo "$particaoPorcForm < 70" | bc -l) )); then # Caso a disponibilidade de espaço na partição em % seja menor que 70%
        criticidadePorc="${CORES[verde]}"  # Verde
    elif (( $(echo "$particaoPorcForm >= 70 && $particaoPorcForm <= 85" | bc -l) )); then # Caso a disponibilidade de espaço na partição em % enteja entre 70% e 85%
        criticidadePorc="${CORES[amarelo]}"  # Amarelo
    else # Caso a disponibilidade de espaço na partição em % seja maior que 85%
        criticidadePorc="${CORES[vermelho]}"  # Vermelho
    fi

    # Envio dos parametros para variável global #-----------------------------------------------------------------------#
    PARTICOES_INFO+="\nInformações partição ${CORES[amarelo]}$pontoMontagem${CORES[none]}:\n" 
    PARTICOES_INFO+=" ⤷ total: $particaoTotal\n" 
    PARTICOES_INFO+=" ⤷ livre: $particaoLivre\n"
    PARTICOES_INFO+=" ⤷ utilizado: $criticidadePorc$particaoLivrePorc${CORES[none]}\n"
} # Função para levantamento de informações das partições

function _verifServicos_() {   
    #-------------------------------------------------------------------------------------------------------------------#
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
    #--------------------------------------------------------------------------------------------------------------------#
} # Função para verificação de status de serviços em execução no servidor

#------------------------------------------------------------------------------------------------------------------------#
case $1 in 
    "--version" | "--versao" | "version" | "versao" | "-v") # Opção para versionamento do script
        _versaoScript_
    ;;
    "--help" | "-help" | "help" | "-h") # Opção para ajuda
        _ajudaScript_
    ;;
    *) # Opção principal, quando não passado parametros
        _principal_
    ;;
esac