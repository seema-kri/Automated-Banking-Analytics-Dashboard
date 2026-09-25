# Automated Banking Analytics Dashboard

**Analyzing 49,615+ retail banking transactions worth ₹302M across 10,000 customers to power failure detection, cross-sell targeting, and branch prioritization using SQL Server, Microsoft Fabric, and Power BI.**

[![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white)](#)
[![Microsoft Fabric](https://img.shields.io/badge/Microsoft_Fabric-5C2D91?style=flat&logo=microsoft&logoColor=white)](#)
[![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=flat&logo=powerbi&logoColor=black)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

🔗 **[Live Dashboard (Power BI / Microsoft Fabric)](https://app.fabric.microsoft.com/links/gewIC3bykT?ctid=e93d71d6-b5c0-4b78-a861-d9964ecdfcd6&pbi_source=linkShare&bookmarkGuid=9c0df4db-7ea8-4a8d-bead-b3261cb8ae63)**

---

## Table of Contents

- [Overview](#overview)
- [Problem Statement](#problem-statement)
- [Dataset Description](#dataset-description)
- [Tools & Technologies](#tools--technologies)
- [Project Structure](#project-structure)
- [Data Cleaning & Preparation](#data-cleaning--preparation)
- [EDA & Key Insights](#eda--key-insights)
- [Dashboard](#dashboard)
- [How to Run This Project](#how-to-run-this-project)
- [Final Recommendations & Future Work](#final-recommendations--future-work)
- [Author & Contact](#author--contact)

---

## Overview

This project builds a fully automated, end-to-end analytics platform for a retail banking dataset. Raw transaction, account, branch, and customer data flows from **SQL Server** through **Microsoft Fabric** (Dataflow Gen2 → Lakehouse → Semantic Model) into a live-connected **Power BI** report, refreshed daily with zero manual effort.

Alongside the visual dashboard, **10 structured SQL Server queries** answer specific business questions directly against the data turning raw rows into ranked, decision-ready findings (not just charts).

**Scope:** 5 fact/dimension tables · 49,615 transactions · 10,000 customers · 6 transaction channels · 5 account types · 2 dashboard pages · 10 SQL business-analysis queries.

---

## Problem Statement

The bank had no unified, automated view of transaction health, branch performance, or customer behaviour across its six channels (ATM, Mobile Banking, UPI, Internet Banking, Branch, POS). Business teams relied on manual spreadsheet extracts to answer basic questions "which channel is failing most?", "which branches need attention?" often taking hours to days per request, with no shared, governed definition of core KPIs like Success Rate.

This project replaces that manual process with a governed semantic model, a scheduled refresh pipeline, and a curated SQL analysis layer that together deliver consistent, decision-ready answers on demand.

---

## Dataset Description

Data is modeled as a star schema in a SQL Server database (`Banking_Domain`), with 5 tables:

| Table | Description | Grain |
|---|---|---|
| `FactTransaction` | Core transaction fact table | 1 row per transaction (49,615 rows) |
| `DimAccount` | Account attributes (type, status, interest rate) | 1 row per account |
| `DimBranch` | Branch attributes (name, city, region, type) | 1 row per branch |
| `DimCustomer` | Customer demographics & segment | 1 row per customer (10,000 rows) |
| `DimDate` | Calendar date dimension | 1 row per date |

Raw CSV extracts of all 5 tables are available in [`/Data`](./Data). The dataset is a simulated retail banking dataset built for this portfolio project (not real customer data).

---

## Tools & Technologies

| Layer | Tools |
|---|---|
| **Database** | SQL Server (T-SQL) |
| **Data Ingestion & Cleaning** | Microsoft Fabric — Dataflow Gen2 (Power Query / M) |
| **Storage** | Microsoft Fabric Lakehouse (Delta tables) |
| **Modeling** | Fabric SQL Analytics Endpoint — Star Schema + DAX Measures |
| **Visualization** | Power BI (Live Connection, dynamic field parameters) |
| **Automation** | Fabric Data Pipeline (scheduled daily refresh) |
| **Version Control** | Git & GitHub |

---

## Project Structure

```
Automated-Banking-Analytics-Dashboard/
│
├── Assets/                        # Screenshots & architecture diagrams
│   ├── Customer Insights.png
│   ├── Executive Overview.png
│   ├── star_schema_model_view.png
│   └── workspace_fabric.png
│
├── Data/                          # Raw source tables (CSV)
│   ├── FactTransaction.csv
│   ├── DimAccount.csv
│   ├── DimBranch.csv
│   ├── DimCustomer.csv
│   └── DimDate.csv
│
├── Docs/                          # Business documentation
│   ├── BRD.pdf                    # Business Requirements Document
│   ├── Presentation.pdf
│   └── Presentation.pptx
│
├── PowerBI/                       # Power BI report
│   ├── Banking_Dashboard.pbit     # Template (no data — connect to your own DB)
│   └── Banking_Dashboard.pdf
│
├── sql/                           # SQL Server scripts
│   ├── schema_definitions.sql
│   └── business_analysis_queries.sql
│
├── .gitignore
├── LICENSE
└── README.md
```

---

## Data Cleaning & Preparation

All cleaning and transformation happens in **Fabric Dataflow Gen2** using Power Query (M):

- Surrogate keys (`AccountKey`, `CustomerKey`, `BranchKey`, `DateKey`) converted from text to whole numbers.
- Date fields (`OpenDate`, `DateOfBirth`, `CustomerSince`) standardized to strict Date type.
- **Age Band** derived from Date of Birth: `18–25`, `26–35`, `36–45`, `46–55`, `56–65`, `65+`.
- **Income Band** derived from Annual Income: `<3L`, `3–8L`, `8–15L`, `15L+`.
- **Interest Rate Band** derived from Account Interest Rate: `0–4%`, `4–7%`, `7–10%`, `10–13%`, `13%+`.
- All transformed tables loaded into the Lakehouse in Delta format under the `dbo` schema for fast querying.

---

## EDA & Key Insights

Findings below come directly from the 10 SQL queries in [`business_analysis_queries.sql`](./sql/business_analysis_queries.sql):

| # | Business Question | Key Finding |
|---|---|---|
| 1 | Which customer segments generate the most value? | **Mass segment** drives ₹89.7 Cr (4,600 customers) — more than Affluent + Premium combined |
| 2 | Which branches perform well or need attention? | Branch performance flagged relative to regional average using CTE + CASE scoring |
| 3 | Which channels are most successful? | All channels hold ~94% success rate; Mobile Banking has the highest volume |
| 4 | Where are failures concentrated? | **POS (4.05%)** and **Internet Banking (4.03%)** have the highest failure rates; Mobile Banking carries the largest revenue-at-risk (₹1.58 Cr) |
| 5 | Which account types are most valuable? | **Savings** accounts drive ₹67.5 Cr in value; **Loan** accounts carry the highest interest rate (10.99%) |
| 6 | Which customers have cross-sell potential? | High-income, single-account customers flagged as a ready-made cross-sell shortlist |
| 7 | Does income relate to banking activity? | The **₹3–8L income band** is the largest value driver (₹75.3 Cr, ~5,000 customers) |
| 8 | How does performance change monthly? | Seasonal swing from a **February low (3,909 txns)** to an **October peak (4,302 txns)** |
| 9 | Which customer groups have high failure rates? | **Premium-segment Engineers** show the highest failure rate (4.73%) of any group tested |
| 10 | Where should management focus improvement? | Composite scoring ranks **3 branches** (Jaipur Central ×2, Chennai Central) as top priority this quarter |

---

## Dashboard

The Power BI report has two live-connected pages:

**Page 1 — Executive Overview**
KPI cards (Total Transaction Amount, Transaction Count, Average Transaction Value, Success Rate), a dynamic monthly trend chart, channel distribution donut, and regional performance bar chart — all filterable by City, Region, and Year.

![Executive Overview](./Assets/Executive%20Overview.png)

**Page 2 — Customer Insights**
Customer KPI cards, segment breakdown, occupation distribution, and income/age band analysis for demographic and cross-sell targeting.

![Customer Insights](./Assets/Customer%20Insights.png)

🔗 **[Open the live dashboard](https://app.fabric.microsoft.com/links/gewIC3bykT?ctid=e93d71d6-b5c0-4b78-a861-d9964ecdfcd6&pbi_source=linkShare&bookmarkGuid=9c0df4db-7ea8-4a8d-bead-b3261cb8ae63)**

---

## How to Run This Project

1. **Clone the repository**
   ```bash
   git clone https://github.com/seema-kri/Automated-Banking-Analytics-Dashboard.git
   ```
2. **Set up the database**
   - Open SQL Server Management Studio (SSMS).
   - Run [`sql/schema_definitions.sql`](./sql/schema_definitions.sql) to create the `Banking_Domain` database and tables.
   - Load the CSVs from [`/Data`](./Data) into their matching tables (Import Flat File wizard, or `BULK INSERT`).
3. **Run the business analysis queries**
   - Open [`sql/business_analysis_queries.sql`](./sql/business_analysis_queries.sql) in SSMS and execute each query against `Banking_Domain`.
4. **Open the dashboard**
   - Open `PowerBI/Banking_Dashboard.pbit` in Power BI Desktop.
   - When prompted, point it at your own `Banking_Domain` SQL Server instance.
   - Refresh to load your data.

---

## Final Recommendations & Future Work

**Recommendations:**
- Fix POS and Internet Banking reliability first — they post the highest failure rates.
- Launch a cross-sell campaign targeting the high-income, single-account customers flagged in Query 6.
- Prioritize the 3 branches with the highest composite risk score this quarter.
- Plan capacity around the ~10% seasonal swing between February and October.
- Protect the Mass segment with service-quality monitoring, not just premium-tier focus.

**Future Work:**
- Move from daily batch refresh to near-real-time streaming ingestion.
- Add a churn-prediction / fraud-scoring model on top of the existing semantic model.
- Extend the star schema to new products and channels as the bank grows.

---

## Author & Contact

**Seema** — Data & BI Analyst

📧 Email: kriseema87@gmail.com

🔗 LinkedIn: [https://linkedin.com/in/seema-kumari-375763308](https://linkedin.com)

*If you found this project useful, consider giving it a ⭐ on GitHub!*
