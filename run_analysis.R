
#---------------------------------------------------------------------
# R script:  run_analysis.R 
#---------------------------------------------------------------------

rm(list=ls())

#0. get data
Dir <- "./Data"
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
Zip <- paste(Dir, "/", "rawData.zip", sep = "")


if (!file.exists(Dir)) {
  dir.create(Dir)
  download.file(url = Url, destfile = Zip)
  unzip(zipfile = Zip, exdir = Dir)
}


# 1 Init


library(data.table)

# Q1: Merges the training and the test sets to create one data set.

# data test

test_X        <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
test_subject  <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
test_y        <- read.table("./data/UCI HAR Dataset/test/y_test.txt")

train_X       <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
train_subject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
train_y       <- read.table("./data/UCI HAR Dataset/train/y_train.txt")

test_set      <- cbind(test_subject,test_X)
test_set      <- cbind(test_y,test_set)

train_set     <- cbind(train_subject,train_X)
train_set     <- cbind(train_y,train_set)

q1<- rbind(test_set,train_set)


# Q2 Extracts only the measurements on the mean and standard deviation for 
#    each measurement.

q2              <-q1

features        <- read.table("./data/UCI HAR Dataset/features.txt")
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

names(q2)[1:2]      <-c("Activity.Id","Subject.Id")
names(q2)[3:563]    <- paste(features$V2, 3:ncol(q2), sep="")

q2                  <- q2[,grepl("activity.id|subject.id|mean\\(\\)|std\\(\\)",tolower(names(q2)))]



# Q3 Uses descriptive activity names to name the activities in the data set


names(activity_labels)<-c("Activity.Id","Activity.Label")
q3                  <-merge(q2,activity_labels,by.x="Activity.Id",by.y="Activity.Id",all=TRUE)

# Q4 Appropriately labels the data set with descriptive variable names.

q4<-q3

names(q4) <- gsub("^t", "Time", names(q4))
names(q4) <- gsub("^f", "Frequency", names(q4))
names(q4) <- gsub("-mean\\(\\)", "Mean", names(q4))
names(q4) <- gsub("-std\\(\\)", "StandardDeviation", names(q4))
names(q4) <- gsub("\\.", "", names(q4))
names(q4) <- gsub('-','',names(q4))
names(q4) <- gsub('0','',names(q4))
names(q4) <- gsub('1','',names(q4))
names(q4) <- gsub('2','',names(q4))
names(q4) <- gsub('3','',names(q4))
names(q4) <- gsub('4','',names(q4))
names(q4) <- gsub('5','',names(q4))
names(q4) <- gsub('6','',names(q4))
names(q4) <- gsub('7','',names(q4))
names(q4) <- gsub('8','',names(q4))
names(q4) <- gsub('9','',names(q4))
names(q4) <- gsub("BodyBody", "Body", names(q4))


# Q5 From the data set in step 4, creates a second, independent tidy data 
#    set with the average of each variable for each activity and each subject.

q5Columns   <-colnames(q4[,3:68])
# unpivot
q5          <- melt(q4,id=c("SubjectId","ActivityLabel"),measure.vars=q5Columns)
# pivot aggregate
q5          <- dcast(q5, SubjectId + ActivityLabel ~ variable, mean)

# write the tidy dataset to the Data folder
write.table(q5, file = "data/tidydataset.txt", row.names= FALSE)
