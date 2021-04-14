#!/bin/bash 


# insta.sh
# Versao: 1.0
# Analista N2: Sergio Silva
# E-mail: sergio.silva@proativetec.com.br
# Tel: 11 4130-8818
# Proative Technology



#
##	COMENTARIOS

# Esse script efetua a leitura de um arquivo CSV, efetua uma copia de seguranca do mesmo e executa um loop de comandos para cada linha do arquivoremovendo sempre a primeira linha do arquivo antes de passar para a proxima;
# O arquivo deve conter um IP de host por linha;
# Nao e necessario efetuar a separacao por ponto e virgura(;);
# O script ira efetuar a leitura do arquivo informado na variavel LISTA no diretório informado na variavel DIR;
# O nome do arquivo de entrada deve ser diferente de lista.csv



#
##	DECLARANDO VARIAVEIS

DIR="VAZIO"		# Diretorio onde será informado a localizacao da lista de ECs
LISTA="VAZIO"		# Arquivo onde se encontram os IPs dos ECs
SENHA="VAZIO"		# Senha para instalacao
INSTALADOR="VAZIO"	# Pacote instalador que sera utilizado



#
##	INICIO
clear
echo ""


# Alimentando a variavel DIR
#echo -e "Entre com o diretorio onde se encontra o arquivo:"
#read DIR
#echo ""


# Alimentando a variavel SENHA
echo -e "Entre com a senha para efetuar a instalacao:"
read SENHA
echo ""


# Alimentado a variavel INSTALADOR
echo -e "Entre com o instalador:"
read INSTALADOR
echo ""


# Efetuando a copia da lista para lista.csv.bak 
cp $DIR/$LISTA $DIR/lista.csv.bak


# Apagando linhas em branco e gerando o arquivo lista.csv
sed '/^$/d' $DIR/lista.csv.bak > $DIR/lista.csv


# Alimentando o contador do loop com a 	qtd total de linhas
C=$(wc -l $DIR/lista.csv |cut -c1)


# Le a primeira linha executa o comando depois atualiza o arquivo lista.csv apagando sempre a primeira linha do arquivo
for i in $(seq $C) 
    do
	IP=$(head -n1 $DIR/lista.csv)
	
        # Coloque o comando de instalacao aqui utilizando a variavel IP

	sed -i 1d $DIR/lista.csv
    done


# Apagando arquivos gerados pelo script
rm -r $DIR/lista.csv
rm -r $DIR/lista.csv.bak


#
##	FIM
echo "FIM"




















