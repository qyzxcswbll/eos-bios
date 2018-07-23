#!/bin/bash -e

# THIS IS A SAMPLE FILE. PLEASE TWEAK FOR YOUR INFRASTRUCTURE.

# `boot.sh` hook
#
# $1 genesis JSON
# $2 ephemeral public key
# $3 ephemeral private key
#
# This process must not BLOCK.

docker kill -s TERM nodeos-bios || true
docker rm nodeos-bios || true

echo "Copying base config"
cp base_config.ini config.ini

echo "Writing genesis.json"
echo $1 > genesis.json

echo "producer-name = eosio" >> config.ini
echo "enable-stale-production = true" >> config.ini
echo "signature-provider = $2=KEY:$3" >> config.ini

echo "Removing old nodeos data (you might be asked for your sudo password)..."
sudo rm -rf /tmp/nodeos-data

echo "Running 'nodeos' through Docker."
docker run -ti --rm --detach --name nodeos-bios \
       -v `pwd`:/etc/nodeos -v /tmp/nodeos-data:/data \
       -p 8888:8888 -p 9876:9876 \
       gcr.io/eoscanada-public/eosio-nodeos-prod:v1.1.0-16.04 \
       /opt/eosio/bin/nodeos --data-dir=/data \
                             --config-dir=/etc/nodeos \
                             --genesis-json=/etc/nodeos/genesis.json

#~/build/eos/build/programs/nodeos/nodeos --data-dir /tmp/nodeos-data --genesis-json `pwd`/genesis.json --max-transaction-time=5000 --p2p-listen-endpoint=127.0.0.1:65432 --config-dir `pwd` &

echo ""
echo "   View logs with: docker logs -f nodeos-bios"
echo ""

echo "Waiting 2 secs for nodeos to launch through Docker"
sleep 2

echo "See output.log for details logs"
