# Script projet 2019 M1101 - Systèmes
# MUNOZ Matteo - POLLET Lucas - CORIZZI Ianis
# Groupe X 

sortieFile="sortie.txt"
resultat="resultat.txt"
rm $resultat

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
		md5sum $i >> $sortieFile
		nbligne1=`expr $nbligne1 + 1`
	done
		
for j in `find $dir2 -type f`
	do 
		md5sum $j >> $sortieFile
		nbligne2=`expr $nbligne2 + 1`
	done
	
temp1=`find $dir1 -type f -exec md5sum {} \; > tempmd5 && md5sum tempmd5 && rm tempmd5 | cut -d ' ' -f1`
temp2=`find $dir2 -type f -exec md5sum {} \; > tempmd5 && md5sum tempmd5 && rm tempmd5 | cut -d ' ' -f1`
nbfichier1=`find $dir1 -type f | wc -l`
nbfichier2=`find $dir2 -type f | wc -l`	
nbtot=$(( $nbfichier1 + $nbfichier2 ))
filedif=`cat $sortieFile | cut -d ' ' -f1 | sort -u | wc -l`
cat $sortieFile | cut -d ' ' -f1 | sort -u > $resultat

#Test pour sortir les fichiers différents
k=1
while  [ $k -le $filedif ]
	do
		sed -n $k'p' resultat.txt && grep `sed -n $k'p' resultat.txt` sortie.txt | cut -d ' ' -f3 > test.txt
		k=$((k+1))
	done

#Comparaison des aborescences
if [ "$temp1" = "$temp2" ]
	then
	echo "Les deux arborescences sont identiques."
else
	echo "Les deux arborescences sont différentes."
fi
	
echo "Les résultats sont dans le fichier $resultat"
echo "Il y a un total de" $nbtot "fichiers dans les arborescences."
echo "Il y a" $filedif "fichiers différents."
echo "La liste des fichiers différents est dans le fichier $resultat"
