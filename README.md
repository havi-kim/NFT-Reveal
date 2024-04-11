# NFT-Reveal

## Installation:

1. Clone derivative platform

```
$ git clone https://github.com/havi-kim/NFT-Reveal.git
$ cd NFT-Reveal
```

2. Install foundry

```
$ curl -L https://foundry.paradigm.xyz | bash
$ foundryup
```

3. Test

```
Local test
$ yarn test

Sepolia fork test // Integration tests are run on Sepolia fork. Not unit tests.
$ yarn test_sepolia
```

4. Deploy local
```
$ anvil
$ yarn deployNFT
```

5. Deploy Sepolia
```
$ yarn deployNFT_sepolia
```

6. Interact with contracts
```
You can type the command with forge or use yarn command. 
Please refer to each script for instructions.
```

## Structure:
- `src/`: Solidity feature contracts
  - `objects/`: Object libraries based on Diamond storage. It has responsibilities for storage and logics.
  - `utils/`: Utility libraries. It has responsibilities for utility functions.
  - `NFT`: NFT contract with multiple reveal options.
  - `RevealedNFT`: Revealed NFT contract.
- `scripts/`: Scripts for deploying and interacting with contracts
- `test/`: Tests for contracts


## Troubleshooting:
If you encounter evm version or solidity version issues, please refer to the following steps.
```
$ foundryup
$ cargo install svm-rs
$ svm install "0.8.24"
```