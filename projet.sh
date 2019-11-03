# Script projet 2019 M1101 - Systèmes
#Munoz Matteo - Pollet Lucas - Corizzi Ianis
#Groupe X 



sortieFile="résultat.txt"
rm $sortieFile
rm Sortie.txt

echo "- Outil de comparaison de fichiers -"

#demande des répertoires

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

#début analyse
echo "Début d'analyse... Patientez"

nbligne1=0
nbligne2=0
nbfiledif=0
filecompare=1

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
	
for(( k=1; k <= $nbligne2; k++ ))
	do 
		#La comparaison doit comparer le 1er fichier avec tous les autres fichiers du 2 répertoire puis passer au deuxième fichier et ainsi de suite
		temp1md5=`sed -n $filecompare'p' résultat.txt | cut -d ' ' -f1`
		temp2md5=`sed -n $(($nbligne1 + $k))'p' résultat.txt | cut -d ' ' -f1`

		if [ $k -eq $nbligne2 ] && [ $nbligne1 -ne $filecompare ]
			then
			filecompare=`expr $filecompare + 1`
			k=1
		  fi

		echo "Test de $temp1md5 et $temp2md5"
		if [ $temp1md5 = $temp2md5 ]
			then
			
				echo "$temp1md5 identique"
				echo "Ces fichiers sont identiques :" >> Sortie.txt
				grep $temp1md5 $sortieFile >> Sortie.txt
			
				#sed -i -e "s/$temp1md5/' '/g" $sortieFile 
		else
			nbfiledif=`expr $nbfiledif + 1`
		fi
	done
	
echo "Les résultats sont dans le fichier $sortieFile"
echo "Il y a" $nbfiledif "fichier(s) différents dans les arborescences."
