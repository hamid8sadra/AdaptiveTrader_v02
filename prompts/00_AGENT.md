


Ignore following lines:

# Archive
## prompt 1
read following files in order and follow instructions:{
    "01_INDICATOR_SPEC_template.md";
    "01_INDICATOR_SPEC_WeightedPricePDF.md"
    "02_LEVEL1_INDICATOR.md"
}
## prompt 2
read following files in order and follow instructions:{
    "prompts\00_MASTER_CONTEXT.md",
    "MQL5\Indicators\AdaptiveTrader\Ind_WeightedPricePDF.md"
    "prompts\07_LEVEL3_EXPERT.md"
}

# staus
strategy_names:{
    WeightedPricePDF:{
        LEVEL1_INDICATOR_is_ready: True;
        LEVEL3_EXPERT_is_ready:True;
    }
}