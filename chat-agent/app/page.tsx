import { ChatWindow } from "@/components/ChatWindow"
import Dashboard from "@/components/Dashboard"
import { Trade } from "@/components/Trade"
// import { ChatWindow } from "@/components/ChatWindow"

export default function Home() {
	const InfoCard = (
		<div className="p-4 md:p-8 rounded bg-[#25252d] w-full max-h-[85%] overflow-hidden">
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
		<div>
			<div className="flex flex-row gap-3">
				<Dashboard />
				<Trade />
			</div>
			<ChatWindow
				endpoint="api/hello"
				emoji="🤖"
				titleText="Aptos agent"
				placeholder="I'm your friendly Aptos agent! Ask me anything..."
				emptyStateComponent={InfoCard}
			></ChatWindow>
		</div>

	)
}
