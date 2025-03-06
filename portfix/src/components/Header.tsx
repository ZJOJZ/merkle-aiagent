// import ui components
import { ModeToggle } from '@/components/theme-toggle';

import { WalletSelector } from "./WalletSelector";
// import Logo from "@/assets/logo.svg"
// import Logo from "@/components/Logo.png";
// import Logo from "@/components/logo.svg"
export function Header({ connected }: { connected: boolean }) {
  return (
    <div className="flex items-center justify-between px-4 py-2 max-w-screen-xl mx-auto w-full flex-wrap">
      <div className="flex items-center space-x-2">

        {connected && (
          <div className="flex flex-row items-center space-x-2">
            <img
              src="/logo-line-white.svg"
              alt="Logo SVG"
              className="h-[70px] w-[70px]"  // 或者根据实际文字大小调整
            />
            <h1 className="display text-[32px]">PortfiX</h1>
          </div>
        )

        }

      </div>

      <div className="flex gap-2 items-center flex-wrap">
        <div className="flex items-center space-x-2">
          <ModeToggle />
          <WalletSelector />
        </div>
      </div>
    </div >
  );
}
