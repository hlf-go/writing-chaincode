#!/bin/bash

echo "==============================="
echo "-------Creating channel -------"
echo "==============================="
peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx

echo "==============================="
echo "------ Join channel -----------"
echo "==============================="
peer channel join -b mychannel.block

echo "==============================="
echo "---- Install chaincode --------"
echo "==============================="
peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/myfirstchaincode

echo "==============================="
echo "-- Instantiating chaincode ----"
echo "==============================="
peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR ('Org1MSP.member')"