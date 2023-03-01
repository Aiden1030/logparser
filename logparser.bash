#!/bin/bash  

oldIFS=$IFS

directory=$1

#when the input number is wrong
if [[ ! $# == 1 ]]
then 
	echo 'Usage ./logparser.bash <logdir>'
	exit 1
fi

#raise an error for  incorrect input

if [[ ! -d $directory  ]]
then 
	echo Error: /tas/r is not a valid directory name >&2
exit 2
fi


#file names and sort it by numbers

files=$(find  $directory  -name '*.log')
files=$(sort -n <<< $files)

#clear exisitng csv content
$(echo )> logdata.csv

#largest for loop - takes filenames

for file in $files
do
	
	#name

	filename=$(basename "$file")
	name=$filename



#################   host and port name collecting ##############	
#get host and port
#divide filename by period and assign to variables


IFS=\.

#split <host.code.log> format into 3
read -ra hostname <<< $filename
a=0

#name assignment
for i in $filename
do
	case $a in 
		
		0)a=1; hostname=$i;;

			1) a=2; givenName=$i;;

			2) ;;

		esac
	done
IFS='
'

#test
#echo full is       $hostname
#echo givenName       $givenName 





##################################################################




#cat $file | grep -v "Broadcast message request received" | awk '{print $4, ":" }' > grepped


broadcastTime=''

	#Second largest for loop 
	#go through Id list from $file
	#catches Ids and broadcasting time 
	for Id in $(awk '/Broadcast message request received/ { 
		print $NF }' $file); do
	       	
		for broadcast in $( awk -v Id=$Id '/Broadcast message request received/{ if($NF == Id){print $4
			}}' $file ) 
		do
			broadcast=$broadcast
	done

	

#echo broadcast $broadcast
#third largest for loop go through all files and 
#catch lines with senderID	

for nestFile in $files
	do
		



#nestFile name assigning...
#same process as above
IFS=\.



#split <host.code.log> format into 3

nest=$(basename "$nestFile")
read -ra nest2 <<< $nest
a=0

#name assignment
for i in $nest
do
        case $a in

                0)a=1; nestHostname=$i;;

                        1) a=2; nestGivenName=$i;;

                        2) ;;

                esac
        done
IFS='
'


#test
#echo full is       $nestHostname
#echo givenName       $nestGivenName


#creating names
sender=$hostname:$givenName
receiver=$nestHostname:$nestGivenName


#test
#echo sender $sender
#echo receiver $receiver
	


#main awk  
# awk string 
#1:"Received a message from 'sender'" 
#2:"deliver INFO"
#then collect the timestamps
#put them all together to make one line in csv
#print the line in csv file



awk -v sender=$sender -v receiver=$receiver -v broadcastTime=$broadcast -v hostname=$hostname -v Id=$Id -v givenName=$givenName -v nestHostname=$nestHostname -v nestGivenName=$nestGivenName "/Received a message from. .*senderProcess":"$hostname":"$givenName":"val":"$Id/ { receivedTime=\$4 } /deliver INFO":" Received ":"$Id from ":" $hostname":"$givenName/ { deliveredTime=\$4 } END { print  sender, Id , receiver , broadcastTime, receivedTime, deliveredTime}" "$nestFile"| sed 's/ /,/g ' >> logdata.csv 
	done

#now repeat this for all the Ids	
 done	
 #after that do the same for the other files
done
#End of question 3 solution
#echo end of q 3

sender=""
receiver=""
name=""
Id=""
nestFile=""
Filename=""
files=""
file=""
receivedTime=""
deliveredTime=""
result=""
nestfile=""
nest=""
broadcast=""
a=0
x=0
IFS=$oldIFS














#Start of question 4 solution







#list senders and receivers 


$(echo ) > stats.csv

while IFS="," read sender MsgId receiver brocastTime receivedTime deliveredTime; do

if [[ $sender == $oldsender ]]
then
x=1
else
oldsender=$sender
senderList+="$sender " 


fi




for forReceiver in $receiverList
do
	if [[ $forReceiver == $receiver ]]
	then
	x=2
		break
		else 
	x=1

	fi

