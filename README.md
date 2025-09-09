# Hyperledger Fabric 4-Node Network

This repository contains the configuration for a 4-node Hyperledger Fabric network distributed across multiple machines.

## Network Architecture

- **Orderer Node**: 172.70.105.199/20 (Machine 1)
- **Org1 Peer**: 172.70.102.183/20 (Machine 2)  
- **Org2 Peer**: 172.70.96.96 (Machine 3)
- **Org3 Peer**: 172.70.101.19 (Machine 4)

## Prerequisites

On all machines:
- Docker and Docker Compose installed
- Hyperledger Fabric binaries and images (fabric-tools, fabric-peer, fabric-orderer)
- Network connectivity between all machines on specified ports

## File Structure

```
hyperledger/
├── docker-compose-orderer.yaml    # Orderer configuration (Machine 1)
├── docker-compose-org1.yaml       # Org1 peer configuration (Machine 2)
├── docker-compose-org2.yaml       # Org2 peer configuration (Machine 3)
├── docker-compose-org3.yaml       # Org3 peer configuration (Machine 4)
├── crypto-config/
│   ├── configtx.yaml              # Network configuration
│   └── crypto-config.yaml         # Crypto material configuration
├── chaincode/                     # Smart contracts
├── scripts/
│   └── channel-setup.sh           # Channel creation script
└── setup-network.sh               # Network initialization script
```

## Setup Instructions

### 1. Initial Setup (Run on Orderer Machine - 172.70.105.199)

```bash
# Make scripts executable
chmod +x setup-network.sh
chmod +x scripts/channel-setup.sh

# Generate network artifacts
./setup-network.sh
```

This will generate:
- Crypto materials for all organizations
- Genesis block
- Channel configuration
- Anchor peer updates

### 2. Distribute Files

Copy the entire `hyperledger` directory to all peer machines:

```bash
# From orderer machine to each peer machine
scp -r hyperledger user@172.70.102.183:~/
scp -r hyperledger user@172.70.96.96:~/
scp -r hyperledger user@172.70.101.19:~/
```

### 3. Create Docker Network (All Machines)

On each machine, create the required Docker network:

```bash
docker network create fabric_test
```

### 4. Start Services

Start the services in the following order:

#### Machine 1 (Orderer - 172.70.105.199):
```bash
cd hyperledger
docker-compose -f docker-compose-orderer.yaml up -d
```

#### Machine 2 (Org1 - 172.70.102.183):
```bash
cd hyperledger  
docker-compose -f docker-compose-org1.yaml up -d
```

#### Machine 3 (Org2 - 172.70.96.96):
```bash
cd hyperledger
docker-compose -f docker-compose-org2.yaml up -d
```

#### Machine 4 (Org3 - 172.70.101.19):
```bash
cd hyperledger
docker-compose -f docker-compose-org3.yaml up -d
```

### 5. Create and Join Channel (Run from Orderer Machine)

```bash
./scripts/channel-setup.sh
```

This will:
- Create the channel `mychannel`
- Join all peers to the channel
- Update anchor peer configurations

## Verification

Check if all containers are running:

```bash
docker ps
```

Check peer channel membership:

```bash
# From any peer CLI container
docker exec cli-org1 peer channel list
```

## Ports Used

- **7050**: Orderer service port
- **7051**: Peer service port  
- **17050**: Orderer operations port
- **17051**: Peer operations port

## Troubleshooting

1. **Network connectivity issues**: Ensure all machines can reach each other on the specified ports
2. **Container startup failures**: Check Docker logs with `docker logs <container_name>`
3. **Channel creation failures**: Verify orderer is running and accessible from CLI container

## Next Steps

After successful setup, you can:
1. Deploy chaincode to the network
2. Invoke transactions
3. Query the ledger

## Configuration Updates

If you need to modify IP addresses or add more nodes:
1. Update the `configtx.yaml` file
2. Update the respective `docker-compose-*.yaml` files
3. Regenerate network artifacts with `./setup-network.sh`
