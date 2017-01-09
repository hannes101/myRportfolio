# Use the FinancialInstrument package to manage information about tradable
# instruments
library(FinancialInstrument)
library(blotter)
library(quantmod)
library(PerformanceAnalytics)

library(data.table)
# Read in the trade data
myExamplePortfolio <- read.csv(file="ExampleTradeHistory.csv", sep=",",header = TRUE)

myExamplePortfolio$BuyDate <-   as.Date(myExamplePortfolio$BuyDate,"%d/%m/%Y")
dt.myExamplePortfolio <- as.data.table(myExamplePortfolio)
setcolorder(dt.myExamplePortfolio, c( "BuyDate", "ISIN" , "YahooSymbol", "Name", "Volume", "Price", "Fees"))

# Define currency and stocks
rm(list=ls(envir=.blotter),envir=.blotter)
currency("EUR")
symbols <- as.vector(dt.myExamplePortfolio[, unique(YahooSymbol)])

for(symbol in symbols){ # establish tradable instruments
  stock(symbol, currency="EUR", multiplier=1)
}

# Download price data

init.date = dt.myExamplePortfolio[,min(BuyDate)]
current.date <- Sys.Date()

getSymbols(symbols, from=init.date, to=Sys.Date(), src='yahoo',
           index.class=c("POSIXt","POSIXct"), auto.assign = TRUE, adjust = TRUE)


# Initialize a portfolio object 'myPortfolio'
print('Creating portfolio \"p\"...')
initPortf('myPortfolio', symbols=symbols, currency="EUR")
initAcct("myAccount",portfolios=c("myPortfolio"), init.date = init.date)

## Trades must be made in date order.
# Add trades to the portfolio
for(symbol in symbols){
  my.xts.Portfolio <- as.xts.data.table(dt.myExamplePortfolio[YahooSymbol== symbol,.(BuyDate, Volume, Price, Fees)])
  names(my.xts.Portfolio) <- c("TxnQty", "TxnPrice", "TxnFees")
  addTxns("myPortfolio", Symbol = symbol, TxnData = my.xts.Portfolio)
}

updatePortf(Portfolio="myPortfolio", Symbols = symbols, Dates = paste(init.date,current.date,sep="::"))
updateAcct(name="myAccount",Dates='2013-07-15::2017-09')
updateEndEq(Account="myAccount", Dates=current.date)

# Examine the contents of the portfolio
## Here is the transaction record
for(symbol in symbols){
  print(getTxns(Portfolio="myPortfolio", Symbol=symbol, Dates = paste(init.date,current.date,sep="::")))
}

# Alternatively, you can copy the objects into the local workspace
myPortfolio = getPortfolio("myPortfolio") # make a local copy of the portfolio object
myAccount = getAccount("myAccount") # make a local copy of the account object

## Here are the resulting positions
sapply(symbols, function(x) getPos(Portfolio="myPortfolio", Symbol=x, Date=Sys.Date()))


chart.Posn(Portfolio="myPortfolio", Symbol="DBK.DE", Dates=paste(init.date,current.date,sep="::"))

# Plot all positions

for(i in symbols){
  chart.Posn(Portfolio="myPortfolio", Symbol=i, Dates=paste(init.date,current.date,sep="::"),TA='add_SMA(n=10,col=4, on=1)')
  readline(prompt="Press [enter] to continue")
}

# Join resulting positions into a data.table and calculate the 
# difference to current prices

dt.PortfolioPosition <- data.table(YahooSymbol = rownames(t(sapply(symbols, function(x) getPos(Portfolio="myPortfolio"
                                                                                               , Symbol=x
                                                                                               , Date=Sys.Date()
))))
,
t(sapply(symbols, function(x) getPos(Portfolio="myPortfolio"
                                     , Symbol=x
                                     , Date=Sys.Date()
)))
)


dt.PortfolioPosition[, `:=`( Initial.Value = Pos.Qty * Pos.Avg.Cost
                             , Current.Close.Price = last(get(YahooSymbol))
                             , Current.Value = last(get(YahooSymbol))*Pos.Qty 
                             , Profit.Loss.Absolute = last(get(YahooSymbol))*Pos.Qty - Pos.Qty * Pos.Avg.Cost
                             ,Profit.Loss.Relative = round((last(get(YahooSymbol))*Pos.Qty - Pos.Qty * Pos.Avg.Cost)/(Pos.Qty * Pos.Avg.Cost),4)
), by = "YahooSymbol"]














