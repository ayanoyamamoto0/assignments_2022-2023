# :wine_glass: Chemical Analysis of Wines
* Designed experiments that highlights the superiority of k-fold cross-validation over hold-out testing, particularly when dealing with limited data samples.
* Executed the experiments using scikit-learn and discerned that k-fold cross-validation not only imparts greater stability but also yields more reliable performance estimates.

## Code and Resources Used
* Python Version: 3.8.8
* Packages: pandas, numpy, matplotlib, seaborn, sklearn
* Wine Dataset: https://archive-beta.ics.uci.edu/dataset/109/wine

## Experiment 1
* Created 200 different splits for hold-out testing, trained three models (GaussianNB, KNeighborsClassifier, and DecisionTreeClassifier), and plotted the F1 scores in histograms to demonstrate the range of F1 scores between "lucky" and "unlucky" splits.
* Performed 10-fold cross validations on the same models. The F1 scores from cross validations were at balanced points between the "lucky" and "unlucky" splits from the 200 hold-out tests, showing that it provides a more stable, and better estimate of performance on small amounts of data.

![Experiment 1](https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/machine_learning/experiment_1.png)

## Experiment 2
* Sample subsets of increasing sizes from the dataset, and performed 30 hold-out tests and 5-fold cross validations with three models (GaussianNB, KNeighborsClassifier, and DecisionTreeClassifier).
* Across the three models, the 5-fold cross validations seem to perform better than average of 30 hold-out tests in most subset sizes smaller than the original dataset of 178 instances.

![Experiment 2](https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/machine_learning/experiment_2.png)
