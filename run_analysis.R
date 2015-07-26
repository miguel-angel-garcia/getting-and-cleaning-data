## Script: run_analysis.R
## Author: Miguel Ángel García
## Course: Getting and Cleaning Data - getdata-030
##
## Files: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
## This script do the following steps:
## 1.- Merges the training and the test sets to create one data set.
## 2.- Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3.- Uses descriptive activity names to name the activities in the data set
## 4.- Appropriately labels the data set with descriptive variable names. 
## 5.- From the data set in step 4, it creates a second, independent tidy data set with 
## the average of each variable for each activity and each subject.

library(dplyr)
library(tidyr)

# Read the data files
x_train <- tbl_df(read.table("./UCI HAR Dataset/train/X_train.txt"))
x_test <- tbl_df(read.table("./UCI HAR Dataset/test/X_test.txt"))
y_train <- tbl_df(read.table("./UCI HAR Dataset/train/y_train.txt"))
y_test <- tbl_df(read.table("./UCI HAR Dataset/test/y_test.txt"))
subject_train <- tbl_df(read.table("./UCI HAR Dataset/train/subject_train.txt"))
subject_test <- tbl_df(read.table("./UCI HAR Dataset/test/subject_test.txt"))
feature <- tbl_df(read.table("./UCI HAR Dataset/features.txt"))
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

## Merge train and test datasets (Step 1)
x <- bind_rows(x_train, x_test)
y <- bind_rows(y_train, y_test)
subjects <- bind_rows(subject_train, subject_test)

## Free space by removing useless datasets
rm(x_train, x_test, y_train, y_test)

## Name the x columns, activity, y and subject (Step 4)
valid_column_names <- make.names(names = feature$V2, unique = TRUE, allow_ = TRUE)
names(x) <- valid_column_names
names(activity_labels) <- c("Activity_id", "Activity_Description")
names(y) <- "Activity_id"
names(subjects) <- "Subject_id"

## Add activity names (Step 3)
y <- merge(y, activity_labels)

## Merges x, y and subjects
x <- bind_cols(x, y, subjects) # Step 4 data!

## Free space by removing useless datasets
rm(y, feature, subjects)

# Extract the measurements for the mean and standard deviation (Step 3)
mean_std <- select(x, contains("mean"),  contains("std")) 

# Create a new dataset with the average of each variable for each activity and each subject
activity_subject <- x %>%
    group_by(Activity_id, Subject_id) %>%
    summarise_each(funs(mean))

# Write files with data
write.table(activity_subject, "activity_subject_means_measurements.txt", row.name=FALSE)