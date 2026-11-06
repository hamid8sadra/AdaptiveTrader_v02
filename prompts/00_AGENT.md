read following files in order and follow instructions:{
    "prompts\00_MASTER_CONTEXT.md"
    "prompts\04_EXPERTCLASS_03.md"
}


# Ignore following lines:

# Archive
## Archived prompt 1
read following files in order and follow instructions:{
    "prompts\00_MASTER_CONTEXT.md"
    "prompts\01_INDICATOR_SPEC_template.md"
    "prompts\01_INDICATOR_SPEC_WeightedPricePDF.md"
    "prompts\01_INDICATOR.md"
}
## Archived prompt 2
read following files in order and follow instructions:{
    "prompts\00_MASTER_CONTEXT.md"
    prompts\02_NBO_EXPERT.md
}
## Archived prompt 3
read following files in order and follow instructions:{
    "prompts\00_MASTER_CONTEXT.md"
    "prompts\03_INDICATORCLASS.md"
}
## Archived prompt 4.1
read following files in order and follow instructions:{
    "prompts\00_MASTER_CONTEXT.md"
    "prompts\04_EXPERTCLASS_01.md"
}
## Archived prompt 4.2
read following files in order and follow instructions:{
    "prompts\00_MASTER_CONTEXT.md"
    "prompts\04_EXPERTCLASS_02.md"
}
## Archived prompt 4.3
read following files in order and follow instructions:{
    "prompts\00_MASTER_CONTEXT.md"
    "prompts\04_EXPERTCLASS_03.md"
}
## Archived prompt 4.4
read following files in order and follow instructions:{
    "prompts\00_MASTER_CONTEXT.md"
    "prompts\04_EXPERTCLASS_04.md"
}


# staus
strategy_names:{
    WeightedPricePDF:{
        LEVEL1_INDICATOR_is_ready: True;
        LEVEL3_EXPERT_is_ready:True;
    }
}

# File Structure

prompts\00_AGENT.md
prompts\00_MASTER_CONTEXT.md

prompts\01_INDICATOR_SPEC_template.md
prompts\01_INDICATOR_SPEC_WeightedPricePDF.md
prompts\01_INDICATOR.md
create:
   MQL5\Indicators\AdaptiveTrader\Ind_WeightedPricePDF.mq5
   MQL5\Indicators\AdaptiveTrader\Ind_WeightedPricePDF.md

prompts\02_NBO_EXPERT.md
create:
   MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF.mq5

prompts\03_INDICATORCLASS.md
create:
   MQL5\Include\AdaptiveTrader\IndC_WeightedPricePDF.mqh
   MQL5\Include\AdaptiveTrader\IndC_WeightedPricePDF.md
   MQL5\Experts\AdaptiveTrader\EA_IndC_WeightedPricePDF_test.mq5     // temp

prompts\04_EXPERTCLASS.md
create:
    MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_normal.mq5      // temp
    MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_IndC.mq5        // temp

    MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.mqh         // temp
    MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.md         // temp
    MQL5\Experts\AdaptiveTrader\EAC_WeightedPricePDF_basic_test.mq5      // temp

    MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF.mqh
    MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF.md
    MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_test.mq5    // temp