#!/bin/bash

# =============================================
#  Dafturn Ofris Erdana - Locking your System
# =============================================
# Version       : 1.9.05-en
# Created by    : Muhammad Faruq Nuruddinsyah
# E-Mail        : faruq@dafturn.org
# Created date  : October, 12th 2008
# =============================================
# An Open Source from Indonesia
# =============================================

# =============================================
# Modified by:   Ali Riza KESKIN (SulinOS community)
# Modified date: 06.11.2019
#
# Added features:
#  - Password protection
#  - Set or clear Ofris password
#  - root checking
# =============================================

#----- Cheching root -----
if [ $UID -ne 0 ] ; then
	echo "Root permission needed!"
	exit 1
fi
#----- Starting ----
echo 
echo "==================================================="
echo "    Dafturn Ofris Erdana - Locking your System"
echo "         Created by : Muhammad Faruq Nuruddinsyah"
echo "               Development: Ali Rıza KESKIN"
echo "==================================================="
echo 

#----- Password protection by Kelompok 4 OSSDev -----
if [ -e .ofris-password ]; then
	ofris_password=$(<.ofris-password)
	echo -n "Type the password: "
	read -s password
	password=$(echo -n "$password" | md5sum | cut -c 1-32)
	
	if [ $password != $ofris_password ]; then
		echo 
		echo 
		echo "Wrong password!"
		echo 
		exit
	fi
	
	echo 
	echo 
fi

echo "Menu:"
echo "  1. Freeze the system for this User only"
echo "  2. Freeze the system for specified User"
echo "  3. Freeze the system for all Users"
echo "  4. Unfreeze the system"
echo "  5. View status"
echo "  6. Set password"
echo "  7. Exit"
echo 
#-------------------

#----- Mendeklarasikan variabel -----
is_opt=false
is_success=true
ofris_n=6
ofris_tmp_co=1
is_cho=false
#------------------------------------

#----- Awal script untuk menentukan pilihan -----
while [ $is_opt = false ]; do
	echo -n "Please type the menu number you want: "
	read -n 1 ofris_opt

	if [[ $ofris_opt = 1 ]]; then
		is_opt=true
		ofris_tmp_co=1
	elif [[ $ofris_opt = 2 ]]; then
		is_opt=true
		ofris_tmp_co=2
	elif [[ $ofris_opt = 3 ]]; then
		is_opt=true
		ofris_tmp_co=3
	elif [[ $ofris_opt = 4 ]]; then
		is_opt=true
	elif [[ $ofris_opt = 5 ]]; then
		is_opt=true
	elif [[ $ofris_opt = 6 ]]; then
	#----- Password protection by Kelompok 4 OSSDev -----
		is_opt=true
	elif [[ $ofris_opt = 7 ]]; then
		is_opt=true
		echo 
		exit
	else
		echo "Sorry, you choose wrong menu. Please try again..."
		echo
		is_opt=false
	fi
done
#------------------------------------------------

#----- Script utama -----------------------------
if [[ $ofris_tmp_co = 1 ]]; then
	ofris_user="${HOME:$ofris_n}"
elif [[ $ofris_tmp_co = 3 ]]; then
	ofris_user=""
elif [[ $ofris_tmp_co = 2 ]]; then
	is_cho=true
	ofris_user=""
fi

grep -v "rsync -a --delete /etc/" /etc/rc.local > ofris_tmp
set $(wc -l ofris_tmp)
ofris_orig=$1
set $(wc -l /etc/rc.local)
ofris_recnt=$1
ofris_rst=$[$ofris_recnt-$ofris_orig]
rm ofris_tmp

if [[ $ofris_opt = '1' || $ofris_opt = '2' || $ofris_opt = '3' ]]; then
#----- Mengunci sistem -----
	echo 
	echo "===== Freeze the System ====="
	echo 
	echo "Please wait..."
	echo 

	if [[ $is_cho = true ]]; then
		is_cho_suc=false
		while [ $is_cho_suc = false ]; do
			is_cho_suc=false
			echo -n "Please type the username you want to freeze: "
			read ofris_cho
			
			if [ -d "/home/$ofris_cho" ]; then
				echo 
				is_cho_suc=true
				ofris_user=$ofris_cho
			else
				echo "Sorry, the username is wrong. Please try again..."
				echo 
			fi
		done
	fi

	if [ $ofris_rst = 1 ]; then 
		echo "Error : The system has been frozen."
		echo 
		is_success=false
	else
		grep -v "exit 0" /etc/rc.local > ofris_tmp
		echo "rsync -a --delete /etc/.ofris/$ofris_user/ /home/$ofris_user/" >> ofris_tmp
		echo "exit 0" >> ofris_tmp
		rm /etc/rc.local
		cp ofris_tmp /etc/rc.local
		rm ofris_tmp
	fi

	if [ $is_success = true ]; then
		if [ -d /etc/.ofris ]; then
			rm -r /etc/.ofris
		fi
		
		if [ -d /etc/.ofris ]; then
			rsync -a --delete /home/$ofris_user /etc/.ofris/
		else
			mkdir /etc/.ofris/
			
			if [[ $ofris_user != "" ]]; then
				mkdir /etc/.ofris/$ofris_user
			fi
			
			rsync -a --delete /home/$ofris_user /etc/.ofris/
		fi
		
		chmod +x /etc/rc.local
	fi
	
	if [ $is_success = true ]; then
		echo "The system was successfully frozen, please restart your computer to complete..."
		echo 
	fi

elif [ $ofris_opt = '4' ]; then
#----- Membuka sistem -----
	echo 
	echo "===== Unfreeze the System ====="
	echo 
	echo "Please wait..."
	grep -v "rsync -a --delete /etc/" /etc/rc.local > ofris_tmp_b
	rm /etc/rc.local
	cp ofris_tmp_b /etc/rc.local
	rm ofris_tmp_b
	
	if [ -d /etc/.ofris ]; then
		rm -r /etc/.ofris
	fi
	
	echo 
	echo "The system was successfully unfrozen..."
	echo 

elif [ $ofris_opt = '5' ]; then
#----- Menampilkan status -----
	if [ $ofris_rst = 1 ]; then
		echo 
		echo "===== Status ====="
		echo " The system has been locked..."
		echo 
	else
		echo 
		echo "===== Status ====="
		echo " The system has not locked yet..."
		echo 
	fi

elif [ $ofris_opt = '6' ]; then
#----- Password protection by Kelompok 4 OSSDev -----
#----- Set or clear password -----
	echo 
	echo "===== Set Password ====="
	echo 
	echo -n "Type new password or just hit enter to clear the password: "
	
	read -s new_password
	echo -n "$new_password" > .ofris_tmp_pwd
	password_count=$(wc -m .ofris_tmp_pwd)
	rm .ofris_tmp_pwd
	password_count=${password_count:0:1}
	
	if [[ $password_count = 0 ]]; then
		if [ -e .ofris-password ]; then
			rm .ofris-password
		fi
		
		echo 
		echo 
		echo "Password successfully removed."
		echo 
	else
		hash_password=$(echo -n "$new_password" | md5sum | cut -c 1-32)
		echo -n "$hash_password" > .ofris-password
		
		echo 
		echo 
		echo "Password successfully changed."
		echo 
	fi
fi

#----- Ending session -----
echo -n "[Press any key to exit...] "
read -s -n 1
echo 
echo 

#========== Selesai ===================================================================

