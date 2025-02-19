"use client"
// import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { useAutoConnect } from "@/components/AutoConnectProvider";
import { Network } from "@aptos-labs/ts-sdk";
import { ChatWindow } from "@/components/ChatWindow"
import { WalletSelector as ShadcnWalletSelector } from "@/components/WalletSelector";
import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
// Import any additional wallet plugins. Ex.
// import { OKXWallet } from "@okwallet/aptos-wallet-adapter";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { ThemeToggle } from "@/components/ThemeToggle";
// import { WalletConnection } from "@/components/WalletConnection";
import { isMainnet } from "@/utils";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { AlertCircle } from "lucide-react";
import { TransactionParameters } from "@/components/transactionFlows/TransactionParameters";
import { SingleSigner } from "@/components/transactionFlows/SingleSigner";
import { Sponsor } from "@/components/transactionFlows/Sponsor";
import { MultiAgent } from "@/components/transactionFlows/MultiAgent";
// const { account, connected, wallet, changeNetwork } = useWallet();
export default function Home() {
	const { account, connected, network, wallet, changeNetwork } = useWallet();
	const InfoCard = (
		<div className="p-4 md:p-8 rounded bg-[#25252d] w-full max-h-[85%] overflow-hidden">
			<div className="flex justify-between gap-6 pb-10">
				<div className="flex flex-col gap-2 md:gap-3">
					<h1 className="text-xl sm:text-3xl font-semibold tracking-tight">
						Aptos Wallet Adapter Tester
						{network?.name ? ` — ${network.name}` : ""}
					</h1>
					<a
						href="https://github.com/aptos-labs/aptos-wallet-adapter/tree/main/apps/nextjs-example"
						target="_blank"
						rel="noreferrer"
						className="text-sm text-muted-foreground underline underline-offset-2 font-medium leading-none"
					>
						Demo App Source Code
					</a>
				</div>
				<ThemeToggle />
			</div>
			<WalletSelection />
			{connected
				// && (
				// 	<WalletConnection
				// 		account={account}
				// 		network={network}
				// 		wallet={wallet}
				// 		changeNetwork={changeNetwork}
				// 	/>
				// )
			}
			{connected
				&& isMainnet(connected, network?.name) && (
					<Alert variant="destructive">
						<AlertCircle className="h-4 w-4" />
						<AlertTitle>Warning</AlertTitle>
						<AlertDescription>
							The transactions flows below will not work on the Mainnet network.
						</AlertDescription>
					</Alert>
				)
			}
			{connected
				&& (
					<>
						<TransactionParameters />
						<SingleSigner />
						<Sponsor />
						<MultiAgent />
					</>
				)
			}
			<h1 className="text-3xl md:text-4xl mb-4">MoveAgentKit + LangChain.js 🦜🔗 + Next.js</h1>
			<ul>
				<li className="text-l">
					🤝
					<span className="ml-2">
						This template showcases a simple agent chatbot using{" "}
						<a href="https://https://www.moveagentkit.xyz/">MoveAgentKit</a>
						{", "}
						<a href="https://js.langchain.com/" target="_blank">
							LangChain.js
						</a>{" "}
						and the Vercel{" "}
						<a href="https://sdk.vercel.ai/docs" target="_blank">
							AI SDK
						</a>{" "}
						in a{" "}
						<a href="https://nextjs.org/" target="_blank">
							Next.js
						</a>{" "}
						project.
					</span>
				</li>
				<li className="hidden text-l md:block">
					💻
					<span className="ml-2">
						You can find the prompt and model logic for this use-case in <code>app/api/chat/route.ts</code>.
					</span>
				</li>
				<li className="hidden text-l md:block">
					🎨
					<span className="ml-2">
						The main frontend logic is found in <code>app/page.tsx</code>.
					</span>
				</li>
				<li className="text-l">
					🐙
					<span className="ml-2">
						This template is open source - you can see the source code and deploy your own version{" "}
						<a href="#" target="_blank">
							from the GitHub repo (coming soon)
						</a>
						!
					</span>
				</li>
				<li className="text-l">
					👇
					<span className="ml-2">
						Try asking e.g. <code>What is my wallet address?</code> below!
					</span>
				</li>
			</ul>
		</div>
	)
	return (
		<ChatWindow
			endpoint="api/hello"
			emoji="🤖"
			titleText="Aptos agent"
			placeholder="I'm your friendly Aptos agent! Ask me anything..."
			emptyStateComponent={InfoCard}
		></ChatWindow>
	)
}


function WalletSelection() {
	const { autoConnect, setAutoConnect } = useAutoConnect();

	return (
		<Card className="absolute top-4 right-4 w-[200px] h-[100px]">
			<CardContent className="pt-4">
				<div className="flex flex-col items-center gap-4">
					<ShadcnWalletSelector />
					<label className="flex items-center gap-2 cursor-pointer text-sm">
						<Switch
							id="auto-connect-switch"
							checked={autoConnect}
							onCheckedChange={setAutoConnect}
						/>
						<Label htmlFor="auto-connect-switch">
							Auto reconnect
						</Label>
					</label>
				</div>
			</CardContent>
		</Card>
		// ... existing code ...
	);
}

