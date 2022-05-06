#!/bin/bash


# local_user_manager.sh
# Versao: 3.0
# Analista: Sergio Silva
# E-mail: 
# Tel: 
#  Technology



#
##	COMENTARIOS

# Esse script efetua a leitura de um arquivo CSV, que contem os nomes dos usuários a serem criados em uma servidor Linux, faz uma copia de seguranca do mesmo e executa um loop de comandos para cada linha do arquivo removendo sempre a primeira linha antes de passar para a proxima;
# Tambem cria o usuário opservices no Sistema, caso o mesmo já exista ele sera desabilitado;
# O arquivo deve ter as seguintes informacoes: NOME e SOBRENOME separados por espaco, um por linha;
# Nao e necessario colocar por ponto e virgura(;) ao final da linha;
# O script ira efetuar a leitura do arquivo informado na variavel LISTA no diretório informado na variavel DIR;
# O nome do arquivo de entrada deve ser diferente de lista.csv
# Anote a senhas dos LOGINS criados e passe para os respectivos usuarios;
# Sera necessario efetuar a troca da senha no primeiro acesso;



#
##	DECLARANDO VARIAVEIS

DIR="/root/"					# Diretorio onde será informado a localizacao da lista de USUARIOs
LISTA="usuarios.csv"	# Arquivo onde se encontram os USUARIOs a serem criados
LOGIN=NULL						# Inicial primeiro NOME+SOBRENOME
SENHA=NULL						# Senha inicial dos usuarios
RESP=NULL


#
##	FUNCOES
LOGO()
{
clear
echo ""

echo -e "
    ______              __                              _____         __        __   _                    
   / ____/_____ ____   / /_ _____ ____ _ _____ ___     / ___/ ____   / /__  __ / /_ (_)____   ____   _____
  / __/  / ___// __ \ / __// ___// __ | // ___// _ \    \__ \ / __ \ / // / / // __// // __ \ / __ \ / ___/
 / /___ / /__ / /_/ // /_ / /   / /_/ // /__ /  __/   ___/ // /_/ // // /_/ // /_ / // /_/ // / / /(__  ) 
/_____/ \___/ \____/ \__//_/    \__,_/ \___/ \___/   /____/ \____//_/ \__,_/ \__//_/ \____//_/ /_//____/  

"
}


#
##	INICIO

# Menu de interacao
until [ "$RESP" == "0" -o "$RESP" == "1" -o "$RESP" == "2" -o "$RESP" == "3" -o "$RESP" == "4" ]
    do
	LOGO
	echo -e "Entre com a opcao desejada"
	echo ""
	echo -e "1 - Criar Usuarios (Baseado em uma lista)"
	echo -e "2 - Deletar Usuarios' (Delete apenas se souber o que esta fazendo)"
	echo ""
	echo -e "0 - Sair sem executar"
	echo ""
	echo "RESPOSTA"
	read RESP 
    done

# Arquivo txt com logins e senhas criados durante execucao desse script
echo "LOGIN		SENHA" > /root/logins.txt


# Efetuando a copia da lista para lista.csv.bak 
cp $DIR/$LISTA $DIR/lista.csv.bak


# Apagando linhas em branco e gerando o arquivo lista.csv
sed '/^$/d' $DIR/lista.csv.bak > $DIR/lista.csv


# Alimentando o contador do loop com a 	qtd total de linhas
CONTADOR=$(wc -l $DIR/lista.csv |cut -c1)


