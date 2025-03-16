import requests
import pandas as pd
import talib
import time
from typing import Dict, List

class Joule_Finance_MarketAnalyzer:
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

class Binance_MarketAnalyzer:
    def __init__(self):
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36'
        }

    def fetch_kline_data(self, symbol: str, interval: str = '30m', limit: int = 96) -> pd.DataFrame:
        """获取币安K线数据"""
        url = f'https://api.binance.com/api/v3/klines'
        params = {
            'symbol': f'{symbol}USDT',
            'interval': interval,
            'limit': limit
        }
        
        response = requests.get(url, params=params, headers=self.headers)
        data = response.json()
        
        df = pd.DataFrame(data, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume',
                                       'close_time', 'quote_volume', 'trades', 'taker_buy_base',
                                       'taker_buy_quote', 'ignore'])
        
        df['timestamp'] = pd.to_datetime(df['timestamp'], unit='ms')
        for col in ['open', 'high', 'low', 'close', 'volume']:
            df[col] = df[col].astype(float)
        return df

    def calculate_technical_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        """计算技术指标"""
        close_prices = df['close']
        high_prices = df['high']
        low_prices = df['low']
        
        # 移动平均线族
        ma5 = talib.SMA(close_prices, timeperiod=5)
        ma10 = talib.SMA(close_prices, timeperiod=10)
        ma20 = talib.SMA(close_prices, timeperiod=20)
        ma60 = talib.SMA(close_prices, timeperiod=60)
        
        # RSI族
        rsi6 = talib.RSI(close_prices, timeperiod=6)
        rsi12 = talib.RSI(close_prices, timeperiod=12)
        rsi24 = talib.RSI(close_prices, timeperiod=24)
        
        # MACD
        macd, macd_signal, macd_hist = talib.MACD(
            close_prices, 
            fastperiod=12, 
            slowperiod=26, 
            signalperiod=9
        )
        
        # KDJ
        k, d = talib.STOCH(
            high_prices, low_prices, close_prices,
            fastk_period=9, slowk_period=3, slowk_matype=0,
            slowd_period=3, slowd_matype=0
        )
        j = 3 * k - 2 * d

        return pd.DataFrame({
            'ma5': ma5,
            'ma10': ma10,
            'ma20': ma20,
            'ma60': ma60,
            'rsi6': rsi6,
            'rsi12': rsi12,
            'rsi24': rsi24,
            'macd': macd,
            'macd_signal': macd_signal,
            'macd_hist': macd_hist,
            'k': k,
            'd': d,
            'j': j,
        })

    def analyze_trend(self, df: pd.DataFrame, indicators: pd.DataFrame) -> str:
        """分析趋势"""
        current_price = float(df['close'].iloc[-1])
        signals = []
        
        # MA分析
        ma5_current = indicators['ma5'].iloc[-1]
        ma10_current = indicators['ma10'].iloc[-1]
        ma20_current = indicators['ma20'].iloc[-1]
        
        if ma5_current > ma10_current > ma20_current:
            signals.append("短期、中期均线呈多头排列，上升趋势强劲")
        elif ma5_current < ma10_current < ma20_current:
            signals.append("短期、中期均线呈空头排列，下降趋势明显")
        
        # RSI分析
        rsi6_current = indicators['rsi6'].iloc[-1]
        rsi12_current = indicators['rsi12'].iloc[-1]
        
        if rsi6_current > 80 and rsi12_current > 70:
            signals.append("RSI双重超买，注意回调风险")
        elif rsi6_current < 20 and rsi12_current < 30:
            signals.append("RSI双重超卖，可能存在反弹机会")
        
        # KDJ分析
        k_current = indicators['k'].iloc[-1]
        d_current = indicators['d'].iloc[-1]
        
        if k_current > d_current:
            signals.append("KDJ金叉形态，可能上涨")
        else:
            signals.append("KDJ死叉形态，可能下跌")
            
        return "\n".join(signals)

    def analyze_market(self, symbol: str):
        """分析市场"""
        df = self.fetch_kline_data(symbol)
        indicators = self.calculate_technical_indicators(df)
        
        formatted_indicators = {k: round(float(v), 2) if pd.notna(v) else v 
                              for k, v in indicators.iloc[-1].to_dict().items()}
        analysis = self.analyze_trend(df, indicators)
        
        formatted_indicators["summary"] = "。".join(analysis.split("\n"))
        formatted_indicators["symbol"] = symbol
        formatted_indicators["current_price"] = round(float(df['close'].iloc[-1]), 2)
        return formatted_indicators

def get_binance_market_analysis():
    analyzer = Binance_MarketAnalyzer()
    total_indicators = []
    for symbol in ["BTC", "ETH", "APT"]:
        try:
            indicators = analyzer.analyze_market(symbol)
            total_indicators.append(indicators)
        except Exception as e:
            print(f"Error analyzing {symbol}: {str(e)}")
    return total_indicators

def get_joule_finance_market_data_analysis():
    analyzer = Joule_Finance_MarketAnalyzer()
    market_data = analyzer.fetch_market_data()
    analysis_results = get_binance_market_analysis()
    
    # Create a mapping dictionary for symbol matching
    symbol_mapping = {
        'WBTC': 'BTC',
        'WETH': 'ETH',
        'APT': 'APT'
    }
    
    # Technical indicators to copy from Binance analysis
    technical_indicators = [
        'ma5', 'ma10', 'ma20', 'ma60',
        'rsi6', 'rsi12', 'rsi24',
        'macd', 'macd_signal', 'macd_hist',
        'k', 'd', 'j'
    ]
    
    # Convert analysis_results to a dictionary for easier lookup
    analysis_dict = {result['symbol']: result for result in analysis_results}
    
    # Add Binance analysis data to market_data where symbols match
    for idx, row in market_data.iterrows():
        symbol = row['symbol']
        # Check if the symbol exists in our mapping
        mapped_symbol = next((binance_sym for joule_sym, binance_sym in symbol_mapping.items() 
                            if joule_sym == symbol), None)
        
        if mapped_symbol and mapped_symbol in analysis_dict:
            binance_data = analysis_dict[mapped_symbol]
            # Add binance price and technical analysis summary
            market_data.loc[idx, 'binance_price'] = binance_data['current_price']
            market_data.loc[idx, 'technical_analysis'] = binance_data['summary']
            
            # Add all technical indicators
            for indicator in technical_indicators:
                if indicator in binance_data:
                    market_data.loc[idx, f'{indicator}'] = binance_data[indicator]
            
    return market_data

if __name__ == "__main__":
    analysis_results = get_joule_finance_market_data_analysis()
    print(analysis_results.set_index('symbol').T.to_dict())