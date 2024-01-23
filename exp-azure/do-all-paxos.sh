#!/usr/bin/env bash

wait_for_servers_to_start() {
    local protocol=$1
    local binary=$2
    local parameter=$3
    local timer=0
    local max_wait_time=60
    local SERVER_COUNT=$(cat "replica-location.config" | wc -l)

    while true; do
        sleep 10
        local running_servers=$(./sbin/server.sh settings.sh list $binary | grep "./$binary" | awk -F "./$binary " '{print $2}' | sort | uniq | wc -l)
        
        if [[ $running_servers -eq $SERVER_COUNT ]]; then
            echo "All $protocol servers are up and running."
            break
        else
            echo "Some $protocol servers are not running. Attempting to restart missing servers..."
            for server_id in $(seq 1 $SERVER_COUNT); do
                if ! ./sbin/server.sh settings.sh list $binary | grep -q "./$binary -i $server_id"; then
                    echo "Restarting $binary server with ID $server_id..."
                    ./sbin/restart.sh settings.sh $binary $server_id $parameter
                fi
            done
        fi

        sleep 10
        timer=$((timer + 5))

        if [[ $timer -ge $max_wait_time ]]; then
            echo "Timeout waiting for $protocol servers to start. Exiting."
            exit 1
        fi
    done
}

get_client_parameter() {
    local protocol=$1
    case $protocol in
        dynamic)   echo "d" ;;
        mencius)   echo "m" ;;
        epaxos)    echo "e" ;;
        paxos)     echo "p" ;;
        fastpaxos) echo "fp" ;;
        *)         echo "Unknown protocol"; exit 1 ;;
    esac
}

perform_experiment() {
    local exp_id=$1
    local protocol=$2
    local binary=$3
    local parameter=$4

    echo "Starting $protocol experiment"
    ./sbin/server.sh settings.sh start $binary $parameter
    wait_for_servers_to_start $protocol $binary $parameter

    client_parameter=$(get_client_parameter $protocol)
    ./sbin/client.sh settings.sh start $client_parameter
    ./sbin/wait_client_processes.sh
    ./sbin/server.sh settings.sh stop $binary
    ./sbin/wait_server_processes.sh $binary
    ./sbin/log.sh settings.sh collect
    mkdir -p latency/$exp_id/$protocol
    mv log/* latency/$exp_id/$protocol/
    ./sbin/check_experiment_result.sh $exp_id $protocol
}

case $2 in
    "noLeader")
        perform_experiment "$1" "epaxos" "epaxos" "e false"
        perform_experiment "$1" "mencius" "epaxos" "m true"
        ;;
    "Leader")
        perform_experiment "$1" "dynamic" "dynamic" ""
        perform_experiment "$1" "paxos" "epaxos" "p false"
        perform_experiment "$1" "fastpaxos" "fastpaxos" ""
        ;;
    *)
        echo "Invalid argument"
        exit 1
        ;;
esac
