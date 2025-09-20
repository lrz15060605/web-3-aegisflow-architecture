import { NextRequest, NextResponse } from "next/server";
import { createWalletClient, http, parseAbi, encodeFunctionData } from "viem";
import { privateKeyToAccount } from "viem/accounts";

const rpcUrl = process.env.NEXT_PUBLIC_RPC_URL!;
const relayer = privateKeyToAccount(process.env.RELAYER_KEY as `0x${string}`);

const aegisAbi = parseAbi([
  "function exec((address target,uint256 value,bytes data,uint256 nonce,uint256 deadline) intent, bytes signature) payable returns (bytes)"
]);

export async function POST(req: NextRequest) {
  const body = await req.json();
  const { accountAddress, intent, signature } = body as {
    accountAddress: `0x${string}`;
    intent: {
      target: `0x${string}`;
      value: bigint;
      data: `0x${string}`;
      nonce: bigint;
      deadline: bigint;
    };
    signature: `0x${string}`;
  };

  const client = createWalletClient({ account: relayer, transport: http(rpcUrl) });

  const data = encodeFunctionData({
    abi: aegisAbi,
    functionName: "exec",
    args: [intent, signature],
  });

  const hash = await client.sendTransaction({
    to: accountAddress,
    data,
    value: 0n,
  });

  return NextResponse.json({ txHash: hash });
}
