#' This is a telecom company customer dataset. We have to predict customer churn based on customer behavior.
#' 
## ------------------------------------------------------------------------
library(plyr)
library(corrplot)
library(ggplot2)
library(gridExtra)
library(ggthemes)
library(caret)
library(MASS)
library(party)
library(RColorBrewer)
library(ROCR)
library(class)
library(rpart)
library(rattle)
library(rpart.plot)

## ------------------------------------------------------------------------
df_churn <- read.csv('Churn.csv')
head(df_churn)

 
## ------------------------------------------------------------------------
str(df_churn)


sapply(df_churn, function(x) sum(is.na(x)))


## ------------------------------------------------------------------------
count(df_churn, 'gender')
#table(df_churn$gender)

#' We can notice a number of customers are Female and Male using count() function
#' 
#' We have to check all columns like this way to count each category in a column.
## ------------------------------------------------------------------------
count(df_churn, 'SeniorCitizen')
class(df_churn$SeniorCitizen)

df_churn$SeniorCitizen = ifelse(df_churn$SeniorCitizen <=0.5, 0,1)
count(df_churn, 'SeniorCitizen')
count(df_churn, ' Partner')
count(df_churn, 'Dependents')
#count(df_churn, 'tenure')
count(df_churn, ' CallService')
count(df_churn, ' MultipleConnections') # *
count(df_churn, ' InternetConnection')
count(df_churn, ' OnlineSecurity') # *
count(df_churn, ' OnlineBackup') # *
count(df_churn, ' DeviceProtectionService') #  *
count(df_churn, ' TechnicalHelp') #  *
count(df_churn, ' OnlineTV') #  *
count(df_churn, ' OnlineMovies') #  *
count(df_churn, ' Agreement')
count(df_churn, ' BillingMethod')
count(df_churn, ' PaymentMethod')
#count(df_churn, ' MonthlyServiceCharges')
#count(df_churn, ' TotalAmount')
count(df_churn, ' Churn')


#' 
#' Based on the result of the count each column, change "No 
#' internet service" to 
#' "No" for six columns, they are: "OnlineSecurity", "OnlineBackup", 
#' "DeviceProtectionService", "TechnicalHelp", "OnlineTV", 
#' "OnlineMovies".
#' 
#' 
## ------------------------------------------------------------------------


A = c(2,3,4,5)

for (i in 1:4) {
  print(i)
}
  

df_churn[,10]
names(df_churn)

cols_name <- c(10:15)
XYZ =  df_churn[,cols_name][,1]

XYZ =  data.frame(df_churn[,cols_name][,1])
 ncol(df_churn[,cols_name])

#DF2 = df_churn[,cols_name]
#DF3 = data.frame(df_churn[,cols_name][,1])
df_churn[,cols_name][,1]

for(i in 1:ncol(df_churn[,cols_name])) 
    {
        df_churn[,cols_name][,i] <- as.factor(mapvalues
          (df_churn[,cols_name][,i], from =c("No internet service"),
            to=c("No")))
        }

#' 
#' 
#' 
## ------------------------------------------------------------------------




df_churn$MultipleConnections <- as.factor(mapvalues(df_churn$MultipleConnections, 
                                                    from=c("No phone service"),
                                                    to=c("No")))

#' 
## ------------------------------------------------------------------------
df_churn$SeniorCitizen <- as.factor(mapvalues(df_churn$SeniorCitizen,
                                      from=c("0","1"),
                                      to=c("No", "Yes")))

class(df_churn$SeniorCitizen)
#' 
#' 
#' Remove the columns we do not need for the analysis:
#' 
## ------------------------------------------------------------------------
df_churn$customerID <- NULL

#' 
#' ##Exploratory data analysis and feature selection
#' 
## ------------------------------------------------------------------------
numeric.var <- sapply(df_churn, is.numeric) ## Find numerical variables
XYZ = df_churn[,numeric.var]
corr.matrix <- cor(df_churn[,numeric.var])  ## Calculate the correlation matrix
#corrplot(corr.matrix, main="Corr Plot", method="number")

