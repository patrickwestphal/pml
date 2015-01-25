write-up 
========================================================

## reading and cleaning data

After having had a look at the data I found that there are 'NA' strings representing NA values and some 'division by zero' remarks that should also be handled as NA values.
Moreover I found that there are columns only having NA values and a lot of columns with about 98% of their values being NA.
Both types of columns were removed during data cleansing.
Besides this I removed the first column only containing running numbers, the two timestamp columns, the user name column and the yes/no factor column.


```r
# read the data
tdata <- read.csv('data/pml-training.csv', na.strings=c('NA', '#DIV/0!'), strip.white=T)

len <- nrow(tdata)

# remove columns that contain only NAs
onlyNAsIdxs <- integer()
for (c in 1:ncol(tdata)) {
    if(sum(is.na(tdata[, c])) == len) {
        onlyNAsIdxs <- append(onlyNAsIdxs, c)
    }
}
onlyNAsIdxs
```

```
## [1]  14  17  89  92 127 130
```

```r
tdata <- tdata[, -onlyNAsIdxs]
dim(tdata)
```

```
## [1] 19622   154
```

```r
# remove columns that contain too many NA values (more that 70%)
tooMuchNAsIdxs = integer(); threshold <- .3
for (c in 1:ncol(tdata)) {
    ratio <- sum(is.na(tdata[, c]))/len
    if (ratio > (1-threshold)) {
        tooMuchNAsIdxs <- append(tooMuchNAsIdxs, c)
    }
}
tooMuchNAsIdxs
```

```
##  [1]  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28
## [18]  29  30  31  32  33  34  48  49  50  51  52  53  54  55  56  57  67
## [35]  68  69  70  71  72  73  74  75  76  77  78  79  80  81  85  86  87
## [52]  88  89  90  91  92  93  94  95  96  97  99 100 101 102 103 104 105
## [69] 106 107 108 121 122 123 124 125 126 127 128 129 130 131 132 133 135
## [86] 136 137 138 139 140 141 142 143 144
```

```r
tdata <- tdata[, -tooMuchNAsIdxs]

# remove col 1 since it contains only running counter, col 2 (user names),
# 3, 5 (both timestamps), 6 (yes/no factor)
tdata <- tdata[, -c(1, 2, 3, 5, 6)]
```

## training

For the training I decided to use random forests and see how well this approach does.
I stuck mostly with the default parameter since the result seemed already promising.


```r
library(caret)
```

```
## Loading required package: lattice
## Loading required package: ggplot2
```

```r
inTrain <- createDataPartition(y=tdata$classe, p=.7, list=F)
training <- tdata[inTrain, ]
testing <- tdata[-inTrain, ]

library(randomForest)
```

```
## randomForest 4.6-10
## Type rfNews() to see new features/changes/bug fixes.
```

```r
set.seed(23)
# random forest-based training
rfTrain <- randomForest(classe ~ ., data=training)
trainPrediction <- predict(rfTrain, training)
confusionMatrix(training$classe, trainPrediction)
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    A    B    C    D    E
##          A 3906    0    0    0    0
##          B    0 2658    0    0    0
##          C    0    0 2396    0    0
##          D    0    0    0 2252    0
##          E    0    0    0    0 2525
## 
## Overall Statistics
##                                      
##                Accuracy : 1          
##                  95% CI : (0.9997, 1)
##     No Information Rate : 0.2843     
##     P-Value [Acc > NIR] : < 2.2e-16  
##                                      
##                   Kappa : 1          
##  Mcnemar's Test P-Value : NA         
## 
## Statistics by Class:
## 
##                      Class: A Class: B Class: C Class: D Class: E
## Sensitivity            1.0000   1.0000   1.0000   1.0000   1.0000
## Specificity            1.0000   1.0000   1.0000   1.0000   1.0000
## Pos Pred Value         1.0000   1.0000   1.0000   1.0000   1.0000
## Neg Pred Value         1.0000   1.0000   1.0000   1.0000   1.0000
## Prevalence             0.2843   0.1935   0.1744   0.1639   0.1838
## Detection Rate         0.2843   0.1935   0.1744   0.1639   0.1838
## Detection Prevalence   0.2843   0.1935   0.1744   0.1639   0.1838
## Balanced Accuracy      1.0000   1.0000   1.0000   1.0000   1.0000
```

Since the accuracy on the training data was perfect I took this as an indication of overfitting.
So I expected the accuracy on the validation data to be lower which also means that the out of sample error will be greater than zero.

## validation on test set

Validating the training results on the test set showed an overall accuracy of about 0.995 which means that the out of sample error should be about 0.5%.

```r
set.seed(23)
# validation on test set
testPrediction <- predict(rfTrain, testing)
confusionMatrix(testing$classe, testPrediction)
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    A    B    C    D    E
##          A 1674    0    0    0    0
##          B    2 1136    1    0    0
##          C    0    2 1024    0    0
##          D    0    0    6  958    0
##          E    0    0    0    2 1080
## 
## Overall Statistics
##                                           
##                Accuracy : 0.9978          
##                  95% CI : (0.9962, 0.9988)
##     No Information Rate : 0.2848          
##     P-Value [Acc > NIR] : < 2.2e-16       
##                                           
##                   Kappa : 0.9972          
##  Mcnemar's Test P-Value : NA              
## 
## Statistics by Class:
## 
##                      Class: A Class: B Class: C Class: D Class: E
## Sensitivity            0.9988   0.9982   0.9932   0.9979   1.0000
## Specificity            1.0000   0.9994   0.9996   0.9988   0.9996
## Pos Pred Value         1.0000   0.9974   0.9981   0.9938   0.9982
## Neg Pred Value         0.9995   0.9996   0.9986   0.9996   1.0000
## Prevalence             0.2848   0.1934   0.1752   0.1631   0.1835
## Detection Rate         0.2845   0.1930   0.1740   0.1628   0.1835
## Detection Prevalence   0.2845   0.1935   0.1743   0.1638   0.1839
## Balanced Accuracy      0.9994   0.9988   0.9964   0.9983   0.9998
```
