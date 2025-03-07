import requests
import pandas as pd
import numpy as np
from typing import Dict, List
import talib  # 需要先安装: pip install talib-binary
import time

class MarketAnalyzer:
    def __init__(self):
        self.headers = {
            'accept': '*/*',
            'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'dnt': '1',
            'origin': 'https://app.merkle.trade',
            'priority': 'u=1, i',
            'referer': 'https://app.merkle.trade/',
            'sec-ch-ua': '"Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"',
            'sec-ch-ua-mobile': '?0',
            'sec-ch-ua-platform': '"macOS"',
            'sec-fetch-dest': 'empty',
            'sec-fetch-mode': 'cors',
            'sec-fetch-site': 'same-site',
            'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',
        }

    def fetch_kline_data(self, symbol: str, from_time: int, to_time: int, unit: int = 1800000) -> pd.DataFrame:
        """获取K线数据并转换为DataFrame格式"""
        params = {
            'from': from_time,
            'to': to_time,
            'unit': unit,
        }
        
        response = requests.get(
            f'https://api.merkle.trade/v1/chart/{symbol}', 
            params=params, 
            headers=self.headers
        )
        data = response.json()
        # print(data)
        # 将数据转换为DataFrame
        df = pd.DataFrame(data["items"])
        # print(df)
        df['timestamp'] = pd.to_datetime(df['ts'], unit='ms')
        return df

    def calculate_technical_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        """计算更多技术指标"""
        close_prices = df['close'].astype(float)
        high_prices = df['high'].astype(float)
        low_prices = df['low'].astype(float)
        
        # 移动平均线族
        ma5 = talib.SMA(close_prices, timeperiod=5)
        ma10 = talib.SMA(close_prices, timeperiod=10)
        ma20 = talib.SMA(close_prices, timeperiod=20)
        ma60 = talib.SMA(close_prices, timeperiod=60)
        
        # 指数移动平均线
        ema12 = talib.EMA(close_prices, timeperiod=12)
        ema26 = talib.EMA(close_prices, timeperiod=26)
        
        # RSI族
        rsi6 = talib.RSI(close_prices, timeperiod=6)
        rsi12 = talib.RSI(close_prices, timeperiod=12)
        rsi24 = talib.RSI(close_prices, timeperiod=24)
        
        # 布林带
        upper, middle, lower = talib.BBANDS(
            close_prices, timeperiod=20, 
            nbdevup=2, nbdevdn=2, matype=0
        )
        
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
        
        # 新增 SAR (抛物线指标)
        sar = talib.SAR(high_prices, low_prices, acceleration=0.02, maximum=0.2)
        
        # 新增 DMI (动向指标)
        plus_di = talib.PLUS_DI(high_prices, low_prices, close_prices, timeperiod=14)
        minus_di = talib.MINUS_DI(high_prices, low_prices, close_prices, timeperiod=14)
        adx = talib.ADX(high_prices, low_prices, close_prices, timeperiod=14)
        
        # ROC (变动率指标)
        roc = talib.ROC(close_prices, timeperiod=10)
        
        # 新增 TEMA (三重指数移动平均线)
        tema = talib.TEMA(close_prices, timeperiod=20)
        
        # 新增 MOM (动量指标)
        mom = talib.MOM(close_prices, timeperiod=10)
        
        # 其他现有指标
        atr = talib.ATR(high_prices, low_prices, close_prices, timeperiod=14)
        cci = talib.CCI(high_prices, low_prices, close_prices, timeperiod=14)
        trix = talib.TRIX(close_prices, timeperiod=30)
        willr = talib.WILLR(high_prices, low_prices, close_prices, timeperiod=14)

        return pd.DataFrame({
            # MA族
            'ma5': ma5,
            'ma10': ma10,
            'ma20': ma20,
            'ma60': ma60,
            'ema12': ema12,
            'ema26': ema26,
            # RSI族
            'rsi6': rsi6,
            'rsi12': rsi12,
            'rsi24': rsi24,
            # 布林带
            'bb_upper': upper,
            'bb_middle': middle,
            'bb_lower': lower,
            # MACD
            'macd': macd,
            'macd_signal': macd_signal,
            'macd_hist': macd_hist,
            # KDJ
            'k': k,
            'd': d,
            'j': j,
            # 其他指标
            'atr': atr,
            'cci': cci,
            'adx': adx,
            'trix': trix,
            'willr': willr,
            # 新增指标
            'sar': sar,
            'plus_di': plus_di,
            'minus_di': minus_di,
            'roc': roc,
            'tema': tema,
            'mom': mom
        })

    def analyze_trend(self, df: pd.DataFrame, indicators: pd.DataFrame) -> str:
        """扩展的趋势分析"""
        current_price = float(df['close'].iloc[-1])
        signals = []
        
        # MA分析
        ma5_current = indicators['ma5'].iloc[-1]
        ma10_current = indicators['ma10'].iloc[-1]
        ma20_current = indicators['ma20'].iloc[-1]
        ma60_current = indicators['ma60'].iloc[-1]
        
        if ma5_current > ma10_current > ma20_current:
            signals.append("短期、中期均线呈多头排列，上升趋势强劲")
        elif ma5_current < ma10_current < ma20_current:
            signals.append("短期、中期均线呈空头排列，下降趋势明显")
        
        # EMA分析
        ema12_current = indicators['ema12'].iloc[-1]
        ema26_current = indicators['ema26'].iloc[-1]
        if ema12_current > ema26_current:
            signals.append("EMA金叉形态，可能上涨")
        else:
            signals.append("EMA死叉形态，可能下跌")
            
        # RSI分析
        rsi6_current = indicators['rsi6'].iloc[-1]
        rsi12_current = indicators['rsi12'].iloc[-1]
        rsi24_current = indicators['rsi24'].iloc[-1]
        
        if rsi6_current > 80 and rsi12_current > 70:
            signals.append("RSI双重超买，注意回调风险")
        elif rsi6_current < 20 and rsi12_current < 30:
            signals.append("RSI双重超卖，可能存在反弹机会")
            
        # SAR分析
        sar_current = indicators['sar'].iloc[-1]
        if current_price > sar_current:
            signals.append("SAR显示多头趋势")
        else:
            signals.append("SAR显示空头趋势")
            
        # DMI分析
        plus_di_current = indicators['plus_di'].iloc[-1]
        minus_di_current = indicators['minus_di'].iloc[-1]
        if plus_di_current > minus_di_current:
            signals.append("DMI显示上升趋势")
        else:
            signals.append("DMI显示下降趋势")
            
        # ROC分析
        roc_current = indicators['roc'].iloc[-1]
        if roc_current > 0:
            signals.append(f"ROC为正({roc_current:.2f})，价格动能向上")
        else:
            signals.append(f"ROC为负({roc_current:.2f})，价格动能向下")
            
        # 动量分析
        mom_current = indicators['mom'].iloc[-1]
        if mom_current > 0:
            signals.append("动量指标为正，上涨动能持续")
        else:
            signals.append("动量指标为负，下跌动能持续")
            
        # Get current K and D values
        k_current = indicators['k'].iloc[-1]
        d_current = indicators['d'].iloc[-1]
        adx_current = indicators['adx'].iloc[-1]
        
        # 趋势强度评估
        trend_strength = 0
        if ma5_current > ma10_current > ma20_current: trend_strength += 1
        if rsi6_current > 50: trend_strength += 1
        if k_current > d_current: trend_strength += 1
        if indicators['macd_hist'].iloc[-1] > 0: trend_strength += 1
        if adx_current > 25: trend_strength += 1
        
        # # 综合评估
        # signals.append("\n总体趋势评估:")
        # if trend_strength >= 4:
        #     signals.append("强烈看涨信号")
        # elif trend_strength >= 3:
        #     signals.append("偏向看涨")
        # elif trend_strength <= 1:
        #     signals.append("强烈看跌信号")
        # else:
        #     signals.append("偏向看跌")
            
        # # 波动性分析
        # atr_current = indicators['atr'].iloc[-1]
        # atr_avg = indicators['atr'].mean()
        # if atr_current > atr_avg * 1.5:
        #     signals.append("\n警告: 当前市场波动性较大，建议谨慎操作")
            
        return "\n".join(signals)

    def analyze_market(self,symbol: str):
        # 获取最近24小时的数据
        current_time = int(time.time() * 1000)
        from_time = current_time - (2 * 24 * 60 * 60 * 1000)  # 48小时前
        
        # 获取数据
        df = self.fetch_kline_data(symbol, from_time, current_time)
        
        # 计算指标
        indicators = self.calculate_technical_indicators(df)
        
        # Format float values to 2 decimal places
        formatted_indicators = {k: round(float(v), 2) if pd.notna(v) else v 
                            for k, v in indicators.iloc[-1].to_dict().items()}
        # 分析走势
        analysis = self.analyze_trend(df, indicators)
        
        formatted_indicators["summary"]="。".join(analysis.split("\n"))
        return formatted_indicators

def get_market_indicators():
    total_indicators = []
    for symbol in ["BTC_USD", "ETH_USD", "APT_USD", "SUI_USD","TRUMP_USD"]:
        formatted_indicators = MarketAnalyzer().analyze_market(symbol)
        formatted_indicators["symbol"] = symbol
        total_indicators.append(formatted_indicators)
    return total_indicators

if __name__ == "__main__":
    import time
    total_indicators = get_market_indicators()
    print(total_indicators)

