library(plyr)

#---
# Download dataset
if(!file.exists("./data"))
{
  dir.create("./data")
}
DownloadedFileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(DownloadedFileUrl,destfile="./data/Dataset.zip")

#---
# Unzip file to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#---
# 1-Merge the training and the test sets to create one data set

#---
# Read trainings tables
X_Training <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
Y_Training <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
Subject_Training <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

#---
# Read testing tables
X_Test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
Y_Test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
Subject_Test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

#---
# Read features table
Features <- read.table('./data/UCI HAR Dataset/features.txt')

#---
# Read activity labels tables
ActivityLabels = read.table('./data/UCI HAR Dataset/activity_labels.txt')

#---
# Assign column names
colnames(X_Training) <- Features[,2] 
colnames(Y_Training) <-"activityId"
colnames(Subject_Training) <- "subjectId"
colnames(X_Test) <- Features[,2] 
colnames(Y_Test) <- "activityId"
colnames(Subject_Test) <- "subjectId"
colnames(ActivityLabels) <- c('activityId','activityType')

#---
# Merge all data in one table Merged_All
Merged_Training <- cbind(Y_Training, Subject_Training, X_Training)
Merged_Test <- cbind(Y_Test, Subject_Test, X_Test)
Merged_All <- rbind(Merged_Training, Merged_Test)

#---
# 2. Extract only the measurements on the mean and standard 
#    deviation for each measurement

#---
# Read column names
ColumnNames <- colnames(Merged_All)

#---
# Create vector with ID, mean and standard deviation
MeanAndDeviation <- (grepl("activityId" , ColumnNames) | 
                    grepl("subjectId" , ColumnNames) | 
                    grepl("mean.." , ColumnNames) | 
                    grepl("std.." , ColumnNames))

#---
# Get necessary subset from Merged_All
GetMeanAndDeviation <- Merged_All[ , MeanAndDeviation == TRUE]

#---
# 3. Using descriptive activity names to name the activities 
#    in the data set
GetActivityNames <- merge(GetMeanAndDeviation, ActivityLabels,
                          by='activityId',
                          all.x=TRUE)

#---
# 4. Appropriately labeling the data set with descriptive variable names
# (done in previous step)

#---
# 5. Create a second, independent tidy data set with the 
#    average of each variable for each activity and each subject

#---
# Make second tidy data set 
SecondTidySet <- aggregate(. ~subjectId + activityId, GetActivityNames, mean)
SecondTidySet <- SecondTidySet[order(SecondTidySet$subjectId, SecondTidySet$activityId),]

#---
# Write second tidy data set in txt file
write.table(SecondTidySet, "SecondTidySet.txt", row.name=FALSE)