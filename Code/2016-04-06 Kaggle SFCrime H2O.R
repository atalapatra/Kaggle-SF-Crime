
setwd("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project")

train <- read.csv("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/train.csv")
test <- read.csv("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/test.csv")
sampleSubmission <- read.csv(check.names = FALSE, "C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/sampleSubmission.csv")
rowIds <- sampleSubmission$Id
colNames <- colnames(sampleSubmission)

## Starts up H2O 
library(h2o)
h2o.init(nthreads = -1) # Start with all CPUs

pathToFolder <- "C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/train.csv"
train.hex = h2o.importFile(path = pathToFolder,
                           destination_frame = "train.hex")

pathToFolder <- "C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/test.csv"
test.hex = h2o.importFile(path = pathToFolder,
                          destination_frame = "test.hex")

# # Feature-engineered Datasets
# pathToFolder <- "SF Data/trainmod1.csv"
# train.hex = h2o.importFile(path = pathToFolder,
#                            destination_frame = "train.hex")
# 
# pathToFolder <- "SF Data/testmod1.csv"
# test.hex = h2o.importFile(path = pathToFolder,
#                           destination_frame = "test.hex")

# # Feature-engineered Datasets
# pathToFolder <- "SF Data/trainmod2.csv"
# train.hex = h2o.importFile(path = pathToFolder,
#                            destination_frame = "train.hex")
# 
# pathToFolder <- "SF Data/testmod2.csv"
# test.hex = h2o.importFile(path = pathToFolder,
#                           destination_frame = "test.hex")

### Feature Engineering
## Function for Feature Engineering
# make_vars_date <- function(crime_df) {
#   crime_df$Years = strftime(strptime(crime_df$Dates,
#                                      "%Y-%m-%d %H:%M:%S"),"%Y")
#   crime_df$Month = strftime(strptime(crime_df$Dates,
#                                      "%Y-%m-%d %H:%M:%S"),"%m")
#   crime_df$DayOfMonth = strftime(strptime(crime_df$Dates,
#                                           "%Y-%m-%d %H:%M:%S"),"%d")
#   crime_df$Hour = strftime(strptime(crime_df$Dates,
#                                     "%Y-%m-%d %H:%M:%S"),"%H")
#   crime_df$YearsMo = paste( crime_df$Years, crime_df$Month , 
#                             sep = "-" )
#   crime_df$DayOfWeek = factor(crime_df$DayOfWeek,
#                               levels=c("Monday","Tuesday",
#                                        "Wednesday","Thursday",
#                                        "Friday","Saturday","Sunday"),
#                               ordered=TRUE)
#   crime_df$weekday = "Weekday"
#   crime_df$weekday[crime_df$DayOfWeek== "Saturday" | 
#                      crime_df$DayOfWeek== "Sunday" | 
#                      crime_df$DayOfWeek== "Friday" ] = "Weekend"
#   addr_spl = strsplit(as.character(crime_df$Address),"/")
#   crime_df$AddressType = "Non-Intersection"
#   ind_l = vector()
#   ind_inxn = sapply(1:dim(crime_df)[1], 
#                     function(x) length(addr_spl[[x]]) == 2)
#   crime_df$AddressType[ ind_inxn ]="Intersection"  
#   return(crime_df)
# }

x <- c("DayOfWeek", "PdDistrict", "X", "Y")
# x <- c("DayOfWeek", "PdDistrict", "X", "Y",
#        "Years","Month","DayOfMonth","Hour","YearsMo","weekday","AddressType")
# x <- c("DayOfWeek", "PdDistrict", "X", "Y", "TMIN", "TMAX", "TAVG")

y <- "Category"

### Split into Training and Validation
# splits <- h2o.splitFrame(train.hex, c(0.7), seed=1234)
# train  <- h2o.assign(splits[[1]], "train.hex") # 70%
# valid  <- h2o.assign(splits[[2]], "valid.hex") # 30%

#### Neural Network Models

# model <- h2o.deeplearning(training_frame=train.hex, 
#                           x,
#                           y,
#                           #activation="Rectifier",  ## default
#                           hidden=c(50,50,50),       ## default: 2 hidden layers with 200 neurons each
#                           epochs=100,
#                           variable_importances=T)    ## not enabled by default

# model <- h2o.deeplearning(training_frame=train, 
#                           validation_frame=valid,
#                           x,
#                           y,
#                           hidden=c(32,32,32),                  ## small network, runs faster
#                           epochs=1000000,                      ## hopefully converges earlier...
#                           score_validation_samples=10000,      ## sample the validation dataset (faster)
#                           stopping_rounds=2,
#                           stopping_metric="misclassification", ## could be "MSE","logloss","r2"
#                           stopping_tolerance=0.01)

# model <- h2o.deeplearning(x,  # column numbers for predictors
#                           y,   # column number for label
#                           training_frame = train.hex, # data in H2O format
#                           activation = "TanhWithDropout", # or 'Tanh'
#                           input_dropout_ratio = 0.2, # % of inputs dropout
#                           hidden_dropout_ratios = c(0.5,0.5,0.5), # % for nodes dropout
#                           balance_classes = TRUE, 
#                           hidden = c(50,50,50), # three layers of 50 nodes
#                           epochs = 100) # max. no. of epochs
 
#### Random Forest Models

model <- h2o.randomForest(x, 
                          y, 
                          training_frame = train.hex, 
                          ntree = 50)

#### Run Test Prediction
modelTest <- h2o.predict(model, test.hex)
modelTestDf <- as.data.frame(modelTest)

#### Set up submission 
modelTestDf$predict <- NULL

## For rounding - might not be necesarry:
# modelTestDf <- as.data.frame(lapply(modelTestDf, round, 5))

modelTestDf <- data.frame(Id = 0, modelTestDf)
modelTestDf$Id <- rowIds
colnames(modelTestDf) <- colNames

write.csv(modelTestDf, row.names = FALSE, file = "Submissions/2016-04-18-01 DL.csv")
