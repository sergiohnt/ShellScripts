#!/bin/bash


# proative_user_manager.sh
# Versao: 2.0
# Analista N2: Sergio Silva
# E-mail: sergio.silva@proativetec.com.br
# Tel: 11 4130-8818
# Proative Technology



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

DIR="/root/opmonusers"		# Diretorio onde será informado a localizacao da lista de USUARIOs
LISTA="opmonusers.csv"	# Arquivo onde se encontram os USUARIOs a serem criados
LOGIN=NULL		# Inicial primeiro NOME+SOBRENOME
SENHA=NULL		# Senha inicial dos usuarios
RESP=NULL


#
##	FUNCOES
PROATIVETEC()
{
clear
echo ""

echo -e "
 ██████╗ ██████╗  ██████╗  █████╗ ████████╗██╗██╗   ██╗███████╗    ████████╗███████╗ ██████╗
 ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██║██║   ██║██╔════╝    ╚══██╔══╝██╔════╝██╔════╝
 ██████╔╝██████╔╝██║   ██║███████║   ██║   ██║██║   ██║█████╗         ██║   █████╗  ██║     
 ██╔═══╝ ██╔══██╗██║   ██║██╔══██║   ██║   ██║╚██╗ ██╔╝██╔══╝         ██║   ██╔══╝  ██║     
 ██║     ██║  ██║╚██████╔╝██║  ██║   ██║   ██║ ╚████╔╝ ███████╗       ██║   ███████╗╚██████╗
 ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝  ╚══════╝       ╚═╝   ╚══════╝ ╚═════╝
 "
}


#
##	INICIO

# Menu de interacao
until [ "$RESP" == "0" -o "$RESP" == "1" -o "$RESP" == "2" -o "$RESP" == "3" -o "$RESP" == "4" ]
    do
	PROATIVETEC
	echo -e "Entre com a opcao desejada"
	echo ""
	echo -e "1 - Criar Usuarios (Baseado em uma lista)"
	echo -e "2 - Criar/Bloquear Usuario 'opservices'"
	echo -e "3 - Deletar Usuarios' (Delete apenas se souber o que esta fazendo)"
	echo -e "4 - Desbloquear temporariamente Usuario 'opservices'"
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


# Adiciona o grupo "sudo" ao sistema
groupadd -f sudo


# Da permissão de escrita para o usuario "root" no arquivo "/etc/sudoers"
chmod 640 /etc/sudoers


# Faz backup do "/etc/sudoers" e insere o grupo "sudo" no arquivo "/etc/sudoers"
cp /etc/sudoers /etc/sudoers.bak
sed -i '97s/wheel/sudo/' /etc/sudoers
sed -i '98s/# %wheel/%sudo/' /etc/sudoers


# Decisao conforme RESP do item MENU
case $RESP in 
	#
	# Saindo sem executar
	0)
	PROATIVETEC
	echo ""
	echo -e "Sindo sem executar"
	exit 0
	;;
	
	#
	# Cria usuarios baseado em uma lista
	1)
	PROATIVETEC
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
		    	echo -e "$SENHA" |passwd --stdin $LOGIN
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

	#
	# Cria usuario opservices
	2)
	PROATIVETEC
	VERIFICAOPSERVICES=$(grep opservices /etc/passwd |cut -d":" -f1)	# Verifica se o LOGIN opservices ja existe no Sistema
	if [ "$VERIFICAOPSERVICES" != "opservices" ]
	    then
	    	# Cria usuario com LOGIN, SENHA, COMENTARIO e forca alteracao de SENHA no primeiro LOGIN
		useradd -c "OPSERVICES PROATIVE" -G sudo -p PASSWD opservices
		echo "opservices		USUARIO BLOQUEADO" >> /root/logins.txt
		passwd -l opservices						# Efetua bloqueio do Usuario 'opservices
    	    else
		echo "opservices ja existe no S.O." >> /root/logins.txt 
		echo "A conta foi BLOQUEADA" >> /root/logins.txt 
		passwd -l opservices						# Efetua bloqueio do Usuario 'opservices'
	fi
	
	# Mostra usuarios criados na tela
	echo ""
	cat /root/logins.txt
	echo ""
	;;
	
	#
	# Deletar Usuarios
	3)
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
	sed -i '/opuser/d' /tmp/usuarios_sistema.tmp
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
	    PROATIVETEC
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
	
	#
	# Desbloqueio USUARIO 'opservices' temporariamente
	4)
	PROATIVETEC
	SENHA=$(openssl rand -base64 5)				# Senha randomica
	BLQ=NULL						# Variavel que armazena data de bloqueio Usuario 'opservices'
	echo -e "Digite a data em que a conta deve ser bloqueada novamente:"
	echo -e "(YYYY-MM-DD)"
	echo ""
	read BLQ
	passwd -u opservices
	echo -e "$SENHA" |passwd --stdin opservices 		# PASSWD
	chage -E $BLQ opservices				# Configura a data para o futuro bloqueio baseado em na variavel BLQ
	echo ""
	echo -e "CONTA: opservices"
	echo -e "SENHA: $SENHA"
	echo ""
	echo -e "DESBLOQUEADA"
	echo -e "O BLOQUEIO ocorrea novamente no dia $BLQ"
	echo ""
	;;

esac

# Retorna permissao '/etc/sudoers' ao normal
chmod 440 /etc/sudoers

# Apagando arquivos gerados pelo script
rm -r $DIR/lista.csv
rm -r $DIR/lista.csv.bak
rm -f /tmp/usuarios_sistema.tmp
rm -f /root/logins.txt

#
##	FIM
echo ""
echo "FIM"
