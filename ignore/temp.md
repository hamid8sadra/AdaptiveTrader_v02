
input enum position_type = {BUY,SELL,BOTH}
input int openCondition_price_upperlimit = [-1,0,1]
input int openCondition_price_mode = [-1,0,1]
input int openCondition_price_lowerlimit = [-1,0,1]
input int closeCondition_price_upperlimit = [-1,0,1]
input int closeCondition_price_mode = [-1,0,1]
input int closeCondition_price_lowerlimit = [-1,0,1]

bool cond_price_upperlimit = last_1m_close > indicator_upperlimit_buffer

score = 1
config_id = 34525
profit_factor = 5.4
max_drawdown = 12%
input enum position_type = BUY
input int openCondition_price_upperlimit = 1
input int openCondition_price_mode = 0
input int openCondition_price_lowerlimit = -1
input int closeCondition_price_upperlimit = 0
input int closeCondition_price_mode = -1
input int closeCondition_price_lowerlimit = 0

input enum MODE{NORMAL,BACKTEST,OPTIMIZE}