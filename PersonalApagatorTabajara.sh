#!/bin/bash

# Versão 1.0
# Data: 23/04/2021
# Autor Sergio Silva
# E-mail: sergiohnt@gmail.com
# Esse script apaga arquivos com base no diretório /tmp por padrão
# A variável DIR2 muda o diretório que será efetuada a limpeza
# Por padrão arquivos não acessados a mais de 30 dias serão apagados
# É possivel mudar o padrão de "30" dias mudando a váriavel DIAS
# Colocando "0" na variável DIAS todos os arquivos encontrados serão apados
# A variável EXT deve ser informada sem o ponto EX: gz, tar, zip, rar, etc...
# Para rodar o arquivo de permissão de execução: chmod 755 PersonalApagatorTabajara.sh

# O Autor não se responsabiliza pela perda/exclusão de dados

# TESTE O SCRIPT ANTES DE EXECUTAR EM PRODUÇÂO


# Vaiáveis
DIR1=/tmp
DIR2=NULL
EXT=NULL
DIAS=NULL
RESP="n"

# Início
echo -e "Digite o caminho completo do diretório que deseja limpar:"
echo -e "(Padao:/tmp)"
read DIR2
echo ""

echo -e "Digite a extensão do arquivo que deseja apagar:"
read EXT
echo ""

# Verifica se a extensão foi informada
if [ -z "$EXT" ]
    then
        echo -e "A entensão deve ser diferente de NULL"
        echo ""
        exit 0
fi

echo -e "Apaga arquivos que não são acessados nos últimos X dias:"
echo -e "(Padrão: 30 dias)"
read DIAS
echo ""

# Adiciona valor a variável DIAS
if [ -z "$DIAS" ]
    then
        DIAS=30
fi

# Executa a limpeza
if [ -z "$DIR2" ]
    then
        # Apaga arquivos no diretório /tmp com a extensão escolhida
        echo -e "Efetuando busca..."
        echo -e ""
        find $DIR1 -type f -atime "$DIAS" -name "*.$EXT"
        echo -e ""
        echo -e "Os arquivos acima serão excluídos. Confirma?"
        echo -e "(Padrão: n)"
        echo -e "s/n"
        read RESP
        echo ""
        if [ "$RESP" != "s" ]
            then
                echo -e "Operação cancelada"
                echo ""
                exit 0
            else
                echo -e "Os arquivos serão apagados em 10s"
                echo -e "Para abortar pressione Ctrl+C"
                echo ""
                sleep 10s
                find $DIR1 -type f -atime "$DIAS" -name "*.$EXT" -delete
        fi
    else
        # Apagar arquivos no diretório $DIR2 com a extensão escolhida
        echo -e "Efetuando busca..."
        echo -e ""
        find $DIR2 -type f -atime "$DIAS" -name "*.$EXT"
        echo -e ""
        echo -e "Os arquivos acima serão excluídos. Confirma?"
        echo -e "(Padrão: n)"
        echo -e "s/n"
        read RESP
        echo ""
        if [ "$RESP" != "s" ]
            then
                echo -e "Operação cancelada"
                echo ""
                exit 0
            else
                echo -e "Os arquivos serão apagados em 10s"
                echo -e "Para abortar pressione Ctrl+C"
                sleep 10s
                find $DIR2 -type f -atime "$DIAS" -name "*.$EXT" -delete
        fi
fi
echo ""
echo -e "Arquivos apagados"
echo ""

# FIM
