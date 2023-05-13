#!/usr/bin/env bash
protocols=(dynamic epaxos fastpaxos mencius paxos)

for protocol in "${protocols[@]}"
do
    touch latency/$protocol.txt
    cat exp-list.config | while read LINE
    do
        #grep -r -w "[0-1] , [0-1] , [0-1] , [0-9]\+ , [0-9]\+"
        exp_id=`echo $LINE | cut -d " " -f 1`
        data=`cat latency/$exp_id/$protocol/client* | grep -w "[0-1] , 1 , 1 , [0-9]\+ , [0-9]\+"`
        num=`echo "$data" | wc -l`
        echo -n $LINE 
        echo -n " "
        if [ "$num" == "0" ] || [ "$num" == "1" ]; then
            echo "error"
        else 
            echo "$data" | sed -e "s/ , /,/g" | cut -d "," -f 4 | sort -n | awk 'BEGIN{OFMT="%d"} { a[i++]=$1; } END { x=int((i+1)/2); if (x < (i+1)/2) print (a[x-1]+a[x])/2; else print a[x-1]; }'
        fi
    done > latency/$protocol.txt
done