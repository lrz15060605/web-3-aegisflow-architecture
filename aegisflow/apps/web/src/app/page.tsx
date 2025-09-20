"use client";
import { useEffect, useState } from "react";
import { createPublicClient, createWalletClient, custom, http, encodeFunctionData, parseAbi } from "viem";

const rpcUrl = process.env.NEXT_PUBLIC_RPC_URL!;
const AEGIS = process.env.NEXT_PUBLIC_AEGIS_ACCOUNT as `0x${string}`;
const TARGET = process.env.NEXT_PUBLIC_DEMO_TARGET as `0x${string}`;

const demoAbi = parseAbi(["function ping(uint256 x) payable returns (uint256)"]);

export default function Home() {
  const [account, setAccount] = useState<`0x${string}` | null>(null);
  const [tx, setTx] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      if (!window.ethereum) return;
      const client = createWalletClient({ transport: custom(window.ethereum) });
      const [addr] = await client.requestAddresses();
      setAccount(addr as `0x${string}`);
    })();
  }, []);

  async function run() {
    setErr(null);
    try {
      if (!window.ethereum || !account) throw new Error("Connect wallet first");
      const wallet = createWalletClient({ account, transport: custom(window.ethereum) });
      const publicClient = createPublicClient({ transport: http(rpcUrl) });

      const data = encodeFunctionData({ abi: demoAbi, functionName: "ping", args: [42n] });

      const nonce = 0n; // first run
      const deadline = BigInt(Math.floor(Date.now() / 1000) + 600);

      const domain = {
        name: "AegisAccount",
        version: "1",
        chainId: await publicClient.getChainId(),
        verifyingContract: AEGIS,
      } as const;

      const types = {
        Intent: [
          { name: "target", type: "address" },
          { name: "value", type: "uint256" },
          { name: "data", type: "bytes" },
          { name: "nonce", type: "uint256" },
          { name: "deadline", type: "uint256" },
        ],
      } as const;

      const intent = {
        target: TARGET,
        value: 0n,
        data: data as `0x${string}`,
        nonce,
        deadline,
      } as const;

      const signature = await wallet.signTypedData({ domain, types, primaryType: "Intent", message: intent });

      const res = await fetch("/api/submit-intent", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ accountAddress: AEGIS, intent, signature }),
      });
      const json = await res.json();
      setTx(json.txHash);
    } catch (e:any) {
      setErr(e.message || String(e));
    }
  }

  return (
    <main style={{ maxWidth: 760, margin: "40px auto", fontFamily: "ui-sans-serif" }}>
      <h1 style={{ fontSize: 28, fontWeight: 700 }}>AegisFlow — Gasless Intent Demo</h1>
      <p>Connected wallet: {account ?? "(not connected)"}</p>
      <ol>
        <li>Run <code>anvil</code> in another terminal.</li>
        <li>Deploy contracts and set env vars.</li>
      </ol>
      <button onClick={run} style={{ padding: 12, borderRadius: 12, border: "1px solid #ddd" }}>Sign & Execute Gasless</button>
      {tx && <p style={{ marginTop: 12 }}>TX sent: <code>{tx}</code></p>}
      {err && <p style={{ color: "crimson" }}>Error: {err}</p>}
    </main>
  );
}
