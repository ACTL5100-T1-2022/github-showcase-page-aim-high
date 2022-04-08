setwd('E:/Downloads/SOA Challenge - ACLT5100 Assignment')

#function to install packages

packages <- c("readxl","tidyr","ggplot2","e1071","qwraps2","rmarkdown","tidyverse","caret")
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
invisible(lapply(packages, library, character.only = TRUE))

#read in sheets of data from xlsx
path <- "Player data flat.xlsx"
L.sheets <- readxl::excel_sheets(path)
L.list <- lapply(L.sheets,
                 function(sheet) readxl::read_excel(path, sheet = sheet))
names(L.list) <- L.sheets
list2env(L.list, envir = .GlobalEnv)

#generate prelim exploratory summary stats
options(qwraps2_markup = "markdown")
drops <- c("Player","Nation","Pos","Squad","Born","League","p.score")

L.Sh_summary <- summary_table(L.Sh[,!(names(L.Sh) %in% drops)], by=c("Year"))
print(L.Sh_summary, rtitle = "League Shooting", cname = c("2020","2021"))

L.Ps_summary <- summary_table(L.Ps[,!(names(L.Ps) %in% drops)], by=c("Year"))
print(L.Ps_summary, rtitle = "League Passing", cname = c("2020","2021"))

L.Df_summary <- summary_table(L.Df[,!(names(L.Df) %in% drops)], by=c("Year"))
print(L.Df_summary, rtitle = "League Defending", cname = c("2020","2021"))

L.Gk_summary <- summary_table(L.Gk[,!(names(L.Gk) %in% drops)], by=c("Year"))
print(L.Gk_summary, rtitle = "League Goalkeeping", cname = c("2020","2021"))

#generate exploratory scatter plots
L.Sh %>%
  gather(-Player, -Nation, -Pos, -Squad, -Born, -League, -p.score, -Year, key = "var", value = "value") %>% 
  ggplot(aes(x = value, y = p.score)) +
  geom_point() +
  facet_wrap(~ var, scales = "free")

L.Ps %>%
  gather(-Player, -Nation, -Pos, -Squad, -Born, -League, -p.score, -Year, key = "var", value = "value") %>% 
  ggplot(aes(x = value, y = p.score)) +
  geom_point() +
  facet_wrap(~ var, scales = "free")

L.Df %>%
  gather(-Player, -Nation, -Pos, -Squad, -Born, -League, -p.score, -Year, key = "var", value = "value") %>% 
  ggplot(aes(x = value, y = p.score)) +
  geom_point() +
  facet_wrap(~ var, scales = "free")

L.Gk %>%
  gather(-Player, -Nation, -Pos, -Squad, -Born, -League, -p.score, -Year, key = "var", value = "value") %>% 
  ggplot(aes(x = value, y = p.score)) +
  geom_point() +
  facet_wrap(~ var, scales = "free")

#define categorical variable for "successful" teams
L.Sh$`p.score>0.65` <- as.factor(ifelse(L.Sh$`p.score`>0.65, "yes", "no"))
L.Ps$`p.score>0.65` <- as.factor(ifelse(L.Ps$`p.score`>0.65, "yes", "no"))
L.Df$`p.score>0.65` <- as.factor(ifelse(L.Df$`p.score`>0.65, "yes", "no"))
L.Gk$`p.score>0.65` <- as.factor(ifelse(L.Gk$`p.score`>0.65, "yes", "no"))

#define variables useful for subsetting and svm fitting
drop.sub <- c("Player","Nation","Pos","Squad","Born","League","Year")
tctrl <- trainControl(method = "repeatedcv",
                      number = 5,
                      repeats = 3,
                      classProbs = TRUE,
                      verboseIter = TRUE,
                      savePredictions = TRUE)

#subsetting the training data
L.Sh.foreign <- L.Sh %>% 
  filter(Nation != "Rarita") %>%
  select(-drop.sub)
train_index <- sample(1:nrow(L.Sh.foreign),0.8*nrow(L.Sh.foreign))
L.Sh.train <- L.Sh.foreign[train_index,]
L.Sh.val <- L.Sh.foreign[-train_index,]

