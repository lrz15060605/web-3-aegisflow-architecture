# 🌐 AegisFlow — Web3 Gasless Intent Execution Demo

AegisFlow is a **full-stack Web3 dApp** that demonstrates how to execute **gasless transactions** using **EIP-712 signed intents**.  
Instead of submitting raw Ethereum transactions, users **sign an intent** in their wallet. A **relayer service** verifies and pays gas, then executes on behalf of the user via a **Smart Account** contract.

---

## 📊 Project Diagram

![AegisFlow Architecture](docs/architecture.png)

---

## 🧩 Components

- **Smart Contracts** (`packages/contracts`)  
  - `AegisAccount`: Minimal smart account verifying EIP-712 signed intents (owner, nonce, deadline).  
  - `DemoTarget`: Simple target contract to prove execution (`ping(uint256)`).

- **Frontend dApp** (`apps/web`)  
  - Next.js app with wallet connect.  
  - Lets the user sign intents and view transaction status.  

- **Relayer API** (`apps/web/src/app/api/submit-intent`)  
  - Next.js API route acting as a relayer.  
  - Sends transactions to `AegisAccount.exec()` using a funded relayer key.  

- **Solver Service** (`packages/solver`)  
  - Placeholder for a future standalone solver/relayer (we’ll migrate API logic here later).  

---

## 🚀 How it Works

1. User opens the dApp and connects wallet (MetaMask).  
2. User clicks **Sign & Execute Gasless** → wallet signs an **EIP-712 Intent**:
   ```solidity
   struct Intent {
     address target;
     uint256 value;
     bytes data;
     uint256 nonce;
     uint256 deadline;
   }
