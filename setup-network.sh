#!/bin/bash

# Network Setup Script for 4-Node Hyperledger Fabric Network
# Run this script from the hyperledger directory

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Hyperledger Fabric 4-Node Network Setup ===${NC}"
echo "Node Configuration:"
echo "- Orderer:    172.70.105.199 (this machine)"
echo "- Org1 Peer:  172.70.102.183"
echo "- Org2 Peer:  172.70.96.96"
echo "- Org3 Peer:  172.70.101.19"
echo ""

# Function to print section headers
print_section() {
    echo -e "${YELLOW}=== $1 ===${NC}"
}

# Clean up existing artifacts
print_section "Cleaning up existing artifacts"
if [ -d "crypto-config/crypto-config" ]; then
    echo "Removing existing crypto-config..."
    rm -rf crypto-config/crypto-config/*
fi

if [ -d "crypto-config/channel-artifacts" ]; then
    echo "Removing existing channel artifacts..."
    rm -rf crypto-config/channel-artifacts/*
fi

# Generate crypto materials
print_section "Generating Crypto Materials"
cryptogen generate --config=./crypto-config.yaml
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Crypto materials generated successfully${NC}"
else
    echo -e "${RED}✗ Failed to generate crypto materials${NC}"
    exit 1
fi

# Create channel artifacts directory
mkdir -p channel-artifacts

# Generate Genesis Block
print_section "Generating Genesis Block"
configtxgen -profile FourOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Genesis block generated successfully${NC}"
else
    echo -e "${RED}✗ Failed to generate genesis block${NC}"
    exit 1
fi

# Generate Channel Configuration Transaction
print_section "Generating Channel Configuration"
export CHANNEL_NAME=mychannel
configtxgen -profile FourOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Channel configuration generated successfully${NC}"
else
    echo -e "${RED}✗ Failed to generate channel configuration${NC}"
    exit 1
fi

# Generate Anchor Peer Updates
print_section "Generating Anchor Peer Updates"
configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Anchor peer updates generated successfully${NC}"
else
    echo -e "${RED}✗ Failed to generate anchor peer updates${NC}"
    exit 1
fi

# Copy artifacts to main directory
# cp -r crypto-config/channel-artifacts ./
# cp -r crypto-config/crypto-config ./

print_section "Network Setup Complete"
echo -e "${GREEN}✓ All network artifacts generated successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Copy the entire hyperledger directory to each peer machine"
echo "2. On each machine, create the docker network:"
echo "   ${YELLOW}docker network create fabric_test${NC}"
echo ""
echo "3. Start the services in this order:"
echo "   a) On orderer (172.70.105.199): ${YELLOW}docker-compose -f docker-compose-orderer.yaml up -d${NC}"
echo "   b) On org1 (172.70.102.183):   ${YELLOW}docker-compose -f docker-compose-org1.yaml up -d${NC}"
echo "   c) On org2 (172.70.96.96):     ${YELLOW}docker-compose -f docker-compose-org2.yaml up -d${NC}"
echo "   d) On org3 (172.70.101.19):    ${YELLOW}docker-compose -f docker-compose-org3.yaml up -d${NC}"
echo ""
echo "4. Create and join channel (run from orderer machine):"
echo "   ${YELLOW}./scripts/channel-setup.sh${NC}"
