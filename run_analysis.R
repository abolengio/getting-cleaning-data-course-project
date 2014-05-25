filePath <- function(...) {
    paste(..., sep="/")
}
concat <- function(...) {
    paste(..., sep="")
}
data_dir = "./UCI HAR Dataset"

get_tidy_dataset <- function(testOrTrain, column_names, columns_to_keep) {
    data_set <- read.table(filePath(data_dir, testOrTrain, concat("X_",testOrTrain,".txt")))
    activity <- read.table(filePath(data_dir, testOrTrain, concat("y_",testOrTrain,".txt")))[,1]
    subject <-read.table(filePath(data_dir,testOrTrain,concat("subject_",testOrTrain,".txt")))[,1]
    colnames(data_set) <- column_names
    tidy_data_set <- cbind(activity, subject, data_set[,columns_to_keep])
    return(tidy_data_set)    
}

feature_names <- read.table(filePath(data_dir,"features.txt"))[,2]
columns_to_keep <- which(grepl("mean()",feature_names,fixed=TRUE) | 
                             grepl("std()",feature_names,fixed=TRUE))

test_data_set <- get_tidy_dataset("test", feature_names, columns_to_keep)
train_data_set <- get_tidy_dataset("train", feature_names, columns_to_keep)
merged_data_set <- rbind(test_data_set, train_data_set)

activity_labels <- read.table(filePath(data_dir,"activity_labels.txt"), col.names=c("activity","activity_label"))
merged_data_set$activity <- factor(merged_data_set$activity, labels=activity_labels$activity_label)

#
library(plyr)
result <- ddply(merged_data_set, .(activity, subject), numcolwise(mean))
write.table(result, file = "averages.txt", row.names = FALSE)
