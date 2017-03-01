##########################################################################################################

## Coursera Getting and Cleaning Data Course Project

# run_analysis.R File Description:

# This script will perform the following steps on the UCI HAR Dataset downloaded from 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

##########################################################################################################

## With Help from Author Pradeep K. Pant

## Load require packages to run script 
library(downloader)
library(plyr);
library(knitr)

##  Download the dataset and unzip folder

# Check if directory already exists?
if(!file.exists("./projectData")){
  dir.create("./projectData")
}

Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# Check if zip has already been downloaded in projectData directory?
if(!file.exists("./projectData/project_Dataset.zip")){
  download.file(Url,destfile="./projectData/project_Dataset.zip",mode = "wb")
}

# Check if zip has already been unzipped?
if(!file.exists("./projectData/UCI HAR Dataset")){
  unzip(zipfile="./projectData/project_Dataset.zip",exdir="./projectData")
}

## List all the files of UCI HAR Dataset folder
path <- file.path("./projectData" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)
## The files that will be used to load data are listed as follows:
# test/subject_test.txt
# test/X_test.txt
# test/y_test.txt
# train/subject_train.txt
# train/X_train.txt
# train/y_train.txt

## Load activity, subject and feature info.
# Read data from the files into the variables

# I. Read the Activity files
ActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)

# II. Read the Subject files
SubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

# III. Read Fearures files
FeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

# Test: Check properties

##str(ActivityTest)
##str(ActivityTrain)
##str(SubjectTrain)
##str(SubjectTest)
##str(FeaturesTest)
##str(FeaturesTrain)

## Part 1: Merges the training and the test sets to create one data set.

# I.Concatenate the data tables by rows
dataSubject <- rbind(SubjectTrain, SubjectTest)
dataActivity<- rbind(ActivityTrain, ActivityTest)
dataFeatures<- rbind(FeaturesTrain, FeaturesTest)

# II. Set names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

# III. Merge columns to get the data frame Data for all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

## Part 2: Extracts only the measurements on the mean and standard deviation for each measurement.

# I. Subset Name of Features by measurements on the mean and standard deviation
# i.e taken Names of Features with "mean()" or "std()"
# Extract using grep
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

# II. Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

# III. Test : Check the structures of the data frame Data
# str(Data)

## Part 3: Uses descriptive activity names to name the activities in the data set

# I. Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)

# II. Factorize Variale activity in the data frame Data using descriptive activity names
Data$activity<-factor(Data$activity,labels=activityLabels[,2])

# Test Print
head(Data$activity,30)

## Part 4: Appropriately label the data set with descriptive variable names

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

# Test Print
names(Data)

## Part 5: Create an independent tidy data set

newData<-aggregate(. ~subject + activity, Data, mean)
newData<-newData[order(newData$subject,newData$activity),]
write.table(newData, file = "tidydata.txt",row.name=FALSE,quote = FALSE, sep = '\t')
