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
#
# This command need only to be call when you have a brand new fabric infrastructure
# 
peer channel create -o orderer.example.com:7050 -c $CHANNELNAME -f ./channel-artifacts/channel.tx   

echo
echo "-- Join channel --"
echo
#
# This command need only to be call when you have a brand new fabric infrastructure
# 
peer channel join -b $CHANNELNAME.block 

echo
echo "-- Installing chaincode --"
echo
#
# Use this command only when you want to install a new chaincode
# If you made changes to you chaincode, you will need to change the
# version of the chaincode by changing the value of the -v field. Say from
# -v 1.0 to -v 2.0.
peer chaincode install -n $CHAINCODEID -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/myfirstchaincode

echo
echo "-- Instantiating chaincode --"
echo
#
# Once you have successfully install a new chaincode you need to instantiate it. Remember to change the 
# value of the -v field to match the one shown above.
# Note: These are arguments currently has no effect until you have implemented something to consume it.
peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNELNAME -n $CHAINCODEID -v 1.0 -c '{"Args":["methodName","a","100","b","200"]}' -P "OR ('Org1MSP.member')" 

# Ensure that instantiation is complete before invoke operations
sleep 10

echo
echo "-- Invoking chaincode --"
echo
#
# Use this command to run the Invoke method in the chaincode
# Note: These are arguments currently has no effect until you have implemented something to consume it.
peer chaincode invoke -o orderer.example.com:7050 -C $CHANNELNAME -n $CHAINCODEID -c '{"Args":["methodName","a","b","10"]}'

echo
echo "========================================================="
echo "              END - myfirstchaincode                     "
echo "========================================================="