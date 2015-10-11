#!/bin/bash
#  
#  Copyright 2015 Emanuele Forestieri <forestieriemanuele@gmail.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.

#  SIMPLE SCRIPT FOR FIX FSCK ERROR 4

export BLUE='\033[1;94m'
export RED='\e[0;31m'
export NORMAL='\033[1;00m'

err_echo () #echo on stderr
{
	>&2 echo -e "$*"
} 

err ()
{
	err_echo $RED"[!] "$*$NORMAL
}

inf ()
{
	err_echo $BLUE"[*] "$*$NORMAL
}

ok ()
{
	err_echo $BLUE"[+] "$*$NORMAL
}

help()
{
	err_echo "Use: "$0" [partition]\n" 
	err_echo "Options:"
	err_echo "-h, --help          Show this screen and exit\n"
	exit 1
}

if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]
then 
	help
else	
	if [ `id -u` -eq 0 ] #if it is run as root
	then 
		if [ "$1" = "`fdisk -l 2>/dev/null | grep "$1" | cut -b 1-${#1}`" ] #verify that the partition is valid
		then
			ok "Partition exist"
			inf "Unmounting partition..."
			umount $1 2>/dev/null
			ok "Partition unmounted"
			inf "Fixing partition with fsck..."
			yes | fsck -CV $1 >/dev/null
			ok "Partition fixed"
		else
			err "Partition does not exist"
			exit 1
		fi
	else
		err "This script must be run as root"
		exit 1
	fi
fi
exit 0
