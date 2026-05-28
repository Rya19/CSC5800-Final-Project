library(rpart)#for dec trees
library(rpart.plot)#for decision trees

library(e1071)#for svm

library(factoextra)#for clustering

library(isotree) #for isolation forest

library(caret)#For analyzing our results

library(pROC)#for ROC curve


Phishing_Data <- read.csv("phishingdata.csv") #Allows us to read from the CSV dataset

#head allows us to see the first 6 rows in the set. Because there are so many characteristics (attributes), they are split into different rows, clogging the console.
head(Phishing_Data)

#Count exactly how many Phishing (-1) and Legitimate (1) sites exist
class_counts = table(Phishing_Train_Data$Result)

#barchart to show
barplot(class_counts, 
        main = "Distribution of Phishing vs. Legitimate Websites", 
        xlab = "Website Classification", 
        ylab = "Total Count", 
        col = c("salmon", "skyblue"), 
        names.arg = c("Phishing (-1)", "Legitimate (1)"))


#PREDICTING WHICH VARIABLES ARE MORE LIKELY TO SHOW THAT A SITE IS A PHISHING WEBSITE
#------------------------------------------------------------------------------------

#Before we start on the model, we need to run it on a training set.
#This is important because if we use the entire set to learn from, it'll memorize it perfectly by memorizing the rows and such.
#By allowing it to run on unseen data, we can be able to see NEW data and do work on it, just like seeing new phishing data.
#Much like a teacher using the study guide to be used as the test as well, students will just memorize them instead of doing thinking-work on them.
#We will use 70% of the data for training, and 30% for testing (We can change this later if needed)

#We will use the sample() function 

#nrow(Phishing_Data) * 0.7 #Just to see 70% of the rows, which will be the number we use, inputted...
#                                 Here -v

#set.seed(123) #This makes it so we test on the same collected 70% of the data instead of random ones. Removing it will allow us to get a new "test" (and "study guide") each time.
Phishing_Train = sample(1:nrow(Phishing_Data), 7738) #We use 70% of the non-randomly chosen training data for training and store that in here
#This created variable will be used here --v

Phishing_Train_Data = Phishing_Data[Phishing_Train, ] #we get 70% of the data from the set (a certain number of rows) while retaining all the columns

Phishing_Test_Data = Phishing_Data[-Phishing_Train, ] #We use a - sigh to get everything that wasn't included in the random sampling process
#END OF SORTING OUT DATA


#Decision tree building
#DEFINITION: A D-tree is like a flowchart, going from different branches based on your answer until it gets to the leaf.
#it does this to ask a specific question to create the purest possible elaves (group that is 100% phishing sites). This relies on Gini and entropy.

#Gini inpurity: Measures the chance of incorrectly classifying a random website if you guessed based on the mix of its group. Gini = 1 - (p1^2 + p2^2)
#We need a score of 0 (only one class exists in that group) as our goal, if possible of course.

#Entropy: measures the disorder or 'chaos' in teh group. Entropy = -(p1 * log2(p1) + p2 * log2(p2))
#Just like gini, a score of 0 means there is no disorder

#Gini_Calculation = function(p1, p2) { #This is where we do the gini math
#  gini = 1 - (p1^2 + p2^2) #put the number here
#  return(gini) #give the number back
#}

#Weighted_Gini = function(w1, g1, w2, g2) {
#  
#}


#We use the rpart function (using gini and finding the best splits), with it predicting the Result (as a factor of a number) column using everything else in the dataset and giving it our "study guide" training data
Phishing_Tree = rpart(as.factor(Result) ~ ., data = Phishing_Train_Data)

#We create a variable to store our predictions using our tested data, and we are giving it the data to "test" on, and we used "class" to know to give us the exact labels (-1 or 1) instead of probability numbers
Tree_Predicitons = predict(Phishing_Tree, Phishing_Test_Data, type = "class")
#the predicitons are stored here, so need to get a "grade" for the "test" to see how well the model did.


Acc = mean(Tree_Predicitons == Phishing_Test_Data$Result) #get the score of how correct the data was (averaged around 90%)
Acc #Result


rpart.plot(Phishing_Tree)
#Plotting the tree, we see only 2 variables. Our tree stops growing branches once it reaches a certain level of purity or when adding more rules does not improve the accuracy.
#It determined that it didnt need the other 28 columns to make its predicitons.
#SSLfinal_State is on the root because it has the LOWEST GINI score out of all 30 columns.
#URL_of_Anchor has our 2nd LOWEST GINI score.


#Another visual to show a Variable Importance score for each column
#We can see that if we run this line, we can see the 2 main variables from the tree visual we just created.
#Along with other variables that are actually not even close to being in the thousandths range.
Phishing_Tree$variable.importance


#create a barplot
barplot(Phishing_Tree$variable.importance,
        main = "Gini score in order for each attribute",
        col = 'skyblue',
        las = 2, #turns the text sideways so they fit
        cex.names = 0.6) #Makes text slightly smaller


data.frame(Score = Phishing_Tree$variable.importance)


#Prediction score
tree_pred = predict(Phishing_Tree, Phishing_Test_Data, type = "class")
confusionMatrix(as.factor(tree_pred), Phishing_Test_Data$Result)


