# myRportfolio
Initial implementation to handle a small portfolio of equities and ETFs with R

Based on various R packages it makes use of the powerful TradeAnalytics suite 
and uses the blotter package to keep track of the trading history.
Besides the possibility to easily create a portfolio in blotter it also
offers basic calculations on the portfolio to give you a quick overview on the
current positions. 
Additional summary commands are of course available, when using the TradeAnalytics suite as indicated in this thread on r-sig-finacne. [1]
This is not really a tool to really implement a portfolio management strategy, but it 
rather is a tool to keep track of the changes in a personal portfolio and get a quick
overview over the current positions.
ToDo:
- implement the possibility to keep track of savings plans, so that one can just put in the basic data of savings plans and these positions are then incorporated explicitly into the portfolio.

It basically was born out of frustration on the offered possibilities of my broker's website and the shortcomings I faced, when using a spreadsheet.

- johannes

[1] https://stat.ethz.ch/pipermail/r-sig-finance/2017q1/014175.html


