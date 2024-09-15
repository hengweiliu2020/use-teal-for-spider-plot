# use tm_g_ipp for spider plot

library(nestcolor)
library(teal)
library(teal.modules.clinical)
library(teal.modules.general)
library(haven)
library(formatters)
library(rtables)
library(tern)



data <- teal_data( )
data = within(data,{
  
  adsl <- read_sas("adsl.sas7bdat")
  adtr <- read_sas("adtr.sas7bdat")
  
  adtr <- adtr[(adtr$PARAMCD=='SUMDIAM' & !is.na(adtr$AVISITN)),]
  adtr$AVISIT <- factor(adtr$AVISIT, 
                        levels=c("Screening", "Cycle 03 Day 01", "Cycle 05 Day 01", 
                                 "Cycle 07 Day 01", "Cycle 09 Day 01", "Cycle 13 Day 01", "End of Treatment"
                        ))
  
  temp <- adsl[c("USUBJID",'ARM')]
  adtr <- merge(adtr, temp, by=c('USUBJID'), all.x=TRUE)
  
  adtr$ARM <- factor(adtr$ARM)
  adsl$ARM <- factor(adsl$ARM)
  
  adtr$AVALU <- ''
  adtr$BASE <- 0
 
  ADSL <- adsl
  ADTR <- adtr
})

datanames(data) <- c("ADSL", "ADTR")

jk <- join_keys(
  join_key("ADSL", "ADSL", c("USUBJID",'ARM')),
  join_key("ADTR", "ADTR", c("USUBJID",'ARM', 'PARAMCD','AVISIT','AVALU')) , 
  join_key("ADSL", "ADTR", c("USUBJID",'ARM'))
  
)

join_keys(data) <- jk

ADTR <- data[["ADTR"]]
ADSL <- data[["ADSL"]]

app <- init(
  
  data = data, 
  
    modules =modules(
      
     
      
      tm_g_ipp(
        label = "Spider Plot",
        dataname = "ADTR",
        arm_var = choices_selected(
          value_choices(ADTR, "ARM"),
          "Dose escalation DrugABC 0.016 mg/kg"
        ),
        paramcd = choices_selected(
          value_choices(ADTR, "PARAMCD"),
          "SUMDIAM"
        ),
        aval_var = choices_selected(
          variable_choices(ADTR, c("AVAL", "PCHG")),
          "PCHG"
        
        ),
        avalu_var = choices_selected(
          variable_choices(ADTR, c("AVALU")),
          "AVALU",
          fixed = TRUE
        ),
        id_var = choices_selected(
          variable_choices(ADTR, c("USUBJID")),
          "USUBJID",
          fixed = TRUE
        ),
        visit_var = choices_selected(
          variable_choices(ADTR, c("AVISIT")),
          "AVISIT"
        ),
        baseline_var = choices_selected(
          variable_choices(ADTR, c("BASE")),
          "BASE",
          fixed = TRUE
        ),
        add_baseline_hline = FALSE,
        separate_by_obs = FALSE
      )
      
      
    )
    
   
)
shinyApp(app$ui, app$server)