// import ui components
import { ModeToggle } from '@/components/theme-toggle';
import { useTheme } from "next-themes";

// import Aptos Wallet Selector
import { WalletSelector } from "./WalletSelector";


export function Header({ connected }: { connected: boolean }) {
  // 使用useTheme钩子来获取当前主题
  const { theme, systemTheme } = useTheme();
  
  return (
    <div className="flex items-center justify-between px-2 py-8 max-w-screen-xl mx-auto w-full flex-wrap h-[100px]">
      <div className="flex items-center space-x-2">

        {connected && (
          <div>
            <img 
                    src={
                      theme === 'system' 
                        ? (systemTheme === 'dark' ? "/logo-line-white.svg" : "/logo-line-dark.svg")
                        : (theme === 'dark' ? "/logo-line-white.svg" : "/logo-line-dark.svg")
                    } 
                    alt="Logo SVG" 
                    className="h-[70px] w-[70px] mx-auto" 
                  />
            {/* <h1 className="display text-[32px]">PortfiX</h1> */}
          </div>
        )

        }

      </div>

      <div className="flex items-center flex-wrap">
        <div className="flex items-center space-x-4">
          <ModeToggle />
          <WalletSelector />
        </div>
      </div>
    </div >
  );
}
