

Name = "WeightedPricePDF"
short_Description = "A volume-weighted price distribution indicator that estimates price quantiles and the most populated price level over a rolling candle window."
type: chart_window

- What it measures: """
  The weighted distribution of traded price levels over the latest inp_period candles.
  Each candle is modeled as a uniform price distribution between its Low and High.
  The candle's tick_volume is used as the total weight of that distribution.
  Candle weights are distributed across a fixed number of price bins according
  to their geometric overlap with each bin.
  The resulting histogram represents the aggregated weighted price distribution.
  Four statistical levels are extracted from this distribution:
  median (Q50), upper quantile (QUP), lower quantile (QDN), and mode.
  """

- Calculation rules:
  - Source data:
    """
    Use the latest inp_period closed M1 candles.
    The indicator recalculates only when a new candle opens on the current
    chart timeframe, meaning the previous chart candle has closed.
    """

  - Histogram construction:
    """
    1. Find the highest High and lowest Low across the selected candles.
    2. Divide this price range into histogram_bins equal-width bins.
    3. Model each candle as a uniform distribution between its Low and High.
    4. Use tick_volume as the candle's total distribution weight.
    5. Distribute the candle's weight among histogram bins proportionally
       to the overlap length between the candle's price range and each bin.
    Each candle's total weight must be preserved after distribution.
    """

  - Buffer0:
    label: "Q50"
    what's in it: """
    The weighted median price (50th percentile) of the aggregated price
    distribution.
    It is the price level at which 50% of the total histogram weight
    lies below it and 50% lies above it.
    """

  - Buffer1:
    label: "QUP"
    what's in it: """
    The upper quantile of the weighted price distribution.
    Its percentile is defined by upper_quantile.
    For example, upper_quantile = 95 means that 95% of the total
    histogram weight lies at or below this price level.
    """

  - Buffer2:
    label: "QDN"
    what's in it: """
    The lower quantile of the weighted price distribution.
    Its percentile is defined by lower_quantile.
    For example, lower_quantile = 5 means that 5% of the total
    histogram weight lies at or below this price level.
    """

  - Buffer3:
    label: "Mode"
    what's in it: """
    The center price of the histogram bin containing the highest
    accumulated weight.

    It represents the most populated price interval in the
    weighted price distribution.
    """

//--- Inputs: original parameters preserved {type, default value, range, optional description}
  - inp_period {int, 60, [30,inf], "Number of source candles used to construct the price distribution."}
  - upper_quantile {int, 95, [65,95], "Upper quantile percentile used to calculate QUP."}
  - lower_quantile {int, 5, [5,35], "Lower quantile percentile used to calculate QDN."}
  - histogram_bins {int, 100, [5,100], "Number of equal-width price intervals used to construct the weighted histogram."}