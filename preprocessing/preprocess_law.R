# Pre-processing of the Law School dataset (law_dataset.arff) into data/lawTransformed.data
# Reconstructed from the R session used for the experiments.
# Source: https://github.com/tailequy/fairness_dataset/tree/main/Law_school
library(dplyr)
library(foreign)

df <- read.arff("law_dataset.arff")
df <- na.omit(df)

# binarisation of the sensitive attribute "male" (1 = man, 0 = woman);
# "racetxt" (1 = white, 0 = non-white) and "pass_bar" are already binary
df[, "male"] <- dplyr::case_when(df[, "male"] >= 1 ~ "homem",
                                 df[, "male"] < 1 ~ "mulher")
df[, "male"] <- as.factor(df[, "male"])
df[, "racetxt"] <- as.factor(df[, "racetxt"])
df[, "pass_bar"] <- as.factor(df[, "pass_bar"])

write.table(df, file = "lawTransformed.data", row.names = FALSE, col.names = TRUE, sep = ";", quote = FALSE)
