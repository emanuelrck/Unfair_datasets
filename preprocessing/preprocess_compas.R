# Pre-processing of the COMPAS dataset (ProPublica, cox-parsed.csv) into data/compasTransformed.data
# Reconstructed from the R session used for the experiments.
# Source file: https://github.com/propublica/compas-analysis/blob/master/cox-parsed.csv
library(dplyr)

data <- read.csv("cox-parsed.csv")

# columns kept: sex, age_cat, race, juv_fel_count, juv_misd_count, juv_other_count,
# priors_count, c_charge_degree, score_text, v_score_text, event (two-year recidivism)
data <- data[, c("sex", "age_cat", "race", "juv_fel_count", "juv_misd_count", "juv_other_count",
                 "priors_count", "c_charge_degree", "score_text", "v_score_text", "event")]
data <- na.omit(data)

# "zero" is used instead of "None" because pandas reads the string None as a missing value
data[, "priors_count"] <- dplyr::case_when(data[, "priors_count"] < 1 ~ "zero",
                                           data[, "priors_count"] >= 1 & data[, "priors_count"] < 5 ~ "low",
                                           data[, "priors_count"] >= 5 ~ "high")
# "N/A" is replaced by "NotConsidered" for the same reason
data[, "score_text"] <- ifelse(data[, "score_text"] == "N/A", "NotConsidered", data[, "score_text"])
data[, "v_score_text"] <- ifelse(data[, "v_score_text"] == "N/A", "NotConsidered", data[, "v_score_text"])

# binarisation of the sensitive attributes
data[, "race"] <- dplyr::case_when(data[, "race"] != "Caucasian" ~ "notWhite",
                                   data[, "race"] == "Caucasian" ~ "White")
data[, "age_cat"] <- dplyr::case_when(data[, "age_cat"] != "25 - 45" ~ "notAdult",
                                      data[, "age_cat"] == "25 - 45" ~ "adult")
data[, "age_cat"] <- as.factor(data[, "age_cat"])
data[, "race"] <- as.factor(data[, "race"])
data[, "sex"] <- as.factor(data[, "sex"])
data[, "event"] <- as.factor(data[, "event"])

write.table(data, file = "compasTransformed.data", row.names = FALSE, col.names = TRUE, sep = ";", quote = FALSE)
