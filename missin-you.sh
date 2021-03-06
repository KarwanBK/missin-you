#!/bin/sh
if [ ! -f "/private/var/tmp/cydia.log" ]; then
    echo "no error bye !"
	exit 0;
fi
cd "/"
number=`awk '/Running dpkg/{print NR}' "/private/var/tmp/cydia.log" | awk 'BEGIN{x=-2147483648};$0>x{x=$0};END{print x}'`
sed -e '1,'$number'd' "/private/var/tmp/cydia.log" >cydia.log
number=`awk '/Unpacking/{print NR}' "/private/var/tmp/cydia.log" | awk 'BEGIN{x=-2147483648};$0>x{x=$0};END{print x}'`
sed -e '1,'$number'd' "/private/var/tmp/cydia.log" >cydia.log

grep -o ' line .*$' cydia.log | cut -c7- >temp.txt # getting error himself
grep -Eo '^[^ ]+' temp.txt >tss2.txt && rm -rf temp.txt # get only first line
du -h | sort -n -r -u tss2.txt >temp.txt && rm -rf tss2.txt #remove duplicates, sort high->low
echo ""
echo "- Using at your own risk !"
echo -n "- Killing Cydia"
killall "Cydia" &>/dev/null
echo " Done !"
echo -n "- backup your status file"
cd /Library/dpkg/
zip -9 -ru "/Library/dpkg/status.zip" "/Library/dpkg/status" &>/dev/null
echo " Done !" && cd /
echo "================="
b=`wc -l < temp.txt` && a=0
if [[ -f "/temp.txt" ]] && [[ ! -s "/temp.txt" ]]; then 
	echo "- No ERROR !"
else
    while [ $a -lt $b ]
    do
    a=`expr $a + 1`
da_error=`cat temp.txt | sed ''$a'!d'` #error himself
loc_error=`awk '/'$da_error'/{ print NR; exit }' cydia.log` #location in cydia.log
loc_miss=`expr $loc_error + 1` # the line which contain missing what
cat cydia.log | sed ''$loc_miss'!d' >boq.txt
we_miss=`grep -o ' missing .*' boq.txt | cut -c 10-19`":"; # missing what
	    if [ "$we_miss" == "maintainer:" ]; then
	    we_miss="Maintainer:"
		else
		we_miss="Description:"
		fi
	echo "- $da_error $we_miss"
	da_error=`expr $da_error - 1`
    sed -i ''$da_error'i\'$we_miss' KurdiOS' /Library/dpkg/status
    done
fi
echo "================="
echo "- Done ! "
echo "- by @Karwanbk"
echo ""
rm -rf boq.txt
rm -rf temp.txt
rm -rf cydia.log
exit 0;
