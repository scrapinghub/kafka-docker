#!/bin/bash
DEFAULT_STREAMS=1
DEFAULT_GROUP_ID="KafkaMirror"
DEFAULT_OFFSET_RESET="largest"

if [ -n "$WHITE_LIST" ]; then
    WHITE_LIST="--whitelist $WHITE_LIST"
fi

if [ -n "$BLACK_LIST" ]; then
    BLACK_LIST="--blacklist $BLACK_LIST"
fi

if [ -z "$STREAM_COUNT" ]; then
    STREAM_COUNT=$DEFAULT_STREAMS
fi

if [ -z "$CONSUMER_OFFSET_RESET" ]; then
    CONSUMER_OFFSET_RESET=$DEFAULT_OFFSET_RESET
fi

if [ -z "$CONSUMER_GROUP_ID" ]; then
    CONSUMER_GROUP_ID=$DEFAULT_GROUP_ID
fi

if [ -z "$CONSUMER_ZK_CONNECT" ]; then
    echo "Specify CONSUMER_ZK_CONNECT connection string"
    exit 2
fi

if [ -z "$DOWNSTREAM_BROKERS" ]; then
    echo "Specify DOWNSTREAM_BROKERS for the producer"
    exit 3
fi


cat <<- EOF > ~/consumer.config
    zookeeper.connect=$CONSUMER_ZK_CONNECT
    group.id=$CONSUMER_GROUP_ID
    auto.offset.reset=$CONSUMER_OFFSET_RESET
EOF


cat <<- EOF > ~/producer.config
    bootstrap.servers=$DOWNSTREAM_BROKERS
EOF

$KAFKA_HOME/bin/kafka-run-class.sh kafka.tools.MirrorMaker --consumer.config ~/consumer.config --producer.config ~/producer.config --num.streams $STREAM_COUNT $WHITE_LIST $BLACK_LIST
