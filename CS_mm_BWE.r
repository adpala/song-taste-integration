library(glmmTMB)

# load data
soc.data <- read.csv(file = "dat/CS_annotated.csv", header = T, stringsAsFactors = T)

# select corresponding conditions and exclude NaNs
soc.data <- subset(soc.data, (!is.na(soc.data$BWE)) & (soc.data$sex_target == "male"))

# substitute zeros with small number to avoid mathematical errors later
soc.data$BWE <- ifelse(soc.data$BWE == 0, 0.00001, soc.data$BWE)

# model definitions and training
null.soc <- glmmTMB(BWE ~ 1, data = soc.data, family = beta_family)
red.soc <- glmmTMB(BWE ~ taste + playlist, data = soc.data, family = beta_family)
full.soc <- glmmTMB(BWE ~ taste * playlist, data = soc.data, family = beta_family)
# model selection
model_selection <- as.data.frame(anova(null.soc, red.soc, full.soc, test = "Chisq"))
model_selection$strain <- "CS"
model_selection$y <- "BWE"
model_selection$analysis <- "simple"
write.csv(model_selection, "res/CS_males_BWE_chisq.csv")

# coefficient tables
null_df <- as.data.frame(summary(null.soc)$coefficients$cond)
null_df$model <- "null_model"
null_df$names <- row.names(null_df)
row.names(null_df) <- NULL

red_df <- as.data.frame(summary(red.soc)$coefficients$cond)
red_df$model <- "linear"
red_df$names <- row.names(red_df)
row.names(red_df) <- NULL

full_df <- as.data.frame(summary(full.soc)$coefficients$cond)
full_df$model <- "nonlinear"
full_df$names <- row.names(full_df)
row.names(full_df) <- NULL

combined_df <- rbind(null_df, red_df, full_df)
combined_df$strain <- "CS"
combined_df$y <- "BWE"
combined_df$analysis <- "simple"
write.csv(combined_df, "res/CS_males_BWE_coeffs.csv")
