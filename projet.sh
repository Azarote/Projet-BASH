#!/bin/bash
#
#=============================================
#
# Script projet BASH 2019 M1101 - Systèmes
# MUNOZ Matteo - POLLET Lucas - CORIZZI Ianis
# Groupe X 
#
#=============================================


#Définition des noms de fichier sortie dans une variable

sortieFile="sortie.txt"
fichdif="FichDif.txt"
dossdif="DossDif.txt"
result="résultat.txt"
md5unique="md5unique.txt"
listedossier1="listedossier1.txt"
listedossier2="listedossier2.txt"
listedossiermd51="listedossiermd51.txt"
listedossiermd52="listedossiermd52.txt"
tempsousdossier="tempsousdossier.txt"
tempsousdossier2="tempsousdossier2.txt"
listefichier1="listefichier1.txt"
listefichier2="listefichier2.txt"

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

#Suppression des anciens fichiers si existants
delFile $sortieFile
delFile $fichdif
delFile $dossdif
delFile $result
delFile $listedossiermd51
delFile $listedossiermd52
delFile $tempsousdossier
delFile $tempsousdossier2
delFile $listefichier1
delFile $listefichier2

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
echo "-------------------------------------------------"
echo "Analyse des fichiers..."
for i in `find $dir1 -type f`
	do 
		md5sum $i >> $sortieFile #récupération de toute les empreintes du premier répertoire
		md5sum $i >> $listefichier1 
		nbligne1=`expr $nbligne1 + 1`
	done
		
for j in `find $dir2 -type f`
	do 
		md5sum $j >> $sortieFile #récupération de toute les empreintes du deuxième répertoire
		md5sum $j >> $listefichier2
		nbligne2=`expr $nbligne2 + 1`
	done


find $dir1 -type d | tail -n +2 >> listedossier1.txt
find $dir2 -type d | tail -n +2 >> listedossier2.txt

createMD5folder(){ # $1 = listedossier $2 = liste des md5 des fichiers
	while read line
	do
		find $line -type f -exec md5sum {} \; >> tempsousdossier.txt
		find $line -type d -exec basename {} \; | sed '1d'  >> tempsousdossier2.txt
		while read line2
			do
				chemin=`echo "$line2" | cut -d ' ' -f3` 
				nom=`basename $chemin`
				md5=`echo "$line2" | cut -d ' ' -f1`
				echo "$md5" "$nom" >> tempsousdossier2.txt
			done < tempsousdossier.txt
		chemin=`echo "$line" | cut -d ' ' -f3` 
		md5=`md5sum tempsousdossier2.txt | cut -d ' ' -f1`
		echo "$md5" "$chemin"  >> $2
		
		rm -f tempsousdossier.txt
		rm -f tempsousdossier2.txt
	done < $1
}

echo "Analyse des dossiers..."
createMD5folder listedossier1.txt listedossiermd51.txt
createMD5folder listedossier2.txt listedossiermd52.txt  

nbforfile1=0
nbforfile2=0
nbforfolder1=0
nbforfolder2=0

compareForDif(){ # $1 = premier fichier ou dossier à comparer $2 = deuxieme fichier ou dossier à comparer $3 nb alloué 
	nbdif=0
	while read line
	do
		bool=0
		linemd5=`echo "$line" | cut -d ' ' -f1`
		fichchemin=`echo "$line" | cut -d ' ' -f3`
		linechemin=`echo "$line" | cut -d ' ' -f2`
		while read line2
			do
				line2md5=`echo "$line2" | cut -d ' ' -f1`
				if test "$linemd5" == "$line2md5"
				then
					bool=1
				fi
			done < $2
		if test $bool -eq 0 
		then
			if [ $3 -eq 1 ] || [ $3 -eq 2 ]
			then
			echo $linemd5 $fichchemin >> $fichdif
			fi
			if [ $3 -eq 3 ] || [ $3 -eq 4 ]
			then
			echo $linemd5 $linechemin >> $dossdif
			fi
			nbdif=`expr $nbdif + 1`  
		fi
	done < $1
	
	if test $3 -eq 1
		then
		nbforfile1=$nbdif
	elif test $3 -eq 2
		then
		nbforfile2=$nbdif
	elif test $3 -eq 3 
		then
		nbforfolder1=$nbdif
	elif test $3 -eq 4
		then
		nbforfolder2=$nbdif
	fi	
	
}

echo "Comparaison des fichiers..."
compareForDif $listefichier1 $listefichier2 1
compareForDif $listefichier2 $listefichier1 2

echo "Comparaison des dossiers..."
compareForDif $listedossiermd51 $listedossiermd52 3
compareForDif $listedossiermd52 $listedossiermd51 4

nbfiledif=$(($nbforfile1 + $nbforfile2))
nbfolderdif=$(($nbforfolder1 + $nbforfolder2))

	
nbfichier1=`find $dir1 -type f | wc -l`
nbfichier2=`find $dir2 -type f | wc -l`	
nbtot=$(($nbfichier1 + $nbfichier2))
filedif=`cat $sortieFile | cut -d ' ' -f1 | sort -u | wc -l`

echo "-------------------------------------------------"
echo "Les MD5 de chaque fichier différent:"
cat $sortieFile | cut -d ' ' -f1 | sort -u > $md5unique #récupère toute les empreintes différentes
cat $md5unique

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

echo " "
echo "-------------------------------------------------"

#Comparaison des aborescences
md5forfolder1=`md5sum $listedossier1 | cut -d ' ' -f1`
md5forfolder2=`md5sum $listedossier2 | cut -d ' ' -f1`
md5forfile1=`md5sum $listefichier1 | cut -d ' ' -f1`
md5forfile2=`md5sum $listefichier2 | cut -d ' ' -f1`
echo "Fichier différent entre $dir1 et $dir2" >> $result | cat $fichdif  >> $result
echo -e "\nDossier différent entre $dir1 et $dir2" >> $result | cat $dossdif >> $result

delFile $dossdif
delFile $fichdif

# - AFFICHAGE RESULTATS - 

if [ $md5forfolder1 == $md5forfolder2 ] && [ $md5forfile1 == $md5forfile2 ]
	then
	echo "Les deux arborescences sont ${JAUNE}identiques${RESET}."
	nbtot=$nbfichier1
else
	echo "Les deux arborescences sont ${JAUNE}différentes${RESET}."
fi

echo  "-------------------------------------------------"

echo "Il y a ${VERT}$nbfiledif${RESET} fichiers différents entre l'arborescence $dir1 et $dir2"
echo "Il y a ${VERT}$nbfolderdif${RESET} dossiers différents entre l'arborescence $dir1 et $dir2"

echo "Il y a un total de ${VERT}"$nbtot" fichiers ${RESET}dans les arborescences."
echo "Il y a ${VERT}"$filedif" fichiers ${RESET}qui ont un md5 différent."
echo "Les fichiers et dossiers différents ainsi que leurs chemins sont dans ${VERT}"résultat.txt"${RESET}."

echo "-------------------------------------------------"

delFile $md5unique
delFile $listedossier1
delFile $listedossier2