corrplot(corr.matrix, main="Corr Plot")

#' 
#' 
#' The MonthlyServiceCharges, tenure and  Total Charges 
#' are correlated. 
#' 
#' ## Bar plots of categorical variables
#' 
## ------------------------------------------------------------------------

table(df_churn$gender)
#pie(df_churn$gender)

ggplot(df_churn, aes(x=gender)) + ggtitle("Gender") + xlab("Gender") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + 
  ylab("Percentage") + coord_flip() + theme_minimal()
ggplot(df_churn, aes(x=Partner)) + ggtitle("Partner") + xlab("Partner") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()

ggplot(df_churn, aes(x=Dependents)) + ggtitle("Dependents") + 
  xlab("Dependents") +geom_bar(aes(y = 100*(..count..)/sum(..count..)),
  width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()


#' 
#' We can notice "gender" more or less equal in this detaset and Most 
#' customer did not dependent others.
#' 
## ------------------------------------------------------------------------
plot4 <- ggplot(df_churn, aes(x=CallService)) + ggtitle("Call Service") + xlab("Call Service") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
plot5 <- ggplot(df_churn, aes(x=MultipleConnections)) + ggtitle("Multiple Connections") + xlab("Multiple Connections") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
plot6 <- ggplot(df_churn, aes(x=InternetConnection)) + ggtitle("Internet Connection") + xlab("Internet Connection") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
plot7 <- ggplot(df_churn, aes(x=OnlineSecurity)) + ggtitle("Online Security") + xlab("Online Security") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
grid.arrange(plot4, plot5, plot6, plot7, ncol=2)

#' We can notice most customers have call service. The customer who does not have multiple connections is higher the customer who has multiple connections. The customers have mostly Fiber optic connection. Most of the customers does not have online Security.
#' 
## ------------------------------------------------------------------------
plot12 <- ggplot(df_churn, aes(x=OnlineMovies)) + ggtitle("Online Movies") + xlab("Online Movies") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
plot13 <- ggplot(df_churn, aes(x=Agreement)) + ggtitle("Agreement") + xlab("Agreement") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
plot14 <- ggplot(df_churn, aes(x=BillingMethod)) + ggtitle("Billing Method") + xlab("Billing Method") + 
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
plot15 <- ggplot(df_churn, aes(x=PaymentMethod)) + ggtitle("Payment Method") + xlab("Payment Method") +
  geom_bar(aes(y = 100*(..count..)/sum(..count..)), width = 0.5) + ylab("Percentage") + coord_flip() + theme_minimal()
grid.arrange(plot12, plot13, plot14, plot15,  ncol=2)

#' 
#' We can notice how many customers were watching online movies 
#' and most of the customer have a month to month agreement.
#'  Billing method is paperless or not. So paperless billing customers 
#'  are mostly here. The customers can pay their bill in four ways. 
#'  Here we can see a comparison of payment method.
#' 
#' 
#' The Monthly Service Charges, tensure and  Total Charges are 
#' correlated. So one of them will be removed from the model. 
#' We remove Total Charges.
#' 
#' Remove some unnecessary columns before build a model
## ------------------------------------------------------------------------


hist(df_churn$tenure)
table(df_churn$gender)

table(df_churn$gender,df_churn$Churn)
df_churn$tenure <- NULL
#table(df_churn$PaymentMethod)
#table(df_churn$PaymentMethod,df_churn$Churn)
#df_churn$PaymentMethod <- NULL
df_churn$gender <- NULL




#' 
#' Model Development
#' 
#' Split the data into training and testing sets.
#' 
## ------------------------------------------------------------------------

#set.seed(2000)
#intrainX<- createDataPartition(1:50,p=0.7,list=FALSE)

set.seed(2000)
intrain<- createDataPartition(df_churn$Churn,p=0.7,list=FALSE)

training<- df_churn[intrain,]
testing<- df_churn[-intrain,]

#' Confirm the splitting is correct.
#' 
## ------------------------------------------------------------------------
dim(training); dim(testing)


#' 
#' 
#' Training with gini criterion
#' 
## ------------------------------------------------------------------------
#help(rpart)

model_tree <- rpart(Churn ~ ., training, method = "class", control = list(maxdepth = 6))
write.csv(training, "train.csv")

## ------------------------------------------------------------------------
fancyRpartPlot(model_tree)
table(df_churn$Churn)
6728/(6728+5607)

#' 
#' We can notice "Agreement" is the root node and "SeniorCitizen", 
#' "MonthlyServiceCharges", "TotalAmount" are child nodes and "Yes", 
#' "No" are leaf nodes.
#' 
#' At the top, it is the overall probability of customer churn and 
#' non-customer churn.
#' 55 percent of non-customer churn and 45 percent of customer churn 
#' based on "Agreement"
#' 
#' This node asks that the year of agreement One year or Two years. 
#' So 43 percent of the customer is one year or two
#'  years  customer where 74 percent 
#' of non-customer churn category are and 26 percent of churn is.
#' we can notice left side MonthlyServiceCharge < 21 which means 3 
#' percent of the customers are paying monthly less than 21$ with 
#' non-customer churn probability of 97 percent and customer churn
#'probability of 29 percent like this node has been splitting until
#'  to reach the maximum depth of the tree.
#' 
#' 
## ------------------------------------------------------------------------
printcp(model_tree) # display the results 
# complexity paramater
help(printcp)
#' 
#' Root node error is the percent of correctly sorted records 
#' at the first (root)
#'  splitting node. This value can be used to calculate two 
#'  measures of predictive
#'   performance in combination with Rel Error and X Error, 
#'   both of which are 
#'   included in the Pruning Table.
#' 
#' Root Node Error x Rel Error is the resubstitution error rate 
#' (the error rate 
#' computed on the training sample). Root Node Error x X Error 
#' is the cross-validated
#'  error rate, which is a more objective measure of predictive
#'   accuracy. 
#' 
#' The complexity parameter is not the error in that particular node. It is the 
#' amount by which splitting that node improved the relative error. 
#' 
#' So in our example, splitting the original root node dropped the 
#' relative error 
#' from 1.0 to 0.73, so the CP of the root node is 0.26. 
#' The CP of the next node
#'  is only 0.05.like this node is split.
#' 
#' 6th node splitting value is 0.01(which is the default limit for deciding when
#'  to consider splits). So splitting that node only resulted in an improvement 
#'  of 0.01, so the tree building stopped there.
#' 
#' We can notice which variables are used by the model and error while splitting 
#' tree. "xerror" is cross validation error. nsplit is number of split.
#' Rel error (relative error) is 1 - R2 root mean square error. This is the error 
#' for predictions of the data that were used to estimate the model.
#' 
#' Xstd is standard error is estimate error.
#' 
#' More levels in a tree has lower classification error on training, but with an 
#' increased risk of overfitting. Cross-validation error typically increases as 
#' the tree "grows' after the optimal level. The rule of thumb is to select the 
#' lowest level where rel_error _ xstd < xerror.
#' 
#' visualize cross-validation results
## ------------------------------------------------------------------------
plotcp(model_tree) # visualize cross-validation results 

#' 
#' 
#' The dashed line represents the highest cross-validated
#'  error 
#' minus the minimum cross-validated error, plus 
#' 
#' the standard deviation of the error at that tree. 
#' A reasonable choice of cp for pruning is often the leftmost 
#' value where the mean is less than the horizontal line. 
#' In this case, we see that the optimal size of the tree 
#' is 6-10 terminal nodes
#' 
#' Prediction on train dataset
## ------------------------------------------------------------------------
# Predict the values of the test set
predict(model_tree, training)
pred_training <- predict(model_tree, training,type = "class")

help("predict")

#' The confusion matrix
## ------------------------------------------------------------------------
# Construct the confusion matrix: conf
table(training$Churn)
conf_matrix <- table(training$Churn, pred_training)
conf_matrix

(3816+2433)/(3816+2433+894+1492) # 71.30

#' 
#' From the above result, the number of "No" class are correctly classified and misclassified by the model. Here, 3886 observations are correctly classified as "No" and 824 observations are wrongly classified as "Yes".
#' The number of "Yes" class are correctly classified and misclassified by the model. Here, 2549 observations are correctly classified as "Yes" and 1376 observations are wrongly classified as "No".
#' 
#' Prediction on test dataset
## ------------------------------------------------------------------------
# Predict the values of the test set
pred_test <- predict(model_tree, testing, type = "class")

#' The confusion matrix
## ------------------------------------------------------------------------
# Construct the confusion matrix: conf
conf_matrix <- table(testing$Churn, pred_test)
conf_matrix

(1680+991)/(1680+991+338+691)# 71.43

#' 
#' Accuracy
## ------------------------------------------------------------------------
# Print out the accuracy
sum( diag(conf_matrix) ) / sum(conf_matrix)

#' 
#' 
#' ##### Pruning the tree #####
#' 
## ------------------------------------------------------------------------
# Prune the tree: pruned
pruned <- prune(model_tree, cp = 0.02)
printcp(pruned)
## ------------------------------------------------------------------------
# Draw pruned
fancyRpartPlot(pruned)

#' 
#' We can notice "Agreement" is the root node and "SeniorCitizen", "MonthlyServiceCharges" is child node and "Yes", "No" are leaf nodes.
#' 
## ------------------------------------------------------------------------
pred_pruned <- predict(pruned, testing, type = "class")

## ------------------------------------------------------------------------
conf_i <- table(testing$Churn, pred_pruned)
conf_i

#' 
## ------------------------------------------------------------------------
# Print out the accuracy
sum( diag(conf_i) ) / sum(conf_i)

#' 
#' 
#' 
#' Training and Testing with information gain as splitting criterion
#' 
#' Training
#' 
#' Prepruning
## ------------------------------------------------------------------------
# Change the first line of code to use information gain as splitting criterion
model_i <- rpart(Churn ~ ., training, method = "class",
                parms = list(split = "information"),control = 
                  rpart.control(cp = 0, maxdepth = 6,minsplit = 100))

#' 
## ------------------------------------------------------------------------
printcp(model_i) # display the results 


#' 
#' We can notice which variables are used by the model and error while splitting tree.
#' 
#' 
#' visualize cross-validation results
## ------------------------------------------------------------------------
plotcp(model_i) # visualize cross-validation results 

#' 
#' We can notice error has been reducing while splitting increases.
#' 
#' Testing
## ------------------------------------------------------------------------
pred_i <- predict(model_i, testing, type = "class")

#' Confusion matrix for testing
## ------------------------------------------------------------------------
conf_i <- table(testing$Churn, pred_i)
conf_i

## ------------------------------------------------------------------------
# Print out the accuracy
sum( diag(conf_i) ) / sum(conf_i)

#' 
#' 
#' Postpruning
#' 
#' Pruning the tree
## ------------------------------------------------------------------------
# Prune the tree: pruned
pruned_i <- prune(model_i, cp = 0.01)

#' 
## ------------------------------------------------------------------------
# Draw pruned
fancyRpartPlot(pruned_i)

#' 
#' We can notice "Agreement" is the root node and "SeniorCitizen", "MonthlyServiceCharges", "InternetConnection", "TotalAmount" are child nodes and "Yes", "No" are leaf nodes.
#' 
#' 
#' Prediction using pruned tree
## ------------------------------------------------------------------------
pred_pruned <- predict(pruned_i, testing, type = "class")

#' Confusion matrix
## ------------------------------------------------------------------------
confusionMatrix(testing$Churn, pred_pruned)

#' 
#' 
#' Accuracy:
#' Accuracy refers to the closeness of a measured value to a standard or known value. 
#' 
#' For Example : In our example, 73 % value which is predicted by decision tree  is close to actual value.
#' 
#' 95% CI : (0.7233, 0.752):
#' 
#' The accuracy 0.73% lies between 0.7233 and 0.752 in 95% Confidence Interval.
#' 
#' Kappa:
#' 
#' The Kappa statistic (or value) is a metric that compares an Observed Accuracy with an Expected Accuracy (random chance). 
#' 
#' There is not a standardized interpretation of the kappa statistic. According to Wikipedia (citing their paper), Landis and Koch considers 0-0.20 as slight, 0.21-0.40 as fair, 0.41-0.60 as moderate, 0.61-0.80 as substantial, and 0.81-1 as almost perfect.
#' 
#'  In our Example : Kappa value is 0.46 which is moderate perfect
#' 
#' Kappa is an important measure on classifier performance, especially on imbalanced data set.
#'  
#' No Information Rate:
#' The no-information rate is 0.607 in our result. This is the accuracy achievable by always predicting the majority class label. 
#' In this case if asked to predict whether a observation will "No" or "Yes", by always choosing majority class label. we can achieve nearly 60% accuracy on the test set.
#' 
#' P-value:
#' How much better performance has given by the model over no information rate is indicated by P-value.
#' The model has give 2% better performance than no information rate. 
#' TP - True Positive
#' TN - True Negative
#' FP - False Positive
#' FN - False Negative
#' 
#' Precision or Positive Predictive Value: 
#' What percentage of predicted "Yes" was correct?
#' TP / (TP + FP)
#' 82% percentage of predicted "Yes" was correct.
#'  
#' Sensitivity or Recall:
#' What percentage of all "Yes" was correctly predicted?
#' TP / (TP + FN)
#' 73% percentage of all "Yes" was correctly predicted.
#' 
#' Specificity:
#' What percentage of all "No" was correctly predicted?
#' TN / ( TN + FP )
#' 74% percentage of all "No" was correctly predicted
#' 
#' Negative Predictive Value:
#' What percentage of "No" was correctly predicted in the total number of "No"?
#' TN / (TN + FN)
#' 64% percentage of "No" was correctly predicted in the total number of "No".
#' 
#' Balanced Accuracy:
#' If A dataset contains a balanced class, we can consider regular accuracy value as a performance value of the model.
#' If A dataset contains an imbalanced class, we should consider balanced accuracy value as a performance value of the model.
#' 
#' Accuracy formula :
#' (TN + TP) /  (TN + FP + FN + TP)
#' Balanced Accuracy: 
#' (Sensitivity + Specificity)/2
#' 
#' Balanced accuracy was 73.91%.
#' 
#' Detection Rate:
#' Detection rate (DR) and sensitivity are synonyms (the proportion of affected individuals with a positive test result). An advantage of 'DR' is that it avoids confusion as 'sensitivity' has a different meaning in analytical biochemistry.
#' Detection Rate == Sensitivity == TP/(TP+FN)
#' 
#' Prevalence:
#' Prevalence in epidemiology is the proportion of a particular population found to be affected by a medical condition (typically a disease or a risk factor such as smoking or seat-belt use).
#' Prevalence= Actual "Yes" /Total = ( FN+TP)/(TP+FP+TN+FN)
#' 
#' In our example, the proportion of a particular population found to be affected by something
#' Prevalence for "yes" was 60.70%
#' 
#' Detection Prevalence:
#' What percentage of the full sample was predicted as "Yes"?
#' Detection Prevalence = (TP+FP) / (TP+FP+TN+FN)
#' 54% percentage of the full sample was predicted "Yes".
#' 
#' 
#' ROC Curve
#' 
## ------------------------------------------------------------------------
all_probs <- predict(pruned_i, testing, type = "prob")

all_probs[,2]
#' 
## ------------------------------------------------------------------------
probs <- all_probs[, 2]

## ------------------------------------------------------------------------
# Make a prediction object: pred
pred_test <- prediction(probs, testing$Churn)

# Make a performance object: perf
perf <- performance(pred_test, "tpr", "fpr")
plot(perf , col="blue")
abline(a=0,b=1)

names(training)

#' 
#' 
#' Basically, it has been drawn from the confusion matrix. We can notice the model has moderate accuracy. 
#' If the blue curve covered more area, we could have said that the model performs well.
