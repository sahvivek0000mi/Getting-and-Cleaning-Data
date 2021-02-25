# Load packages

library(dplyr)

# Create data folder 

if(!file.exists("./data"))
{
        dir.create("./data")
}

# Download data and unzip

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

zipfile <- "./data/dataset.zip"
outfile <- "./data"

if(!file.exists("./data/UCI HAR Dataset")){
        download.file(url, zipfile, method = "curl")
        unzip(zipfile, exdir = outfile)
        file.remove("./data/dataset.zip")
}


# Load data
## load lables
activity_names <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
feature_names <- read.table("./data/UCI HAR Dataset/features.txt")

### add col names
colnames(activity_names) <- c("classlables", "activitynames")
colnames(feature_names) <- c("n", "features")

## load test data
readings_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
activities_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

## load train data
readings_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
activities_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

### add col names
#test
colnames(readings_test) <- c(feature_names$features)
colnames(activities_test) <- c("activity")
colnames(subject_test) <- c("subject")

#train
colnames(readings_train) <- c(feature_names$features)
colnames(activities_train) <- c("activity")
colnames(subject_train) <- c("subject")

# 1. Merges the training and the test sets to create one data set.
readings <- rbind(readings_test, readings_train)
rm(readings_test, readings_train)

activities <- rbind(activities_test, activities_train)
rm(activities_test, activities_train)

subject <- rbind(subject_test, subject_train)
rm(subject_test, subject_train)

dataset <- cbind(subject, activities, readings)
rm(subject, activities, readings)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

datasetextract <- dataset %>% 
        select(subject, activity, matches("std\\(|mean\\("))

# 3. Uses descriptive activity names to name the activities in the data set

datasetextract$activity <- activity_names[datasetextract$activity, 2]
datasetextract$activity <- as.factor(datasetextract$activity)

# 4. Appropriately labels the data set with descriptive variable names.

names(datasetextract) <- gsub("-", "", names(datasetextract))
names(datasetextract) <- gsub("^t", "Time_", names(datasetextract))
names(datasetextract) <- gsub("^f", "Frequency_", names(datasetextract))
names(datasetextract) <- gsub("Body|BodyBody", "Body_", names(datasetextract)) 
names(datasetextract) <- gsub("Acc", "Acceleration_", names(datasetextract))
names(datasetextract) <- gsub("Gravity", "Gravity_", names(datasetextract))
names(datasetextract) <- gsub("Gyro", "Gyroscope_", names(datasetextract))
names(datasetextract) <- gsub("Jerk", "Jerk_", names(datasetextract))
names(datasetextract) <- gsub("Mag", "Magnitude_", names(datasetextract))
names(datasetextract) <- gsub("std\\(\\)", "standard_deviation_", names(datasetextract))
names(datasetextract) <- gsub("mean\\(\\)", "mean ", names(datasetextract))
names(datasetextract) <- gsub("X", "x-axis", names(datasetextract))
names(datasetextract) <- gsub("Y", "y-axis", names(datasetextract))
names(datasetextract) <- gsub("Z", "z-axis", names(datasetextract))
str(datasetextract)

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of 
# each variable for each activity and each subject.

tidydf <- datasetextract %>%
        group_by(subject, activity) %>%
        summarise_all(mean)
str(tidydf)
tidydf
