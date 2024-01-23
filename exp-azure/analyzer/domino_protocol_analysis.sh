#!/usr/bin/env bash

# 対象のプロトコルをdynamicに設定
protocol="dynamic"

# 出力ファイルを作成
touch latency/$protocol\_analysis.txt

# 実験リストを読み込む
cat exp-list.backup | while read LINE
do
    exp_id=`echo $LINE | cut -d " " -f 1`
    data=`cat latency/$exp_id/$protocol/client* | grep -w "[0-1] , 1 , [0-1] , [0-9]\+ , [0-9]\+"`
    
    # FastPaxosを使用した回数と使用しなかった回数をカウント
    fastPaxos_count=`echo "$data" | cut -d "," -f 3 | grep -c "1"`
    non_fastPaxos_count=`echo "$data" | cut -d "," -f 3 | grep -c "0"`

    # 出力の決定
    if [ "$fastPaxos_count" -gt "$non_fastPaxos_count" ]; then
        result="FastPaxos"
    else
        result="Mencius"
    fi

    # 結果をファイルに書き込む
    echo "$LINE $result" #>> latency/$protocol\_analysis.txt
done > latency/$protocol\_analysis.txt
