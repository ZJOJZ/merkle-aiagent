import requests
import pandas as pd

class MarketAnalyzer:
    def __init__(self):
        self.headers = {
            'accept': '*/*',
            'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'dnt': '1',
            'origin': 'https://app.joule.finance',
            'priority': 'u=1, i',
            'referer': 'https://app.joule.finance/',
            'sec-ch-ua': '"Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"',
            'sec-ch-ua-mobile': '?0',
            'sec-ch-ua-platform': '"macOS"',
            'sec-fetch-dest': 'empty',
            'sec-fetch-mode': 'cors',
            'sec-fetch-site': 'same-site',
            'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',
        }


    def fetch_market_data(self) -> pd.DataFrame:
        """获取K线数据并转换为DataFrame格式"""
        response = requests.get('https://price-api.joule.finance/api/market', headers=self.headers)
        data = response.json()
        df = pd.json_normalize(data["data"])
        df2=df[['ltv', 'marketSize', 'totalBorrowed', 
       'asset.displayName','asset.liquidationFactor','priceInfo.price']].copy()
        df2["borrowApy"]=df["borrowApy"] + df["extraAPY.borrowAPY"].astype(float)
        df2["depositApy"] = df["depositApy"] + df["extraAPY.depositAPY"].astype(float)
        df2["ltv"]=df2["ltv"].astype(float)/10000
        df2.rename(columns={'asset.displayName':'symbol',
                            'asset.liquidationFactor':'liquidationFactor',
                            'priceInfo.price':'price'}, inplace=True)
        return df2
    
if __name__ == "__main__":
    print(MarketAnalyzer().fetch_market_data())