# Loan_factor_sql

# 💳 Loan Approval Analysis & Customer Risk Profiling

A data analytics project focused on understanding loan approval patterns, customer credit health, and risk segmentation using **SQL**.

---

## 📁 Dataset Description

The dataset consists of synthetically generated loan applicant information, including:

- `CustomerID`: Unique identifier per applicant
- `Age`, `Gender`, `MaritalStatus`, `EducationLevel`, `EmploymentStatus`
- `AnnualIncome`, `LoanAmountRequested`, `PurposeOfLoan`
- `CreditScore`, `ExistingLoansCount`, `LatePaymentsLastYear`
- `LoanApproved`: Approval status (Yes/No)

---

## 📌 Key Business Questions

### ✅ Loan Approval Insights
- What is the **loan approval rate by credit score range**?
- Do applicants with **higher credit scores** have better approval chances?
- How does **employment status** affect loan decisions?
- What is the **average loan amount** approved by purpose?
- Does **education level** impact approval rates?

### 💰 Customer Risk & Financial Health
- Is there a relationship between **existing loans** and **credit score**?
- Do **higher-income** customers get approved more often?
- What is the average number of **late payments** by employment status?

### 👥 Customer Segmentation
- Which **gender + marital status** groups are more likely to be approved?
- What loan purposes are most common among **low / medium / high-income** groups?
- How does **age** correlate with approval or credit score?

### 📉 Performance Monitoring
- Which customer segments have the **highest risk** (low score, late payments)?
- What are the **traits of customers who were denied loans**?
- 
---

## 🛠 Tools & Technologies

- **SQL** (PostgreSQL): Data exploration, aggregations, window functions, CTEs

---


## 🚀 Project Highlights

- Simulated real-world business questions
- Focus on **data-driven decision-making** for financial services

---

Insight 

The SQL analysis reveals that credit score, employment status, and income level are the most significant factors influencing loan approval. Applicants with excellent or very good credit scores and those who are employed consistently have higher approval rates. Income also plays a critical role—higher-income groups not only apply for larger loans but also enjoy better approval outcomes. Furthermore, individuals with multiple existing loans or poor credit scores are more likely to be denied, signaling potential risk to lenders.

On the risk side, the data shows that unemployed individuals, especially those in the lower-income bracket or with high school education, tend to accumulate more late payments. Applicants in the 26–35 age group also show higher instances of payment delays. Interestingly, rejected applicants typically request higher loan amounts, which, combined with their weaker financial profiles, may explain the denials. These insights can help financial institutions refine their risk models and improve loan product targeting.

---