#----------------------------------------------------------------------------------------
#Support Vector Machines
#How they work:
#Imagine a 2D scatterplot. You have a cluster of red dots on the left side, and blue dots on the right side.
#If you want to clearly seperate the set w/o clusters so that you can easily categorize new dots in the future, you'd use a linear line.
#This is called a HYPERPLANE. There are many lines you can draw, but you have to pick the best one.
#This best one will be exactly in the middle to keep it as far away from the 2 closest points as possible.
#The width is called the MARGIN.
#We don't want it to overfit things, so we have a soft margin, which allows a few dots to be on the wrong side (acceptable mistakes).
#Uses library package e1071 for SVM

#svm function to find the optimal line to seperate data, we predict the Result category (as factor) and uses every column to make that prediction. We use out testing data as well. We set the cost as 1 to allow it to make a few "mistakes"
Phishing_SVM = svm(as.factor(Result) ~ ., data = Phishing_Train_Data, cost = 1)

#Similar to the code on line 57, we test our data
SVM_Predicitons = predict(Phishing_SVM, Phishing_Test_Data)

#Results on how the "test" went
Res = mean(SVM_Predicitons == Phishing_Test_Data$Result)
Res #Output 


plot(Phishing_SVM, Phishing_Train_Data, SSLfinal_State ~ URL_of_Anchor)


#------------------------------------------------------------------------------------------
#Clustering (Since we dug a lot into them)
#How they work:
#Clustering groups data into little clusters/groups. They compare every data with every other data, and gathers dentical variables together into distinct groups.
#In this case, we compare each website to others and group identical ones together. 
#This is useful because we can see patterns or categories, and helps us identify families.
#Because we have a dataset of -1 to 1, we can just count exact matches instead of actual distances sicne we are limited to just 3 integers (yes, no, maybe)


#We create a blind dataset for hte clustering algorithm and remove the results column, we want it to guess and not cheat.
Cluster_Data = subset(Phishing_Train_Data, select = -Result)

#Function that tests multiple clusters and draws the elbow plots, takes the blind data, we use kmeans, and we draw a wss, aka elbow chart.
fviz_nbclust(Cluster_Data, kmeans, method = "wss")
#X shows the number of clusters.
#Y shows the error score. For example, forcing all sites into 1 cluster forces sites that arent similar to eachother.
#Allowing the algorithm to crate more clusters, the sites inside each group become more identical, causing the error to drop.
#We can see the line plunges down (stops curving downwards) to 3, which is what we will use.

#We found the optimal cluster value, so we take our blind data and put in 3 clusters
Phishing_Clusters = kmeans(Cluster_Data, centers = 3)

#Gives out the exact number of websites placed into each group, but we can vizulaize this.
Phishing_Clusters$size

#We can graph it using our mathematical variable we made and the original blind dataset
fviz_cluster(Phishing_Clusters, Cluster_Data)
#We can see that they arent seperated, but overlapping eachother, not necessarily because it failed, but because its
#pressing 30 dimensions into a 2D one.


#-------------------------------------------------------------------------------------------------
#ISOLATION FOREST
#What it is: It is an algorithm that looks for outliers through random partitioning.
#This works for our dataset of -1 to 1's is becauase there could be sites that are alone in a specific area.

#We give our blind data and "plant" 100 treesm doing its own line chopping
Iso_Model = isolation.forest(Cluster_Data, ntrees = 100)

#Takes the forest and applies it to our data, generates a deminal score (where 1 is the max) and saves it into a new column called Anomaly_Score
Phishing_Train_Data$Anomaly_Score = predict(Iso_Model, Cluster_Data)

#We create a new variable to search for the new column of which has the highest number, and pulls the row od data to look at
Anom_Sites = Phishing_Train_Data[which.max(Phishing_Train_Data$Anomaly_Score), ]
Anom_Sites #gives the most suspicious site from the dataset 

#------------------------------------------------
#Accuracy, F-measure, sensitivity, and precision
confusionMatrix(as.factor(SVM_Predicitons), as.factor(Phishing_Test_Data$Result))

#On the top we have a 2x2 matrix, with TN, TP, FP, FN.
#We have our accuracy which is 95% (measures all the predicitons the model got correct)
#Sensitivity/Recall is 94% (Caught 94% of total phishing sites)
#Pos pred value/Precision 96% (When the model claimed it was a phising site, it was correct 96% of the time)
#"positive" class means the model considers a phishing site (-1) a positive hit, since thats what we want.

#Error rate (1 - 0.9578) = 4.22%
#F-measure = 2 * Prec * recall / Prec + Recall = 0.9526

#ROC curve
#Needs percentage scores instead of the data values we have inside our dataset.

#Converted both columns in both datasets to categories
Phishing_Train_Data$Result = as.factor(Phishing_Train_Data$Result)
Phishing_Test_Data$Result = as.factor(Phishing_Test_Data$Result)

#Remove the extra column we made so that it runs the ROC curve
Phishing_Train_Data$Anomaly_Score = NULL


svm_model = svm(Result ~., data = Phishing_Train_Data, probability = TRUE)

#Generate predictions and extract the -1 probabilities, since we are looking for those.
svm_predprobs = predict(svm_model, Phishing_Test_Data, probability = TRUE)
SVM_probs = attr(svm_predprobs, "probabilities")[, "-1"]

#Calculate and plot the ROC.
svm_roc = roc(Phishing_Test_Data$Result, SVM_probs)
plot(svm_roc, main = "ROC curve for SVM part", col = "skyblue", lwd = 2, print.auc = TRUE)

