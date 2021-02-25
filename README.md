Getting and Cleaning Data Course Project
================
Liam
25/02/2021

This readme document liblcontains a detailed explanation of the data and
the code used to tidy the data. The same code can be found in
‘run\_analysis.R’ in this repo.

## Overview of the data

The zip file contains data from experiments that have been carried out
with a group of **30 volunteers** within an age bracket of 19-48 years.
Each person performed **six activities** (WALKING, WALKING\_UPSTAIRS,
WALKING\_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone
(Samsung Galaxy S II) on the waist. Using its embedded accelerometer and
gyroscope, we captured 3-axial linear acceleration and 3-axial angular
velocity at a constant rate of 50Hz. The obtained dataset has been
randomly partitioned into two sets, where **70% (21)** of the volunteers
was selected for generating the **training data** and **30% (9)** the
**test data**

The folder (test and training) consists of \* `X_test.txt`/`train.txt`:
which contains the *readings* \* `y_test.txt`/`train.txt`: whhich
contains *activity* numbers corosponding to the data set \*
`subject_test.txt`/`train.txt` which contains the *subject* number
corosponding to the data set

Label files are also provided:

  - `features.txt`: List of all *features* of the data sets.
  - `activity_labels.txt`: Links the activity numbers with their
    activity name.

The inertial signals were not looked at for the purposes of the analysis

## Preparing the data

Load libraries and set up the working environment

``` r
# Load packages

library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
# Create data folder 

if(!file.exists("./data"))
{
        dir.create("./data")
}
```

Download file and unzip

``` r
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

zipfile <- "./data/dataset.zip"
outfile <- "./data"

if(!file.exists("./data/UCI HAR Dataset")){
        download.file(url, zipfile, method = "curl")
        unzip(zipfile, exdir = outfile)
        file.remove("./data/dataset.zip")
}
```

Read the source data and add the headers. The readings variable names
were added using the feature\_names.txt file

``` r
## load lables sets
activity_names <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
feature_names <- read.table("./data/UCI HAR Dataset/features.txt")
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
colnames(readings_test) <- c(feature_names$features)
colnames(activities_test) <- c("activity")
colnames(subject_test) <- c("subject")
colnames(readings_train) <- c(feature_names$features)
colnames(activities_train) <- c("activity")
colnames(subject_train) <- c("subject")
```

## Tidying the data

This section covers the code that :

  - Merges the training and the test sets to create one data set.
  - Extracts only the measurements on the mean and standard deviation
    for each measurement.
  - Uses descriptive activity names to name the activities in the data
    set
  - Appropriately labels the data set with descriptive variable names.
  - From the data set in step 4, creates a second, independent tidy data
    set with the average of each variable for each activity and each
    subject.

### 1\. Merges the training and the test sets to create one data set.

The data from X\_test/train.txt contains the ‘readings’. Here the the
corosponding ‘readings’ datarames are merged row wise with r bind. *The
source data frames are removed from the global environment as they are
no longer needed and only clutter the workspace.*

``` r
readings <- rbind(readings_test, readings_train)
rm(readings_test, readings_train)
```

The same is done for the corosponding activity labels and subject labels

``` r
activities <- rbind(activities_test, activities_train)
rm(activities_test, activities_train)

subject <- rbind(subject_test, subject_train)
rm(subject_test, subject_train)
```

Now we have 3 data frames, the subject ‘lables’, the activity ‘labels’
and the readings for each individual observation. Each of these
dataframes contains 10299 individual observations.

The *subject*, *activities* and *readings* dataframes can now be merged
into one single tidy dataset

``` r
dataset <- cbind(subject, activities, readings)
rm(subject, activities, readings)
```

### 2\. Extracts only the measurements on the mean and standard deviation for each measurement.

Next the columns on the **mean** and **std deviation** for each
measurment is extracted.

``` r
datasetextract <- dataset %>% 
        select(subject, activity, matches("std\\(|mean\\("))
```

### 3\. Uses descriptive activity names to name the activities in the data set

Next the labels for the activities are updated by using the data
obtained from ‘activity\_names.txt’. This method uses subsetting as it
is the simpilest method in this scenario.

``` r
datasetextract$activity <- activity_names[datasetextract$activity, 2]
```

### 4\. Appropriately labels the data set with descriptive variable names.

Here the lables of the data set are renamed `gsub()` using *overly*
descriptive names that are probably over the top for the real world but
atleast you wont get confused. Make sure all the names were changed
correctly with `str()`

``` r
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
```

## 5\. From the data set in step 4, creates a second, independent tidy data set

This tidy dataset should consist of the average of each variable for
each activity and each subject.

using `dplyr::group_by` the data is first grouped by activity and then
by subject. The grouped data is the parsed to `summarise_all` to find
the mean of of **all** the variables for each activity completed by each
subject. Then the data is looked at and declared not only tidy, but
pretty too

``` r
tidydf <- datasetextract %>%
        group_by(activity, subject) %>%
        summarise_all(mean)
str(tidydf)
```

    ## tibble [180 x 68] (S3: grouped_df/tbl_df/tbl/data.frame)
    ##  $ activity                                                      : chr [1:180] "LAYING" "LAYING" "LAYING" "LAYING" ...
    ##  $ subject                                                       : int [1:180] 1 2 3 4 5 6 7 8 9 10 ...
    ##  $ Time_Body_Acceleration_mean x-axis                            : num [1:180] 0.222 0.281 0.276 0.264 0.278 ...
    ##  $ Time_Body_Acceleration_mean y-axis                            : num [1:180] -0.0405 -0.0182 -0.019 -0.015 -0.0183 ...
    ##  $ Time_Body_Acceleration_mean z-axis                            : num [1:180] -0.113 -0.107 -0.101 -0.111 -0.108 ...
    ##  $ Time_Body_Acceleration_standard_deviation_x-axis              : num [1:180] -0.928 -0.974 -0.983 -0.954 -0.966 ...
    ##  $ Time_Body_Acceleration_standard_deviation_y-axis              : num [1:180] -0.837 -0.98 -0.962 -0.942 -0.969 ...
    ##  $ Time_Body_Acceleration_standard_deviation_z-axis              : num [1:180] -0.826 -0.984 -0.964 -0.963 -0.969 ...
    ##  $ Time_Gravity_Acceleration_mean x-axis                         : num [1:180] -0.249 -0.51 -0.242 -0.421 -0.483 ...
    ##  $ Time_Gravity_Acceleration_mean y-axis                         : num [1:180] 0.706 0.753 0.837 0.915 0.955 ...
    ##  $ Time_Gravity_Acceleration_mean z-axis                         : num [1:180] 0.446 0.647 0.489 0.342 0.264 ...
    ##  $ Time_Gravity_Acceleration_standard_deviation_x-axis           : num [1:180] -0.897 -0.959 -0.983 -0.921 -0.946 ...
    ##  $ Time_Gravity_Acceleration_standard_deviation_y-axis           : num [1:180] -0.908 -0.988 -0.981 -0.97 -0.986 ...
    ##  $ Time_Gravity_Acceleration_standard_deviation_z-axis           : num [1:180] -0.852 -0.984 -0.965 -0.976 -0.977 ...
    ##  $ Time_Body_Acceleration_Jerk_mean x-axis                       : num [1:180] 0.0811 0.0826 0.077 0.0934 0.0848 ...
    ##  $ Time_Body_Acceleration_Jerk_mean y-axis                       : num [1:180] 0.00384 0.01225 0.0138 0.00693 0.00747 ...
    ##  $ Time_Body_Acceleration_Jerk_mean z-axis                       : num [1:180] 0.01083 -0.0018 -0.00436 -0.00641 -0.00304 ...
    ##  $ Time_Body_Acceleration_Jerk_standard_deviation_x-axis         : num [1:180] -0.958 -0.986 -0.981 -0.978 -0.983 ...
    ##  $ Time_Body_Acceleration_Jerk_standard_deviation_y-axis         : num [1:180] -0.924 -0.983 -0.969 -0.942 -0.965 ...
    ##  $ Time_Body_Acceleration_Jerk_standard_deviation_z-axis         : num [1:180] -0.955 -0.988 -0.982 -0.979 -0.985 ...
    ##  $ Time_Body_Gyroscope_mean x-axis                               : num [1:180] -0.01655 -0.01848 -0.02082 -0.00923 -0.02189 ...
    ##  $ Time_Body_Gyroscope_mean y-axis                               : num [1:180] -0.0645 -0.1118 -0.0719 -0.093 -0.0799 ...
    ##  $ Time_Body_Gyroscope_mean z-axis                               : num [1:180] 0.149 0.145 0.138 0.17 0.16 ...
    ##  $ Time_Body_Gyroscope_standard_deviation_x-axis                 : num [1:180] -0.874 -0.988 -0.975 -0.973 -0.979 ...
    ##  $ Time_Body_Gyroscope_standard_deviation_y-axis                 : num [1:180] -0.951 -0.982 -0.977 -0.961 -0.977 ...
    ##  $ Time_Body_Gyroscope_standard_deviation_z-axis                 : num [1:180] -0.908 -0.96 -0.964 -0.962 -0.961 ...
    ##  $ Time_Body_Gyroscope_Jerk_mean x-axis                          : num [1:180] -0.107 -0.102 -0.1 -0.105 -0.102 ...
    ##  $ Time_Body_Gyroscope_Jerk_mean y-axis                          : num [1:180] -0.0415 -0.0359 -0.039 -0.0381 -0.0404 ...
    ##  $ Time_Body_Gyroscope_Jerk_mean z-axis                          : num [1:180] -0.0741 -0.0702 -0.0687 -0.0712 -0.0708 ...
    ##  $ Time_Body_Gyroscope_Jerk_standard_deviation_x-axis            : num [1:180] -0.919 -0.993 -0.98 -0.975 -0.983 ...
    ##  $ Time_Body_Gyroscope_Jerk_standard_deviation_y-axis            : num [1:180] -0.968 -0.99 -0.987 -0.987 -0.984 ...
    ##  $ Time_Body_Gyroscope_Jerk_standard_deviation_z-axis            : num [1:180] -0.958 -0.988 -0.983 -0.984 -0.99 ...
    ##  $ Time_Body_Acceleration_Magnitude_mean                         : num [1:180] -0.842 -0.977 -0.973 -0.955 -0.967 ...
    ##  $ Time_Body_Acceleration_Magnitude_standard_deviation_          : num [1:180] -0.795 -0.973 -0.964 -0.931 -0.959 ...
    ##  $ Time_Gravity_Acceleration_Magnitude_mean                      : num [1:180] -0.842 -0.977 -0.973 -0.955 -0.967 ...
    ##  $ Time_Gravity_Acceleration_Magnitude_standard_deviation_       : num [1:180] -0.795 -0.973 -0.964 -0.931 -0.959 ...
    ##  $ Time_Body_Acceleration_Jerk_Magnitude_mean                    : num [1:180] -0.954 -0.988 -0.979 -0.97 -0.98 ...
    ##  $ Time_Body_Acceleration_Jerk_Magnitude_standard_deviation_     : num [1:180] -0.928 -0.986 -0.976 -0.961 -0.977 ...
    ##  $ Time_Body_Gyroscope_Magnitude_mean                            : num [1:180] -0.875 -0.95 -0.952 -0.93 -0.947 ...
    ##  $ Time_Body_Gyroscope_Magnitude_standard_deviation_             : num [1:180] -0.819 -0.961 -0.954 -0.947 -0.958 ...
    ##  $ Time_Body_Gyroscope_Jerk_Magnitude_mean                       : num [1:180] -0.963 -0.992 -0.987 -0.985 -0.986 ...
    ##  $ Time_Body_Gyroscope_Jerk_Magnitude_standard_deviation_        : num [1:180] -0.936 -0.99 -0.983 -0.983 -0.984 ...
    ##  $ Frequency_Body_Acceleration_mean x-axis                       : num [1:180] -0.939 -0.977 -0.981 -0.959 -0.969 ...
    ##  $ Frequency_Body_Acceleration_mean y-axis                       : num [1:180] -0.867 -0.98 -0.961 -0.939 -0.965 ...
    ##  $ Frequency_Body_Acceleration_mean z-axis                       : num [1:180] -0.883 -0.984 -0.968 -0.968 -0.977 ...
    ##  $ Frequency_Body_Acceleration_standard_deviation_x-axis         : num [1:180] -0.924 -0.973 -0.984 -0.952 -0.965 ...
    ##  $ Frequency_Body_Acceleration_standard_deviation_y-axis         : num [1:180] -0.834 -0.981 -0.964 -0.946 -0.973 ...
    ##  $ Frequency_Body_Acceleration_standard_deviation_z-axis         : num [1:180] -0.813 -0.985 -0.963 -0.962 -0.966 ...
    ##  $ Frequency_Body_Acceleration_Jerk_mean x-axis                  : num [1:180] -0.957 -0.986 -0.981 -0.979 -0.983 ...
    ##  $ Frequency_Body_Acceleration_Jerk_mean y-axis                  : num [1:180] -0.922 -0.983 -0.969 -0.944 -0.965 ...
    ##  $ Frequency_Body_Acceleration_Jerk_mean z-axis                  : num [1:180] -0.948 -0.986 -0.979 -0.975 -0.983 ...
    ##  $ Frequency_Body_Acceleration_Jerk_standard_deviation_x-axis    : num [1:180] -0.964 -0.987 -0.983 -0.98 -0.986 ...
    ##  $ Frequency_Body_Acceleration_Jerk_standard_deviation_y-axis    : num [1:180] -0.932 -0.985 -0.971 -0.944 -0.966 ...
    ##  $ Frequency_Body_Acceleration_Jerk_standard_deviation_z-axis    : num [1:180] -0.961 -0.989 -0.984 -0.98 -0.986 ...
    ##  $ Frequency_Body_Gyroscope_mean x-axis                          : num [1:180] -0.85 -0.986 -0.97 -0.967 -0.976 ...
    ##  $ Frequency_Body_Gyroscope_mean y-axis                          : num [1:180] -0.952 -0.983 -0.978 -0.972 -0.978 ...
    ##  $ Frequency_Body_Gyroscope_mean z-axis                          : num [1:180] -0.909 -0.963 -0.962 -0.961 -0.963 ...
    ##  $ Frequency_Body_Gyroscope_standard_deviation_x-axis            : num [1:180] -0.882 -0.989 -0.976 -0.975 -0.981 ...
    ##  $ Frequency_Body_Gyroscope_standard_deviation_y-axis            : num [1:180] -0.951 -0.982 -0.977 -0.956 -0.977 ...
    ##  $ Frequency_Body_Gyroscope_standard_deviation_z-axis            : num [1:180] -0.917 -0.963 -0.967 -0.966 -0.963 ...
    ##  $ Frequency_Body_Acceleration_Magnitude_mean                    : num [1:180] -0.862 -0.975 -0.966 -0.939 -0.962 ...
    ##  $ Frequency_Body_Acceleration_Magnitude_standard_deviation_     : num [1:180] -0.798 -0.975 -0.968 -0.937 -0.963 ...
    ##  $ Frequency_Body_Acceleration_Jerk_Magnitude_mean               : num [1:180] -0.933 -0.985 -0.976 -0.962 -0.977 ...
    ##  $ Frequency_Body_Acceleration_Jerk_Magnitude_standard_deviation_: num [1:180] -0.922 -0.985 -0.975 -0.958 -0.976 ...
    ##  $ Frequency_Body_Gyroscope_Magnitude_mean                       : num [1:180] -0.862 -0.972 -0.965 -0.962 -0.968 ...
    ##  $ Frequency_Body_Gyroscope_Magnitude_standard_deviation_        : num [1:180] -0.824 -0.961 -0.955 -0.947 -0.959 ...
    ##  $ Frequency_Body_Gyroscope_Jerk_Magnitude_mean                  : num [1:180] -0.942 -0.99 -0.984 -0.984 -0.985 ...
    ##  $ Frequency_Body_Gyroscope_Jerk_Magnitude_standard_deviation_   : num [1:180] -0.933 -0.989 -0.983 -0.983 -0.983 ...
    ##  - attr(*, "groups")= tibble [6 x 2] (S3: tbl_df/tbl/data.frame)
    ##   ..$ activity: chr [1:6] "LAYING" "SITTING" "STANDING" "WALKING" ...
    ##   ..$ .rows   : list<int> [1:6] 
    ##   .. ..$ : int [1:30] 1 2 3 4 5 6 7 8 9 10 ...
    ##   .. ..$ : int [1:30] 31 32 33 34 35 36 37 38 39 40 ...
    ##   .. ..$ : int [1:30] 61 62 63 64 65 66 67 68 69 70 ...
    ##   .. ..$ : int [1:30] 91 92 93 94 95 96 97 98 99 100 ...
    ##   .. ..$ : int [1:30] 121 122 123 124 125 126 127 128 129 130 ...
    ##   .. ..$ : int [1:30] 151 152 153 154 155 156 157 158 159 160 ...
    ##   .. ..@ ptype: int(0) 
    ##   ..- attr(*, ".drop")= logi TRUE

``` r
tidydf
```

    ## # A tibble: 180 x 68
    ## # Groups:   activity [6]
    ##    activity subject `Time_Body_Acce~ `Time_Body_Acce~ `Time_Body_Acce~
    ##    <chr>      <int>            <dbl>            <dbl>            <dbl>
    ##  1 LAYING         1            0.222          -0.0405           -0.113
    ##  2 LAYING         2            0.281          -0.0182           -0.107
    ##  3 LAYING         3            0.276          -0.0190           -0.101
    ##  4 LAYING         4            0.264          -0.0150           -0.111
    ##  5 LAYING         5            0.278          -0.0183           -0.108
    ##  6 LAYING         6            0.249          -0.0103           -0.133
    ##  7 LAYING         7            0.250          -0.0204           -0.101
    ##  8 LAYING         8            0.261          -0.0212           -0.102
    ##  9 LAYING         9            0.259          -0.0205           -0.108
    ## 10 LAYING        10            0.280          -0.0243           -0.117
    ## # ... with 170 more rows, and 63 more variables:
    ## #   `Time_Body_Acceleration_standard_deviation_x-axis` <dbl>,
    ## #   `Time_Body_Acceleration_standard_deviation_y-axis` <dbl>,
    ## #   `Time_Body_Acceleration_standard_deviation_z-axis` <dbl>,
    ## #   `Time_Gravity_Acceleration_mean x-axis` <dbl>,
    ## #   `Time_Gravity_Acceleration_mean y-axis` <dbl>,
    ## #   `Time_Gravity_Acceleration_mean z-axis` <dbl>,
    ## #   `Time_Gravity_Acceleration_standard_deviation_x-axis` <dbl>,
    ## #   `Time_Gravity_Acceleration_standard_deviation_y-axis` <dbl>,
    ## #   `Time_Gravity_Acceleration_standard_deviation_z-axis` <dbl>,
    ## #   `Time_Body_Acceleration_Jerk_mean x-axis` <dbl>,
    ## #   `Time_Body_Acceleration_Jerk_mean y-axis` <dbl>,
    ## #   `Time_Body_Acceleration_Jerk_mean z-axis` <dbl>,
    ## #   `Time_Body_Acceleration_Jerk_standard_deviation_x-axis` <dbl>,
    ## #   `Time_Body_Acceleration_Jerk_standard_deviation_y-axis` <dbl>,
    ## #   `Time_Body_Acceleration_Jerk_standard_deviation_z-axis` <dbl>,
    ## #   `Time_Body_Gyroscope_mean x-axis` <dbl>, `Time_Body_Gyroscope_mean
    ## #   y-axis` <dbl>, `Time_Body_Gyroscope_mean z-axis` <dbl>,
    ## #   `Time_Body_Gyroscope_standard_deviation_x-axis` <dbl>,
    ## #   `Time_Body_Gyroscope_standard_deviation_y-axis` <dbl>,
    ## #   `Time_Body_Gyroscope_standard_deviation_z-axis` <dbl>,
    ## #   `Time_Body_Gyroscope_Jerk_mean x-axis` <dbl>,
    ## #   `Time_Body_Gyroscope_Jerk_mean y-axis` <dbl>,
    ## #   `Time_Body_Gyroscope_Jerk_mean z-axis` <dbl>,
    ## #   `Time_Body_Gyroscope_Jerk_standard_deviation_x-axis` <dbl>,
    ## #   `Time_Body_Gyroscope_Jerk_standard_deviation_y-axis` <dbl>,
    ## #   `Time_Body_Gyroscope_Jerk_standard_deviation_z-axis` <dbl>,
    ## #   `Time_Body_Acceleration_Magnitude_mean ` <dbl>,
    ## #   Time_Body_Acceleration_Magnitude_standard_deviation_ <dbl>,
    ## #   `Time_Gravity_Acceleration_Magnitude_mean ` <dbl>,
    ## #   Time_Gravity_Acceleration_Magnitude_standard_deviation_ <dbl>,
    ## #   `Time_Body_Acceleration_Jerk_Magnitude_mean ` <dbl>,
    ## #   Time_Body_Acceleration_Jerk_Magnitude_standard_deviation_ <dbl>,
    ## #   `Time_Body_Gyroscope_Magnitude_mean ` <dbl>,
    ## #   Time_Body_Gyroscope_Magnitude_standard_deviation_ <dbl>,
    ## #   `Time_Body_Gyroscope_Jerk_Magnitude_mean ` <dbl>,
    ## #   Time_Body_Gyroscope_Jerk_Magnitude_standard_deviation_ <dbl>,
    ## #   `Frequency_Body_Acceleration_mean x-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_mean y-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_mean z-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_standard_deviation_x-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_standard_deviation_y-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_standard_deviation_z-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_Jerk_mean x-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_Jerk_mean y-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_Jerk_mean z-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_Jerk_standard_deviation_x-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_Jerk_standard_deviation_y-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_Jerk_standard_deviation_z-axis` <dbl>,
    ## #   `Frequency_Body_Gyroscope_mean x-axis` <dbl>,
    ## #   `Frequency_Body_Gyroscope_mean y-axis` <dbl>,
    ## #   `Frequency_Body_Gyroscope_mean z-axis` <dbl>,
    ## #   `Frequency_Body_Gyroscope_standard_deviation_x-axis` <dbl>,
    ## #   `Frequency_Body_Gyroscope_standard_deviation_y-axis` <dbl>,
    ## #   `Frequency_Body_Gyroscope_standard_deviation_z-axis` <dbl>,
    ## #   `Frequency_Body_Acceleration_Magnitude_mean ` <dbl>,
    ## #   Frequency_Body_Acceleration_Magnitude_standard_deviation_ <dbl>,
    ## #   `Frequency_Body_Acceleration_Jerk_Magnitude_mean ` <dbl>,
    ## #   Frequency_Body_Acceleration_Jerk_Magnitude_standard_deviation_ <dbl>,
    ## #   `Frequency_Body_Gyroscope_Magnitude_mean ` <dbl>,
    ## #   Frequency_Body_Gyroscope_Magnitude_standard_deviation_ <dbl>,
    ## #   `Frequency_Body_Gyroscope_Jerk_Magnitude_mean ` <dbl>,
    ## #   Frequency_Body_Gyroscope_Jerk_Magnitude_standard_deviation_ <dbl>

The data is tidy because: \* Each variable forms a column. \* Each
observation forms a row. \* Each type of observational unit forms a
table.

:)
