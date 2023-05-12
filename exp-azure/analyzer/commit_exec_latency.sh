#!/usr/bin/env bash
protocols=(dynamic epaxos fastpaxos mencius paxos)

for protocol in "${protocols[@]}"
do
    touch latency/$protocol.txt
    cat exp-list.config | while read LINE
    do
        #grep -r -w "[0-1] , [0-1] , [0-1] , [0-9]\+ , [0-9]\+"
        exp_id=`echo $LINE | cut -d " " -f 1`
        data=`cat latency/$exp_id/$protocol/server* | grep -E ' [[:digit:]]+ ns'`
        num=`echo "$data" | wc -l`
        echo -n $LINE 
        echo -n " "
        if [ "$num" == "0" ] || [ "$num" == "1" ]; then
            echo "error"
        else 
            echo "$data" | rev | cut -d " " -f 2 | rev |awk '{s+=$1} END {print s/NR}'
        fi
    done #> latency/$protocol.txt
done