# Decisao conforme RESP do item MENU
case $RESP in 
	#
	# Saindo sem executar
	0)
	LOGO
	echo ""
	echo -e "Saindo sem executar"
	exit 0
	;;
	
	#
	# Cria usuarios baseado em uma lista
	1)
	LOGO
	# Le a primeira linha executa o comando depois atualiza o arquivo lista.csv apagando sempre a primeira linha do arquivo
	for i in $(seq $CONTADOR)
	    do
		NAME=$(head -n1 $DIR/lista.csv)					# NOME SOBRENOME
		FNAME=$(echo $NAME |cut -d" " -f1 | cut -c1)			# Inicial Primeiro Nome
		LNAME=$(echo $NAME |cut -d" " -f2)				# SOBRENOME
		LOGIN=$(echo ${FNAME}${LNAME} |tr '[:upper:]' '[:lower:]')	# LOGIN
		SENHA=$(openssl rand -base64 5)					# Senha randomica
	
		VERIFICALOGIN=$(grep $LOGIN /etc/passwd |cut -d":" -f1)		# Verifica se LOGIN ja existe no Sistema

		if [ "$VERIFICALOGIN" != "$LOGIN" ]
		    then
		    	# Cria usuario com LOGIN, SENHA, COMENTARIO e forca alteracao de SENHA no primeiro LOGIN
		    	useradd -c "$NAME" -G sudo -p $SENHA $LOGIN
		    	echo "$LOGIN:$SENHA" > /root/Ltemp 
					chpasswd < /root/Ltemp
		    	passwd -e $LOGIN
		
		   	# Adiciona os LOGINS e SENHAS ao arquivo /root/logins.txt
		   	echo "$LOGIN		$SENHA" >> /root/logins.txt 
	    	    else
			echo "$LOGIN ja existe no S.O." >> /root/logins.txt 
		fi
	
		# Apaga a primeira linha do arquivo lista.csv
		sed -i 1d $DIR/lista.csv
	    done
	# Mostra usuarios criados na tela
	echo ""
	cat /root/logins.txt
	echo ""
	;;


	2)
	# Lista usuarios do Sistema
	cat /etc/passwd |cut -d":" -f1 > /tmp/usuarios_sistema.tmp
	echo -e "Esses sao todos o Usuarios em uso no Sistema Operacional"
	echo -e "Certifique-se de NAO excluir um Usuario essencial para o Sistema Operacional"
	echo -e "Digite o numero do Usuario que deseja excluir:"

	# Excluindo usuarios do Sistema Operacional do menu
	echo ""
	sed -i '/root/d' /tmp/usuarios_sistema.tmp
	sed -i '/daemon/d' /tmp/usuarios_sistema.tmp
	sed -i '/naemon/d' /tmp/usuarios_sistema.tmp
	sed -i '/vcsa/d' /tmp/usuarios_sistema.tmp
	sed -i '/mysql/d' /tmp/usuarios_sistema.tmp
	sed -i '/apache/d' /tmp/usuarios_sistema.tmp
	sed -i '/bin/d' /tmp/usuarios_sistema.tmp
	sed -i '/memcached/d' /tmp/usuarios_sistema.tmp
	sed -i '/postfix/d' /tmp/usuarios_sistema.tmp
	sed -i '/sync/d' /tmp/usuarios_sistema.tmp
	sed -i '/shutdown/d' /tmp/usuarios_sistema.tmp
	sed -i '/halt/d' /tmp/usuarios_sistema.tmp
	sed -i '/mail/d' /tmp/usuarios_sistema.tmp
	sed -i '/ntp/d' /tmp/usuarios_sistema.tmp
	sed -i '/uucp/d' /tmp/usuarios_sistema.tmp
	sed -i '/adm/d' /tmp/usuarios_sistema.tmp
	sed -i '/lp/d' /tmp/usuarios_sistema.tmp
	sed -i '/operator/d' /tmp/usuarios_sistema.tmp
	sed -i '/gopher/d' /tmp/usuarios_sistema.tmp
	sed -i '/games/d' /tmp/usuarios_sistema.tmp
	sed -i '/ftp/d' /tmp/usuarios_sistema.tmp
	sed -i '/nobody/d' /tmp/usuarios_sistema.tmp
	sed -i '/gearmand/d' /tmp/usuarios_sistema.tmp
	sed -i '/grafana/d' /tmp/usuarios_sistema.tmp
	sed -i '/saslauth/d' /tmp/usuarios_sistema.tmp
	sed -i '/sshd/d' /tmp/usuarios_sistema.tmp
	cat -b /tmp/usuarios_sistema.tmp
	echo ""
	echo "0 - SAIR SEM EXECUTAR"
	echo ""

	read RESPDEL							# Numero da linha do usuario que sera excluido
	
	case $RESPDEL in
		0)
		echo -e "SAINDO SEM EXECUTAR"
		echo ""
		exit 0
		;;
	esac

	USERDEL=$(sed -n "${RESPDEL}p" /tmp/usuarios_sistema.tmp)	# Usuario que sera excluido
	
	# Verificacao referente a exclusao do usuario
	CONTINUA=NULL
	until [ "$CONTINUA" == "1" -o "$CONTINUA" == "2" ]
	do
	    LOGO
	    echo ""
	    echo -e "O Usuario "$USERDEL" sera removido do Sistema e seu arquivos deletados"
	    echo -e "Deseja continuar?"
	    echo ""
	    echo -e "1 - SIM"
	    echo -e "0 - NAO"
	    echo ""
	    read CONTINUA
	done
	case $CONTINUA in
		1)
		userdel -r $USERDEL	# Excluindo Usuario
		echo -e ""
		echo -e "USUARIO excluido com sucesso"
		;;
		0)
		echo ""
		echo -e "SAINDO SEM EXECUTAR"
		exit 0
		;;
	esac
	;;
esac


# Apagando arquivos gerados pelo script
rm -r $DIR/lista.csv
rm -r $DIR/lista.csv.bak
rm -f /tmp/usuarios_sistema.tmp
rm -f /root/logins.txt
rm -f /root/Ltemp

#
##	FIM
echo ""
echo "FIM"
