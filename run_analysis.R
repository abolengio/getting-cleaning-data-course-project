# helper function to concatenate strings with slash "/" as a separator. Handy
# for creation of file paths 
filePath <- function(...) {
    paste(..., sep="/")
}
# helper function to concatenate strings with no separator
concat <- function(...) {
    paste(..., sep="")
}

# function to read Samsung dataset. Can be used to read either test or train datasets
# returned data.frame contains only thouse columns from the data set whcih are 
# specififed in the columns_to_keep parameter plus subject and activity columns.
# All the columns in the result data set are named appropriately, based on the 
# values from parameter column_names. Please note that the function expects all 
#the column names for the original data set to be specified in the column_names 
#parameter, rather than only those which need to be kept
get_tidy_dataset <- function(testOrTrain, column_names, columns_to_keep) {
    file_dir <- filePath(data_dir, testOrTrain)
    data_set <- read.table(filePath(file_dir, concat("X_",testOrTrain,".txt")))
    activity <- read.table(filePath(file_dir, concat("y_",testOrTrain,".txt")))[,1]
    subject <-read.table(filePath(file_dir, concat("subject_",testOrTrain,".txt")))[,1]
    colnames(data_set) <- column_names
    tidy_data_set <- cbind(activity, subject, data_set[,columns_to_keep])
    return(tidy_data_set)    
}

#directory for the Samsung data
data_dir = "./UCI HAR Dataset"

# check that the Samsung data can be found in the working directory
if(!file.exists(data_dir)) {
    stop(paste("Cannot find the Samsung data in the working directory. Expecting to 
         find it in directory ", data_dir))
}

feature_names <- read.table(filePath(data_dir,"features.txt"))[,2]
columns_to_keep <- which(grepl("mean()",feature_names,fixed=TRUE) | 
                             grepl("std()",feature_names,fixed=TRUE))

test_data_set <- get_tidy_dataset("test", feature_names, columns_to_keep)
train_data_set <- get_tidy_dataset("train", feature_names, columns_to_keep)
merged_data_set <- rbind(test_data_set, train_data_set)

activity_labels <- read.table(filePath(data_dir,"activity_labels.txt"), col.names=c("activity","activity_label"))
merged_data_set$activity <- factor(merged_data_set$activity, labels=activity_labels$activity_label)

# creating clean data set containing averages of all the variables within the 
# merged data set
library(plyr)
result <- ddply(merged_data_set, .(activity, subject), numcolwise(mean))
write.table(result, file = "averages.txt", row.names = FALSE)
