# Pre-processing of the Communities and Crime dataset (UCI, communities.data) into data/crimeTransformed.data
# Reconstructed from the R session used for the experiments.
# Source: https://doi.org/10.24432/C53W3X (file communities.data, with the header of the attribute names)
library(dplyr)

data <- read.csv("communities.data")

# 22 attributes kept (all normalised to [0, 1] in the original data)
data <- data[, c("racepctblack", "pctWInvInc", "pctWPubAsst", "NumUnderPov", "PctPopUnderPov",
                 "PctUnemployed", "MalePctDivorce", "FemalePctDiv", "TotalPctDiv", "PersPerFam",
                 "PctKids2Par", "PctYoungKids2Par", "PctTeen2Par", "NumIlleg", "PctIlleg",
                 "PctPersOwnOccup", "HousVacant", "PctHousOwnOcc", "PctVacantBoarded",
                 "NumInShelters", "NumStreet", "ViolentCrimesPerPop")]
data <- na.omit(data)

# every attribute, including the sensitive attribute (racepctblack) and the target
# (ViolentCrimesPerPop), is binarised at 0.7: "low" (< 0.7) / "high" (>= 0.7)
cont <- 1
for (i in data) {
  data[, cont] <- dplyr::case_when(i < 0.7 ~ "low",
                                   i >= 0.7 ~ "high")
  cont <- cont + 1
}
data[, "racepctblack"] <- as.factor(data[, "racepctblack"])
data[, "ViolentCrimesPerPop"] <- as.factor(data[, "ViolentCrimesPerPop"])
colnames(data)[which(colnames(data) == "racepctblack")] <- "race"
colnames(data)[which(colnames(data) == "ViolentCrimesPerPop")] <- "crime"

write.table(data, file = "crimeTransformed.data", row.names = FALSE, col.names = TRUE, sep = ";", quote = FALSE)
