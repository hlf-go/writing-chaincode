#!/bin/bash

CHANNELNAME="mychannel"
CHAINCODEID="mfcc"

echo
echo "========================================================="
echo " Installing, instantiating and invoking myfirstchaincode "
echo "========================================================="

echo
echo "-- Creating my myfirstchannel --"
echo
peer channel create -o orderer.example.com:7050 -c $CHANNELNAME -f ./channel-artifacts/channel.tx 2>&1  &> ./logs/myfirstchaincode.log

echo
echo "-- Join channel --"
echo
peer channel join -b $CHANNELNAME.block 2>&1  &> ./logs/myfirstchaincode.log

echo
echo "-- Installing chaincode --"
echo
peer chaincode install -n $CHAINCODEID -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/myfirstchaincode 2>&1  &> ./logs/myfirstchaincode.log

echo
echo "-- Instantiating chaincode --"
echo
peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNELNAME -n $CHAINCODEID -v 1.0 -c '{"Args":["Init","a","100","b","200"]}' -P "OR ('Org1MSP.member')" 2>&1  &> ./logs/myfirstchaincode.log

echo
echo "-- Invoking chaincode --"
echo
peer chaincode invoke -o orderer.example.com:7050 -C $CHANNELNAME -n $CHAINCODEID -c '{"Args":["invoke","a","b","10"]}' 2>&1  &> ./logs/myfirstchaincode.log
