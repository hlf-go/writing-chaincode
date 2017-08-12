#!/bin/bash

CHANNELNAME="mychannel"
CHAINCODEID="mycc"

echo
echo "========================================================="
echo "           START - myfirstchaincode                      "
echo "========================================================="

echo
echo "-- Creating my myfirstchannel --"
echo
peer channel create -o orderer.example.com:7050 -c $CHANNELNAME -f ./channel-artifacts/channel.tx   

echo
echo "-- Join channel --"
echo
peer channel join -b $CHANNELNAME.block 

echo
echo "-- Installing chaincode --"
echo
peer chaincode install -n $CHAINCODEID -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/myfirstchaincode

echo
echo "-- Instantiating chaincode --"
echo
peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNELNAME -n $CHAINCODEID -v 1.0 -c '{"Args":["Init","a","100","b","200"]}' -P "OR ('Org1MSP.member')" 

sleep 10

echo
echo "-- Invoking chaincode --"
echo
peer chaincode invoke -o orderer.example.com:7050 -C $CHANNELNAME -n $CHAINCODEID -c '{"Args":["invoke","a","b","10"]}'

echo
echo "========================================================="
echo "              END - myfirstchaincode                     "
echo "========================================================="