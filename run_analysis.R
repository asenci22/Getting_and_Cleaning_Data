# Importing data
# We only need the mean values and st.derivations
# so, only partial import will be employed for all the files.
# From the features.txt file first, I'm going to find the lines
# in the file, where I have occurrences of words mean and std.

features <- read.table("UCI HAR Dataset/features.txt", text = TRUE)

column_indices <- grep("mean()|std()", features$V2)
column_names <- features[column_indices, "V2"]

activity_label <- read.table("UCI HAR Dataset/activity_labels.txt", text = TRUE)

test_subjects <- fread("UCI HAR Dataset/test/subject_test.txt")
test_set <- fread("UCI HAR Dataset/test/X_test.txt", select = column_indices,
                       col.names = column_names)
test_labels <- read.table("UCI HAR Dataset/test/y_test.txt", text = TRUE)

train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_set <- fread("UCI HAR Dataset/train/X_train.txt", select = column_indices,
                   col.names = column_names)
train_labels <- read.table("UCI HAR Dataset/train/y_train.txt", text = TRUE)

# Binding all data and sorting it in ascending order by subjects and 
# activity label
total_set <- rbind(cbind(test_subjects, test_labels, test_set),
                   cbind(train_subjects, train_labels, train_set))
colnames(total_set) <- c("subject", "activity", column_names)
total_set <- arrange(total_set, subject, activity)

# renaming the activity labels to actual activities
for (i in 1:6){
  value = toString(i)
  total_set$activity <- gsub(value, activity_label[i, "V2"], total_set$activity)
}
first <- column_names[1]
last <- column_names[length(column_names) - 1]
# calculating average for each subject, activity and variable
tidy_data <- total_set %>% 
  group_by(subject, activity) %>% 
  summarize(across(first:last, ~ mean(.x, na.rm = TRUE)))

write.table(tidy_data, "tidy_data.csv", sep = " ", row.names = FALSE)

