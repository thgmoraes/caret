timestamp <- Sys.time()
library(caret)

model <- "ORFsvm"

#########################################################################

set.seed(2)
training <- twoClassSim(50, linearVars = 2)
testing <- twoClassSim(500, linearVars = 2)
trainX <- training[, -ncol(training)]
trainY <- training$Class

seeds <- vector(mode = "list", length = nrow(training) + 1)
seeds <- lapply(seeds, function(x) 1:20)

cctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all",
                       classProbs = TRUE, 
                       summaryFunction = twoClassSummary, 
                       seeds = seeds)
cctrl2 <- trainControl(method = "LOOCV",
                       classProbs = TRUE, 
                       summaryFunction = twoClassSummary, 
                       seeds = seeds)
cctrl3 <- trainControl(method = "none",
                       classProbs = TRUE, 
                       summaryFunction = twoClassSummary,
                       seeds = seeds)
cctrlR <- trainControl(method = "cv", number = 3, returnResamp = "all", search = "random")

set.seed(849)
test_class_cv_model <- train(trainX, trainY, 
                             method = "ORFsvm", 
                             trControl = cctrl1,
                             metric = "ROC", 
                             preProc = c("center", "scale"),
                             verbose = FALSE,
                             ntree = 20)

set.seed(849)
test_class_cv_form <- train(Class ~ ., data = training, 
                            method = "ORFsvm", 
                            trControl = cctrl1,
                            metric = "ROC", 
                            preProc = c("center", "scale"),
                            verbose = FALSE,
                            ntree = 20)

test_class_pred <- predict(test_class_cv_model, testing[, -ncol(testing)])
test_class_prob <- predict(test_class_cv_model, testing[, -ncol(testing)], type = "prob")
test_class_pred_form <- predict(test_class_cv_form, testing[, -ncol(testing)])
test_class_prob_form <- predict(test_class_cv_form, testing[, -ncol(testing)], type = "prob")

set.seed(849)
test_class_rand <- train(trainX, trainY, 
                         method = "ORFsvm", 
                         trControl = cctrlR,
                         tuneLength = 4,
                         verbose = FALSE,
                         ntree = 20)

set.seed(849)
test_class_loo_model <- train(trainX, trainY, 
                              method = "ORFsvm", 
                              trControl = cctrl2,
                              metric = "ROC", 
                              preProc = c("center", "scale"),
                              verbose = FALSE,
                              ntree = 20)

set.seed(849)
test_class_none_model <- train(trainX, trainY, 
                               method = "ORFsvm", 
                               trControl = cctrl3,
                               tuneLength = 1,
                               metric = "ROC", 
                               preProc = c("center", "scale"),
                               verbose = FALSE,
                               ntree = 20)

test_class_none_pred <- predict(test_class_none_model, testing[, -ncol(testing)])
test_class_none_prob <- predict(test_class_none_model, testing[, -ncol(testing)], type = "prob")

test_levels <- levels(test_class_cv_model)
if(!all(levels(trainY) %in% test_levels))
  cat("wrong levels")

#########################################################################

tests <- grep("test_", ls(), fixed = TRUE, value = TRUE)

sInfo <- sessionInfo()
timestamp_end <- Sys.time()

save(list = c(tests, "sInfo", "timestamp", "timestamp_end"),
     file = file.path(getwd(), paste(model, ".RData", sep = "")))

q("no")