done

if [[ $x == 1 ]]
then

receiverList+="$receiver "
fi


done < logdata.csv

                                                                     #echo senderList $senderList
                                                                     #echo receiverList $receiverList

#list names vertically, change empty space with newline
                                                                     #sort filenames by numbers 

receiverList=$( sort -t : -k 2 -g <<< $(sed -e 's/  */\n/g' <<< "$receiverList"))

                                                                     #echo receiverList $receiverList


senderList=$( sort -t : -k 2 -g <<< $(sed -e 's/  */\n/g' <<< "$senderList"))

                                                                     #echo senderList $senderList







#echo receiverList is $receiverList



receiverListCopy=$receiverList



#creating first row: a comma seperated line of receivers

firstRow="broadcaster,nummsgs"
for string in $receiverList
do
	firstRow+=",$string"
done
#echo firsRow is going to be $firstRow
              
			    #using lists collect info
echo $firstRow > stats.csv




#for loop senders and receivers


for forSender in $senderList
do

for forReceiver in $receiverList
do

#starts reading logdata.csv file, only reads once per  loop, 
#then do the same for next receiver, next loop

	while IFS="," read sender MsgId receiver brocastTime receivedTime deliveredTime; do

		if [[ $sender == $forSender ]]
		then 
			
			if [[ $forReceiver == $receiver ]]
			then 
				num=$(($num+1))

			
				#echo num is now $num
				if [[ $deliveredTime == "" ]] 
				then 
					empty=$(($empty+1))
					#echo empty is now $empty
				fi
			fi
		
		fi

	done < logdata.csv
# collected number of emmpty spaces and message sender to receiver count
		
oldSender=$forSender

oldReceiver=$forReceiver

#printing result








#echo .................................. 
#echo
#echo
#echo
#echo ..................................
#echo
#	echo num is now $num
#echo
#	echo empty is now $empty
#echo	





#calculating the efficiency

result=$(    bc <<< "scale=3; ($num*100-$empty*100)/$num" ) 




#echo
#                        echo result $result percentage
#echo
#                        echo sender $oldSender
#echo
#                        echo receiver $oldReceiver
#echo			

#                        echo number of message is $num
#echo
#echo $empty messages are failed delivering



#record efficiency

resultList="$resultList,$result"







#echo The total num of messages 
#echo that was broadcast from this sender is 
#echo : $num
#echo
#echo resultList is now $resultList






#reset variables  
#next loop, repeat for other receivers 

savedNum=$num
num=0
result=0
empty=0
done


#one sender done

#echo
#echo
#echo $firstRow
#echo
#echo the string printed out is "$forSender"",""$savedNum""$resultList"


#output line
echo "$forSender"",""$savedNum""$resultList" >> stats.csv

resultList=""
done










#stats.html

#question 5


#Table start and end
htmlStart="<HTML>"
body="<BODY>"
middlepart="<H2>GC Efficiency</H2>"
table="<TABLE>"

#printing
echo $htmlStart > stats.html
echo $body >> stats.html
echo $middlepart >> stats.html
echo $table >> stats.html




#substituting comma 

for sentence in $(cat stats.csv)
do
if [[ $x == 1 ]]
then
#	echo $sentence


A='<TR><TD>'	
middle1='</TD><TD>'                        #printing after first  sentence

B='</TD></TR>'

A+=$sentence
A+=$B


out=$(sed -e "s@,@$middle1@g" <<< $A)
echo $out >> stats.html                          

else
		a='<TR><TH>'
		a+=$sentence
	        b='</TH></TR>'           #printing first sentence 
		a+=$b



middle='</TH><TH>'
out=$(sed -e "s@","@$middle@g" <<< $a)
echo $out >> stats.html

		x=1

fi

done

slashTable="</TABLE>"
slashBody="</BODY>"
slashHtml="</HTML>"

echo $slashTable >> stats.html
echo $slashBody >> stats.html               #printing ending statements
echo $slashHtml >> stats.html







exit 0



 
