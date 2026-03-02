# Analysis of University Students Monthly Expenditure Using Robust Regression in R

## Project Overview
This project analyses university students’ monthly expenditure using Multiple Linear Regression (OLS) and Robust Regression (MM-estimator) in R.

The objective is to identify financial and behavioural factors influencing total monthly spending while evaluating whether classical regression assumptions are satisfied. When assumption violations were detected, a robust regression model was implemented to obtain more stable and reliable parameter estimates.

**Dataset:**
45 survey responses from undergraduate students at BINUS University, including:

* Monthly Allowance (IDR)
* Living Arrangement (Parent / Boarding)
* Frequency of Eating Out
* Frequency of Leisure Activities
* Monthly Transportation Spending (IDR)
* Budgeting Habit (Likert 1–5)
* Expense Tracking Habit (Likert 1–5)
* Saving Before Spending Habit (Likert 1–5)
* Impulsive Buying Tendency (Likert 1–5)
* Price Comparison Habit (Likert 1–5)
* Total Monthly Expenditure (Dependent Variable)


## Key Insights
* Assumption Diagnostics (OLS):

  * Non-normal residuals (Lilliefors test, p < 0.05)
  * No heteroskedasticity (Breusch-Pagan test)
  * No autocorrelation (Durbin-Watson test)
  * No multicollinearity (VIF < 10)
  * Presence of outlier and high-leverage observations

* Model Comparison:

  * OLS Model:

    * R² = 0.62
    * Adjusted R² = 0.508
    * Residual Standard Error = 1,074,000
  * Robust Regression (MM-estimator):

    * R² = 0.882
    * Adjusted R² = 0.847
    * Residual Standard Error = 516,200

* Significant Predictor:

  * Monthly Allowance (p < 0.05)

* Marginal Predictor:

  * Transportation Spending (p ≈ 0.087)

* Non-significant:

  * Living arrangement
  * Consumption frequency variables
  * Financial behavioural habits (budgeting, saving, impulse buying, price comparison)

**Takeaway:**
Financial capacity (income) is the dominant determinant of student spending. Robust regression provides substantially more stable and reliable estimates when classical OLS assumptions are violated.


## Tools & Methods
* Language: R

* Libraries:

  * robustbase (MM-estimator)
  * car (VIF)
  * lmtest (Breusch-Pagan, Durbin-Watson)
  * nortest (Lilliefors test)
  * ggplot2 (diagnostic visualization)

* Methods:

  * Data cleaning & preprocessing
  * Multiple Linear Regression (OLS)
  * Classical assumption diagnostics
  * Outlier & leverage detection (Cook’s Distance, standardized residuals)
  * Robust Regression (MM-estimator)
  * Model comparison (R², Adjusted R², Residual Standard Error)


## Results
* Robust regression improved explanatory power significantly (R² increased from 0.62 to 0.882).
* Residual error reduced by more than 50%.
* Only income-related variable (monthly allowance) significantly explains total expenditure.
* Behavioural financial indicators did not show measurable impact in this sample.

This study highlights the importance of regression diagnostics and the practical value of robust statistical modelling in real-world data analysis.

## Future Work

* Increase sample size to improve generalizability.
* Compare additional robust estimators (Huber, Tukey bisquare).
* Implement regularized regression (Lasso, Ridge) for variable selection.
* Develop interactive dashboards for financial behaviour visualization.
* Extend analysis using machine learning models for predictive performance comparison.

