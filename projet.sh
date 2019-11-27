# Script projet 2019 M1101 - Systèmes
# MUNOZ Matteo - POLLET Lucas - CORIZZI Ianis
# Groupe X 

sortieFile="sortie.txt"
resultat="resultat.txt"
range="fichier-rangé.txt"
diffe="différence.txt"
#On teste si les fichiers existent
if [ -f $resultat ]
then 
rm $resultat
fi
if [ -f $sortieFile ]
then 
rm $sortieFile
fi
if [ -f $range ]
then
rm $range
fi


echo "- Outil de comparaison de fichiers -"

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
	
#début analyse
echo "Début d'analyse... Patientez"

for i in `find $dir1 -type f`
	do 
		md5sum $i >> $sortieFile #récupération de toute les empreintes du premier répertoire 
	done
		
for j in `find $dir2 -type f`
	do 
		md5sum $j >> $sortieFile #récupération de toute les empreintes du deuxième répertoire
	done

#On récupère les md5 des 2 répertoires
temp1=`find $dir1 -type f -exec md5sum {} \; > tempmd5 && md5sum tempmd5 && rm tempmd5 | cut -d ' ' -f1`
temp2=`find $dir2 -type f -exec md5sum {} \; > tempmd5 && md5sum tempmd5 && rm tempmd5 | cut -d ' ' -f1`

nbfichier1=`find $dir1 -type f | wc -l`
nbfichier2=`find $dir2 -type f | wc -l`	
nbtot=$(($nbfichier1 + $nbfichier2))
filedif=`cat $sortieFile | cut -d ' ' -f1 | sort -u | wc -l`

echo "Les MD5 de chaque fichier différent:"
cat $sortieFile | cut -d ' ' -f1 | sort -u > $resultat #récupère toute les empreintes différentes
cat $resultat
sort $sortieFile >> $range #range les fichier par empreintes
#récupération des différents fichier et répertoire pour chaque arborescence
diff $dir1 $dir2 >> $diffe

#Comparaison des aborescences
if [ "$temp1" = "$temp2" ]
	then
	echo "Les deux arborescences sont identiques."
else
	echo "Les deux arborescences sont différentes."
fi
	
echo "Il y a un total de" $nbtot "fichiers dans les arborescences."
echo "Il y a" $filedif "fichiers différents."
echo "La liste des fichiers avec des empreintes différentes est dans le fichier $resultat"
echo "La liste de tout les fichier rangé par empreinte md5 est dans $range"
#com a supprimer avans de rendre le projet (étas de ce que vous avais fait est pourquois)
#le prof a dit que sa servais a rien de sortir les fichier différence donc je ai suprimé cette partie la 
#reste les fichier et répertoire différent pour chaque arborescences (machin avec diff) 
