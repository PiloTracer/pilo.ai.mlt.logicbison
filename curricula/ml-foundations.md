# ML Foundations

**Slug:** `ml-foundations`
**Duration:** 4-6 weeks · 3-4 sessions/week
**Level:** Beginner
**Prerequisites:** none

## Audience
Career switchers and students entering ML. Assumes basic Python and high-school math. Common misconception: "ML is just calling library functions."

## Duration & Cadence
4-6 weeks, 3-4 sessions/week. Sessions: 60-90 min (concept + exercise). Async: reading, drills, labs.

## Outcomes
1. Implement linear/logistic regression from scratch in NumPy
2. Build and tune a scikit-learn classifier on a real dataset
3. Perform EDA and communicate findings
4. Explain bias-variance tradeoff, overfitting, cross-validation

## Modules

### Module 1: Math for ML (Week 1-2)
**Objectives:** Build mathematical intuition for ML algorithms.
**Content:** Linear algebra (vectors, matrices, eigenvalues). Calculus (derivatives, chain rule, gradient descent). Probability (distributions, Bayes' theorem, MLE).
**Lab:** Implement gradient descent for linear regression in pure NumPy. Visualize loss landscape and convergence.
**Sources:** [3Blue1Brown — Linear Algebra](https://www.3blue1brown.com/topics/linear-algebra) · [Khan Academy — Statistics](https://www.khanacademy.org/math/statistics-probability) · [MML Book](https://mml-book.github.io/)
**Exit check:** Derive the normal equation; explain eigenvalues geometrically.

### Module 2: Python for ML (Week 2-3)
**Objectives:** Master NumPy, Pandas, Matplotlib, scikit-learn API.
**Content:** NumPy broadcasting and vectorization. Pandas DataFrames, groupby, merging. Visualization with Seaborn. scikit-learn estimators, transformers, pipelines.
**Lab:** Load a real dataset (Titanic/California Housing), clean, engineer features, visualize distributions.
**Sources:** [Python Data Science Handbook](https://jakevdp.github.io/PythonDataScienceHandbook/) · [scikit-learn User Guide](https://scikit-learn.org/stable/user_guide.html) · [fast.ai Lesson 1](https://course.fast.ai/)
**Exit check:** Write a Pandas cleaning+plotting pipeline without documentation.

### Module 3: ML Basics (Week 3-5)
**Objectives:** Understand core ML concepts and build working models.
**Content:** Supervised (regression, classification, loss functions, metrics). Unsupervised (k-means, PCA). Model selection (cross-validation, hyperparameter tuning). Bias-variance, regularization (L1/L2).
**Lab:** Classification pipeline on UCI Adult Income: EDA, preprocessing, training, cross-validation, metric reporting.
**Sources:** [fast.ai — Practical Deep Learning](https://course.fast.ai/) · [Andrew Ng ML Specialization](https://www.coursera.org/specializations/machine-learning-introduction)
**Exit check:** Explain precision vs recall; demonstrate cross-validation on skewed data.

## Assessment

| Criterion | Pass condition |
|-----------|----------------|
| Math fluency | Derive gradient descent update rules by hand |
| Python proficiency | Clean and visualize unfamiliar dataset in <2 hours |
| Model building | Classifier achieving >80% F1 with proper evaluation |
| Concepts | Explain bias-variance tradeoff with concrete example |

## Exit Criteria
All exit checks met. Artifacts in `.training.mlt/`: linear regression impl, scikit-learn pipeline, EDA notebook.
