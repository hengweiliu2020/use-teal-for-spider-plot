# sample program from teal manual

library(nestcolor)
library(dplyr)
library(tidyr)
library(teal)
library(tern)
library(teal.modules.clinical)
library(teal.modules.general)

ADSL <- tmc_ex_adsl %>%
  slice(1:20) %>%
  df_explicit_na()
ADLB <- tmc_ex_adlb %>%
  filter(USUBJID %in% ADSL$USUBJID) %>%
  df_explicit_na() %>%
  filter(AVISIT != "SCREENING")
app <- init(
  data = cdisc_data(
    ADSL = ADSL,
    ADLB = ADLB,
    code = "
 ADSL <- tmc_ex_adsl %>% slice(1:20) %>% df_explicit_na()
 ADLB <- tmc_ex_adlb %>% filter(USUBJID %in% ADSL$USUBJID) %>%
 df_explicit_na() %>% filter(AVISIT != \"SCREENING\")
 "
  ),
  modules = modules(
    tm_g_ipp(
      label = "Individual Patient Plot",
      dataname = "ADLB",
      arm_var = choices_selected(
        value_choices(ADLB, "ARMCD"),
        "ARM A"
      ),
      paramcd = choices_selected(
        value_choices(ADLB, "PARAMCD"),
        "ALT"
      ),
      aval_var = choices_selected(
        variable_choices(ADLB, c("AVAL", "CHG")),
        "AVAL"
        
        
      ),
      avalu_var = choices_selected(
        variable_choices(ADLB, c("AVALU")),
        "AVALU",
        fixed = TRUE
      ),
      id_var = choices_selected(
        variable_choices(ADLB, c("USUBJID")),
        "USUBJID",
        fixed = TRUE
      ),
      visit_var = choices_selected(
        variable_choices(ADLB, c("AVISIT")),
        "AVISIT"
      ),
      baseline_var = choices_selected(
        variable_choices(ADLB, c("BASE")),
        "BASE",
        fixed = TRUE
      ),
      add_baseline_hline = FALSE,
      separate_by_obs = FALSE
    )
  )
)
if (interactive()) {
  shinyApp(app$ui, app$server)
}