#removing any observations with missing data
L.Sh.foreign.naomit <-na.omit(L.Sh.foreign) #removed obs, n=1481 remaining
L.Sh.train.naomit <- na.omit(L.Sh.train) #removed 250 obs, n=1187 remaining
L.Sh.val.naomit <- na.omit(L.Sh.val) #removed 66 obs, n=290 remaining

#fitting League shooting using linear, radial and poly kernel 
svm_L.Sh.L <- train(`p.score>0.65`~., data=L.Sh.train.naomit,
                  method="svmLinear",
                  preProcess = c("center","scale"),
                  tuneGrid = expand.grid(C = seq(0,5,length=10)),
                  trControl=tctrl)
plot(svm_L.Sh.L)
svm_L.Sh.L.preds <- predict(svm_L.Sh.L, newdata=L.Sh.val.naomit, type="prob")
svm_L.Sh.L.preds.sort <- as.factor(ifelse(svm_L.Sh.L.preds[,2] > 0.5, "yes", "no"))
svm_L.Sh.L.cm <- confusionMatrix(svm_L.Sh.L.preds.sort, L.Sh.val.naomit$`p.score>0.65`)

svm_L.Sh.R <- train(`p.score>0.65`~., data=L.Sh.train.naomit,
                    method="svmRadial",
                    preProcess = c("center","scale"),
                    trControl=tctrl)
svm_L.Sh.R.preds <- predict(svm_L.Sh.R, newdata=L.Sh.val.naomit, type="prob")
svm_L.Sh.R.preds.sort <- as.factor(ifelse(svm_L.Sh.R.preds[,2] > 0.5, "yes", "no"))
svm_L.Sh.R.cm <- confusionMatrix(svm_L.Sh.R.preds.sort, L.Sh.val.naomit$`p.score>0.65`)

svm_L.Sh.P <- train(`p.score>0.65`~., data=L.Sh.train.naomit,
                    method="svmPoly",
                    preProcess = c("center","scale"),
                    trControl=tctrl)
svm_L.Sh.P.preds <- predict(svm_L.Sh.P, newdata=L.Sh.val.naomit, type="prob")
svm_L.Sh.P.preds.sort <- as.factor(ifelse(svm_L.Sh.P.preds[,2] > 0.5, "yes", "no"))
svm_L.Sh.P.cm <- confusionMatrix(svm_L.Sh.P.preds.sort, L.Sh.val.naomit$`p.score>0.65`)

#selecting svm with linear kernel as our model. Fit model to full training data.
L.Sh.Rarita <- L.Sh %>%
  filter(Nation == "Rarita") %>%
  na.omit(L.Sh.Rarita)  #n=90 remaining

L.Sh.Rarita.naomit <- L.Sh.Rarita %>%
  select(-drop.sub)

svm_L.Sh.full <- train(`p.score>0.65`~., data=L.Sh.foreign.naomit,
                    method="svmLinear",
                    preProcess = c("center","scale"),
                    tuneGrid = expand.grid(C = seq(0,5,length=10)),
                    trControl=tctrl)
plot(svm_L.Sh.full)
svm_L.Sh.full.preds <- predict(svm_L.Sh.full, newdata=L.Sh.Rarita.naomit, type="prob")
svm_L.Sh.full.preds.sort <- as.factor(ifelse(svm_L.Sh.full.preds[,2] > 0.5, "yes", "no"))
L.Sh.Rarita$selection <- svm_L.Sh.full.preds.sort

write.csv(L.Sh.Rarita, file="L.Sh selections.csv")

#subset training data, remove missing, fit linear svm to full training, generate predictions for L.Ps, L.Df, L.Gk
## L.Ps
L.Ps.foreign <- L.Ps %>% 
  filter(Nation != "Rarita") %>%
  select(-drop.sub)
train_index <- sample(1:nrow(L.Ps.foreign),0.8*nrow(L.Ps.foreign))
L.Ps.train <- L.Ps.foreign[train_index,]
L.Ps.val <- L.Ps.foreign[-train_index,]

L.Ps.foreign.naomit <-na.omit(L.Ps.foreign) #removed 125 obs, n=2264 remaining
L.Ps.train.naomit <- na.omit(L.Ps.train) #removed 96 obs, n=1576 remaining
L.Ps.val.naomit <- na.omit(L.Ps.val) #removed 29 obs, n=688 remaining

L.Ps.Rarita <- L.Ps %>%
  filter(Nation == "Rarita") %>%
  na.omit(L.Ps.Rarita)  #n=141 remaining

