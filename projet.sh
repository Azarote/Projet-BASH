#!/bin/bash
#
#=============================================
#
# Script projet BASH 2019 M1101 - Systèmes
# MUNOZ Matteo - POLLET Lucas - CORIZZI Ianis
# Groupe X 
#
#=============================================


sortieFile="sortie.txt"
resultat="resultat.txt"
listedossier1="listedossier1.txt"
listedossier2="listedossier2.txt"
listedossiermd51="listedossiermd51.txt"
listedossiermd52="listedossiermd52.txt"
tempsousdossier="tempsousdossier.txt"
tempsousdossier2="tempsousdossier2.txt"

# Couleurs (gras)
ROUGE="$(tput bold ; tput setaf 1)"
VERT="$(tput bold ; tput setaf 2)"
JAUNE="$(tput bold ; tput setaf 3)"
BLEU="$(tput bold ; tput setaf 4)"
CYAN="$(tput bold ; tput setaf 6)"
RESET="$(tput sgr0)"

#Fonction pour supprimer un fichier si il existe
delFile(){
	if [ -f $1 ]
	then 
		rm $1
	fi
}

echo "${ROUGE}- Outil de comparaison de fichiers -${RESET}"

delFile $sortieFile
delFile $listedossier1
delFile $listedossier2
delFile $listedossiermd51
delFile $listedossiermd52
delFile $tempsousdossier
delFile $tempsousdossier2

#demande des répertoires

