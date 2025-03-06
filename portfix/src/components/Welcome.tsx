import { useTheme } from "next-themes";

export function Welcome() {
    // 使用useTheme钩子来获取当前主题
    const { theme, systemTheme } = useTheme();
    // console.log(theme)

    return (
          <div className="w-full max-w-4xl p-8 relative">
              {/* 主要内容 */}
              <div className="relative space-y-8 text-center p-8">
                <div className="space-y-4">
                  {/* 根据主题切换logo */}
                  
                  <img 
                    src={
                      theme === 'system' 
                        ? (systemTheme === 'dark' ? "/logo-line-white.svg" : "/logo-line-dark.svg")
                        : (theme === 'dark' ? "/logo-line-white.svg" : "/logo-line-dark.svg")
                    } 
                    alt="Logo SVG" 
                    className="h-[120px] w-[120px] mx-auto" 
                  />
                  <h1 className="text-5xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-indigo-500 to-cyan-500 animate-gradient">
                    Welcome to PortfiX
                  </h1>
                  <p className="text-xl text-secondary-foreground max-w-2xl mx-auto leading-relaxed">
                    Your gateway to next-generation decentralized trading and portfolio management
                  </p>
                </div>
              <div className="relative group">
                {/* 外发光效果 */}
                <div className="absolute -inset-1 bg-gradient-to-r from-indigo-500 to-cyan-500 rounded-lg blur opacity-25 group-hover:opacity-75 transition duration-1000" />

                {/* 主内容区 */}
                <div className="relative p-8 bg-gradient-to-b from-card to-card backdrop-blur-sm rounded-lg leading-none">
                  <div className="space-y-6">
                    <div className="space-y-2">
                      <h2 className="text-2xl font-semibold text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 to-cyan-500 animate-gradient">
                        Connect Your Wallet
                      </h2>
                      <p className="text-muted-foreground">
                        Click the "Connect Wallet" button in the top right corner to begin your journey
                      </p>
                    </div>

                    {/* 特性列表 */}
                    <div className="grid grid-cols-2 gap-4 pt-4">
                      {[
                        'Secure Trading',
                        'Portfolio Analytics',
                        'Real-time Updates',
                        'Cross-chain Support'
                      ].map((feature) => (
                        <div
                          key={feature}
                          className="flex items-center space-x-3 p-3 rounded-lg
                                   bg-gradient-to-r from-muted to-muted
                                   border border-border
                                   hover:border-primary hover:bg-muted
                                   transition-all duration-300"
                        >
                          <div className="w-1.5 h-1.5 rounded-full bg-gradient-to-r from-indigo-400 to-cyan-400 animate-pulse" />
                          <span className="text-foreground">{feature}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        
    )}

    