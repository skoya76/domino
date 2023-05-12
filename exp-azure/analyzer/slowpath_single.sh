#!/usr/bin/env bash
protocols=(dynamic epaxos fastpaxos)

for protocol in "${protocols[@]}"
do
    touch latency/$protocol.txt
    cat exp-list.config | while read LINE
    do
        #grep -r -w "[0-1] , [0-1] , [0-1] , [0-9]\+ , [0-9]\+"
        exp_id=`echo $LINE | cut -d " " -f 1`
        clients=`echo $LINE | cut -d " " -f 2` 
        replicas=`echo $LINE | cut -d " " -f 3` 
        IFS=',' read -ra client <<< "$clients"
        for c in "${client[@]}"; do
            if [ "$protocol" == "epaxos" ]; then
                data=`cat latency/$exp_id/$protocol/client*-$c-*.log | grep -w "0 , 1 , 0 , [0-9]\+ , [0-9]\+"`
            else
                data=`cat latency/$exp_id/$protocol/client*-$c-*.log | grep -w "1 , 1 , 0 , [0-9]\+ , [0-9]\+"`
            fi
            num=`echo "$data" | wc -l`
            echo -n $exp_id $c $replicas
            echo -n " "
            if [ "$num" == "0" ] || [ "$num" == "1" ]; then
                echo "error"
            else 
                echo "$data" | sed -e "s/ , /,/g" | cut -d "," -f 4 | sort -n | awk 'BEGIN{OFMT="%d"} { a[i++]=$1; } END { x=int((i+1)/2); if (x < (i+1)/2) print (a[x-1]+a[x])/2; else print a[x-1]; }'
            fi
        done
    done > latency/$protocol.txt
done