if [ $# -eq 0 ]
	then
		echo "Entrez le 1er répertoire"
		read dir1

	while test ! -d $dir1
		do
			echo "$dir1 n'existe pas"
			echo "Entrez le 1er répertoire"
			read dir1
		done

	echo "Entrez le 2e répertoire"
	read dir2

	while test ! -d $dir2
		do
			echo "$dir2 n'existe pas"
			echo "Entrez le 2e répertoire"
			read dir2
		done
elif [ $# -ne 2 ]
	then
	echo "Pour utiliser ce script, il faut 2 arguments (répertoires)"
	exit
else
	dir1=$1
	dir2=$2
fi

basedir1=`basename $dir1`
basedir2=`basename $dir2`

filetri=$basedir1"_"$basedir2"_tri.txt"

delFile $filetri

#début analyse
echo "Début d'analyse... Patientez"

for i in `find $dir1 -type f`
	do 
		md5sum $i >> $sortieFile #récupération de toute les empreintes du premier répertoire
		nbligne1=`expr $nbligne1 + 1`
	done
		
for j in `find $dir2 -type f`
	do 
		md5sum $j >> $sortieFile #récupération de toute les empreintes du deuxième répertoire
		nbligne2=`expr $nbligne2 + 1`
	done
		
temp1=`find $dir1 -type f -exec md5sum {} \; > tempmd5 && md5sum tempmd5 && rm tempmd5 | cut -d ' ' -f1`
temp2=`find $dir2 -type f -exec md5sum {} \; > tempmd5 && md5sum tempmd5 && rm tempmd5 | cut -d ' ' -f1`

#############################################################
# PARTIE A CONTINUER ....

find $dir1 -type d >> listedossier1.txt
find $dir2 -type d >> listedossier2.txt

#arbo1
while read line
	do
		find $line -type f -exec md5sum {} \; >> tempsousdossier.txt
		find $line -type d -exec basename {} \; | sed '1d' >> tempsousdossier2.txt
		while read line2
			do
				chemin=`echo "$line2" | cut -d ' ' -f3` 
				nom=`basename $chemin`
				md5=`echo "$line2" | cut -d ' ' -f1`
				echo "$md5" "$nom" >> tempsousdossier2.txt
			done < tempsousdossier.txt
		chemin=`echo "$line" | cut -d ' ' -f3` 
		md5=`md5sum tempsousdossier2.txt | cut -d ' ' -f1`
		echo "$md5" "$chemin" >> listedossiermd51.txt
		
		rm -f tempsousdossier.txt
		rm -f tempsousdossier2.txt
	done < listedossier1.txt

#arbo2
while read line
	do
		find $line -type f -exec md5sum {} \; >> tempsousdossier.txt
		find $line -type d -exec basename {} \; | sed '1d' >> tempsousdossier2.txt
		while read line2
			do
				chemin=`echo "$line2" | cut -d ' ' -f3` 
				nom=`basename $chemin`
				md5=`echo "$line2" | cut -d ' ' -f1`
				echo "$md5" "$nom" >> tempsousdossier2.txt
			done < tempsousdossier.txt
		chemin=`echo "$line" | cut -d ' ' -f3` 
		md5=`md5sum tempsousdossier2.txt | cut -d ' ' -f1`
		echo "$md5" "$chemin" >> listedossiermd52.txt
		
		rm -f tempsousdossier.txt
		rm -f tempsousdossier2.txt
	done < listedossier2.txt

#Comparaison arbo1 par rapport à arbo2
while read line
	do
		bool=0
		linemd5=`echo "$line" | cut -d ' ' -f1`
		linechemin=`echo "$line" | cut -d ' ' -f2`
		while read line2
			do
				line2md5=`echo "$line2" | cut -d ' ' -f1`
				if test "$linemd5" == "$line2md5"
				then
					bool=1
				fi
			done < listedossiermd52.txt
		if test $bool -eq 0 
		then
			echo "Le dossier à l'adresse : $linechemin n'apparait dans l'arborescence 2"
		fi
	done < listedossiermd51.txt

#Comparaison arbo2 par rapport à arbo1	
while read line
	do
		bool=0
		linemd5=`echo "$line" | cut -d ' ' -f1`
		linechemin=`echo "$line" | cut -d ' ' -f2`
		while read line2
			do
				line2md5=`echo "$line2" | cut -d ' ' -f1`
				if test "$linemd5" == "$line2md5"
				then
					bool=1
				fi
			done < listedossiermd51.txt
		if test $bool -eq 0 
		then
			echo "Le dossier à l'adresse : $linechemin n'apparait dans l'arborescence 1"
		fi
	done < listedossiermd52.txt

#####################################################	
	
nbfichier1=`find $dir1 -type f | wc -l`
nbfichier2=`find $dir2 -type f | wc -l`	
nbtot=$(($nbfichier1 + $nbfichier2))
filedif=`cat $sortieFile | cut -d ' ' -f1 | sort -u | wc -l`

echo "Les MD5 de chaque fichier différent:"
cat $sortieFile | cut -d ' ' -f1 | sort -u > $resultat #récupère toute les empreintes différentes
cat $resultat

#Test pour sortir les fichiers différents
k=1
m=1
while  [ $k -le $filedif ]
	do
		actualmd5=`sed -n $k'p' $resultat`
		echo "Fichier(s) portant ce md5 : $actualmd5" >> $filetri
		k=$(($k+1))
		m=1
		
		while [ $m -le $nbtot ]
			do
				md5atest=`sed -n $m'p' $sortieFile | cut -d ' ' -f1` 
				
				if [ "$actualmd5" = "$md5atest" ]
					then
					sed -n $m'p' $sortieFile | cut -d ' ' -f3 >> $filetri
				fi
				m=$(($m+1))	
			done
		echo "" >> $filetri
	done
	
#Comparaison des aborescences
if [ "$temp1" == "$temp2" ]
	then
	echo "Les deux arborescences sont ${JAUNE}identiques${RESET}."
	nbtot=$nbfichier1
else
	echo "Les deux arborescences sont ${JAUNE}différentes${RESET}."
fi

echo "Il y a un total de ${VERT}"$nbtot" fichiers ${RESET}dans les arborescences."
echo "Il y a ${VERT}"$filedif" fichiers ${RESET}qui ont un md5 différent."
echo "L'arborescence" $dir1 "possède x fichiers différents de" $dir2

delFile $resultat
