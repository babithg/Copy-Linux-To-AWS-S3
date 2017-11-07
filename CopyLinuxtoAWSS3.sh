#!/bin/bash

#Copy file to AWS S3 

DirList="/tmp/dir_list.txt"
aws_path="s3://MyBucket/MyFolder/"
localpath="/tmp/"
errorReport="/tmp/S3_backuperror.txt"
copyReport="/tmp/S3_copyreport.txt"
echo "Script Started on :`date`">>$errorReport
echo "Script Started on :`date`">>$copyReport

for oneDB in `cat $DirList`
do
	abspath="$localpath$oneDB/"
	awsabspath="$aws_path$(echo "$oneDB" | tr -d '[:space:]')/"

	if [ -d $abspath ]
	then
		filecount=`ls $abspath | wc -l`
		if [ $filecount -gt 0 ]
		then
			echo "Starting Copy to S3 from Directory:$abspath"
			aws s3 cp $abspath $awsabspath --recursive

			#Checking Copied or not 
			for CheckingOne in `ls $abspath`
			do
				awssinglefile=$awsabspath$CheckingOne
				WithAWS=`aws s3 ls $awssinglefile | awk '{print $3","$4}'`
				localsinglefile=$abspath$CheckingOne
				WithLocal=`ls -l $localsinglefile | awk '{print $5","}'`
				WithLocal=$WithLocal$CheckingOne
			        if [ "$WithAWS" == "$WithLocal" ]
				then
					echo "SUCCESSFUL: Date:`date` File $localsinglefile Copied Successfully to $awssinglefile">>$copyReport
					
					#Delete file after the after copy successfull
					rm -f $localsinglefile && echo "File: $localsinglefile Deleted" >>$copyReport
				else
					echo "ERROR: Date:`date` File $localsinglefile Not Copied to $awssinglefile" >>$copyReport
				fi
			done

		else
			echo "No File Found on $abspath">>$errorReport
		fi
	else
		echo "$oneDB not Found on $localpath">>$errorReport
	fi

done
