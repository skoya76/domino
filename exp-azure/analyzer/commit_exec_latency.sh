#!/usr/bin/env bash
protocols=(dynamic epaxos fastpaxos mencius paxos)

for protocol in "${protocols[@]}"
do
    touch latency/$protocol.txt
    cat exp-list.config | while read LINE
    do
        exp_id=`echo $LINE | cut -d " " -f 1`
        data=`cat latency/$exp_id/$protocol/server-* | grep -a --binary-files=text -E '[[:digit:]]+ ns'`
        num=`echo "$data" | wc -l`
        echo -n $LINE 
        echo -n " "
        if [ "$num" == "0" ] || [ "$num" == "1" ]; then
            echo "error"
        else 
            # 計算結果を配列に格納
            arr=($(echo "$data" | rev | cut -d " " -f 2 | rev))
            
            # 平均値の計算
            sum=$(IFS=+; echo "${arr[*]}")
            average=$(awk -v sum="$sum" -v num="$num" 'BEGIN {printf "%.0f", sum/num}')

            # 標準偏差の計算
            variance=$(awk -v sum="$sum" -v num="$num" 'BEGIN {s=0; for (i in ARGV) s+=ARGV[i]; avg=s/num; for (i in ARGV) {diff=ARGV[i]-avg; sdiff+=diff*diff} printf "%.0f", sdiff/num}' "${arr[@]}")
            stddev=$(awk -v variance="$variance" 'BEGIN {printf "%.0f", sqrt(variance)}')

            echo -n "$average "
            echo -n "$stddev "
            echo "$num"
        fi
    done > latency/$protocol.txt
done
