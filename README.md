# ERC2006

## Overview

- <https://hardhat.org/>

- <https://www.alchemy.com/>

- <https://bscscan.com/>

## Installation

```bash
npm init
npm install --save-dev hardhat
npm install @openzeppelin/contracts
npx hardhat
```

## create secrets.json

> copy secrets-copy.json secrets.json

```json
{
  "mnemonic": "***",
  "alchemyApiKey": "***",
  "bscscanApiKey": "***"
}
```

## Quick Start

```bash
npx hardhat accounts
npx hardhat compile
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help

```