L.Ps.Rarita.naomit <- L.Ps.Rarita %>%
  select(-drop.sub)

svm_L.Ps.full <- train(`p.score>0.65`~., data=L.Ps.foreign.naomit,
                       method="svmLinear",
                       preProcess = c("center","scale"),
                       tuneGrid = expand.grid(C = seq(0,5,length=10)),
                       trControl=tctrl)
plot(svm_L.Ps.full)
svm_L.Ps.full.preds <- predict(svm_L.Ps.full, newdata=L.Ps.Rarita.naomit, type="prob")
svm_L.Ps.full.preds.sort <- as.factor(ifelse(svm_L.Ps.full.preds[,2] > 0.5, "yes", "no"))
L.Ps.Rarita$selection <- svm_L.Ps.full.preds.sort

write.csv(L.Ps.Rarita, file="L.Ps selections.csv")

## L.Df
L.Df.foreign <- L.Df %>% 
  filter(Nation != "Rarita") %>%
  select(-drop.sub)
train_index <- sample(1:nrow(L.Df.foreign),0.8*nrow(L.Df.foreign))
L.Df.train <- L.Df.foreign[train_index,]
L.Df.val <- L.Df.foreign[-train_index,]

L.Df.foreign.naomit <-na.omit(L.Df.foreign) #removed 125 obs, n=1924 remaining
L.Df.train.naomit <- na.omit(L.Df.train) #removed 94 obs, n=1340 remaining
L.Df.val.naomit <- na.omit(L.Df.val) #removed 31 obs, n=584 remaining

L.Df.Rarita <- L.Df %>%
  filter(Nation == "Rarita") %>%
  na.omit(L.Df.Rarita)  #n=124 remaining

L.Df.Rarita.naomit <- L.Df.Rarita %>%
  select(-drop.sub)

svm_L.Df.full <- train(`p.score>0.65`~., data=L.Df.foreign.naomit,
                       method="svmLinear",
                       preProcess = c("center","scale"),
                       tuneGrid = expand.grid(C = seq(0,5,length=10)),
                       trControl=tctrl)
plot(svm_L.Df.full)
svm_L.Df.full.preds <- predict(svm_L.Df.full, newdata=L.Df.Rarita.naomit, type="prob")
svm_L.Df.full.preds.sort <- as.factor(ifelse(svm_L.Df.full.preds[,2] > 0.5, "yes", "no"))
L.Df.Rarita$selection <- svm_L.Df.full.preds.sort

write.csv(L.Df.Rarita, file="L.Df selections.csv")

## L.Gk
L.Gk.foreign <- L.Gk %>% 
  filter(Nation != "Rarita") %>%
  select(-drop.sub)
train_index <- sample(1:nrow(L.Gk.foreign),0.8*nrow(L.Gk.foreign))
L.Gk.train <- L.Gk.foreign[train_index,]
L.Gk.val <- L.Gk.foreign[-train_index,]

L.Gk.foreign.naomit <-na.omit(L.Gk.foreign) #removed 113 obs, n=275 remaining
L.Gk.train.naomit <- na.omit(L.Gk.train) #removed 81 obs, n=190 remaining
L.Gk.val.naomit <- na.omit(L.Gk.val) #removed 32 obs, n=85 remaining

L.Gk.Rarita <- L.Gk %>%
  filter(Nation == "Rarita") %>%
  na.omit(L.Gk.Rarita)  #n=18 remaining

L.Gk.Rarita.naomit <- L.Gk.Rarita %>%
  select(-drop.sub)

svm_L.Gk.full <- train(`p.score>0.65`~., data=L.Gk.foreign.naomit,
                       method="svmLinear",
                       preProcess = c("center","scale"),
                       tuneGrid = expand.grid(C = seq(0,5,length=10)),
                       trControl=tctrl)
plot(svm_L.Gk.full)
svm_L.Gk.full.preds <- predict(svm_L.Gk.full, newdata=L.Gk.Rarita.naomit, type="prob")
svm_L.Gk.full.preds.sort <- as.factor(ifelse(svm_L.Gk.full.preds[,2] > 0.5, "yes", "no"))
L.Gk.Rarita$selection <- svm_L.Gk.full.preds.sort

write.csv(L.Gk.Rarita, file="L.Gk selections.csv")


