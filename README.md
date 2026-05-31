# CSC 5800 Final Project: Phishing Website Detection

This project uses machine learning in R to analyze and classify phishing websites. The goal is to compare different modeling techniques, identify important website features, and evaluate how accurately the models can distinguish phishing websites from legitimate ones.

## Overview

The script reads a phishing website dataset from a CSV file and applies several machine learning approaches:

- Decision Tree classification
- Support Vector Machine classification
- K-Means clustering
- Isolation Forest anomaly detection
- Confusion matrix evaluation
- ROC curve analysis

The dataset uses `Result` as the target variable, where phishing and legitimate websites are represented as numeric classes.

## Technologies Used

- R
- rpart
- rpart.plot
- e1071
- factoextra
- isotree
- caret
- pROC

## File Structure

```text
CSC5800proj.R   # Main R script for data analysis and machine learning models
```

## Features

- Loads phishing website data from a CSV file
- Splits the dataset into training and testing data
- Builds a decision tree model to classify websites
- Visualizes important decision tree features
- Trains a Support Vector Machine model
- Uses clustering to explore patterns in the dataset
- Applies Isolation Forest to detect unusual website records
- Evaluates model performance using accuracy, precision, recall, F-measure, and ROC analysis

## How to Run

1. Install R and RStudio.

2. Install the required R packages:

```r
install.packages(c(
  "rpart",
  "rpart.plot",
  "e1071",
  "factoextra",
  "isotree",
  "caret",
  "pROC"
))
```

3. Place the phishing dataset CSV file in the same folder as the script.

The script expects the file to be named:

```text
phishingdata.csv
```

4. Open and run:

```text
CSC5800proj.R
```

## Notes

This repository currently contains the R analysis script. The dataset file must be added separately before running the project.

## Skills Demonstrated

- Machine learning model training and evaluation
- Classification using Decision Trees and SVMs
- Unsupervised learning with clustering
- Anomaly detection with Isolation Forest
- Data visualization in R
- Model performance analysis using confusion matrices and ROC curves
- Working with real-world cybersecurity data

## Future Improvements

- Add the dataset or a dataset download link [DONE]
- Organize the script into reusable functions 
- Add comments explaining expected dataset columns [DONE]
- Save generated plots as image files [DONE] 
- Compare model performance in a summary table [DONE]
- Add a short project report with results and conclusions [DONE]

## Author

Created as a CSC 5800 final project focused on machine learning, data analysis, and phishing website detection.
