# Article Management Data Warehouse & Analytics Platform

A comprehensive Data Warehouse (DWH), Business Intelligence (BI), and Predictive Analytics solution built for digital content and article management platforms. 

This project demonstrates the complete end-to-end data engineering and analytics pipeline: transforming operational transactional data (MySQL) into a dimensional star-schema Data Warehouse (MS SQL Server 2019), building OLAP cubes (SSAS), developing interactive executive dashboards (Power BI), and performing machine learning predictive modeling (Python & Visual Studio Data Mining).

---

## 📑 Table of Contents
- [Project Architecture](#-project-architecture)
- [System Features](#-system-features)
- [Data Warehouse Schema & Dimensional Modeling](#-data-warehouse-schema--dimensional-modeling)
- [Key Performance Indicators (KPIs)](#-key-performance-indicators-kpis)
- [ETL / ELT Pipeline](#-etl--elt-pipeline)
- [BI & Predictive Analytics](#-bi--predictive-analytics)
- [Repository Structure](#-repository-structure)
- [Getting Started](#-getting-started)

---

## 🏗 Project Architecture

The architecture transitions operational transactional systems (OLTP) into a high-performance analytical system (OLAP) and predictive decision-support system:

```
+-----------------------------------------------------------------------+
|                       OPERATIONAL SOURCES (MySQL)                      |
|   gestiune_utilizatori   |   gestiune_continut   | gestiune_interactiuni|
+-----------------------------------------------------------------------+
                                   |
                                   v  (ETL / T-SQL Transformation)
+-----------------------------------------------------------------------+
|                    DATA WAREHOUSE (MS SQL Server)                     |
|                 Star Schema (1 Fact Table + 8 Dimensions)             |
+-----------------------------------------------------------------------+
                                   |
        +--------------------------+--------------------------+
        |                          |                          |
        v                          v                          v
+---------------+          +---------------+          +---------------+
|   SSAS OLAP   |          |   POWER BI    |          |   PYTHON ML   |
|     Cubes     |          |  Dashboards   |          |  Predictive   |
| (VS 2019 SSAS)|          | (Visual Analytics)       |  (scikit-learn)|
+---------------+          +---------------+          +---------------+
```

---

## ✨ System Features

- **Multi-Source ETL Integration**: Ingests, cleans, and transforms operational data from multiple MySQL transactional databases (`users`, `content`, `interactions`).
- **Kimball Dimensional Modeling**: Designed using Ralph Kimball's methodology, featuring a central Fact Table with 8 surrounding Dimension Tables (Star Schema).
- **Hybrid Data Design (Relational + JSON)**: Stores structured numerical metrics alongside flexible, semi-structured qualitative metadata using validated JSON (`NVARCHAR(MAX)` with `ISJSON()` constraints).
- **Automated Database Programmability**: Includes stored procedures, scalar/table-valued functions, and real-time triggers for SCD (Slowly Changing Dimensions) auditing, automated session logging, and anti-spam content filtering.
- **OLAP & BI Dashboards**: Interactive multi-page Power BI dashboards and SSAS Multidimensional Cubes providing deep-dive drill-down analytics.
- **Predictive Machine Learning**: Linear regression models evaluating content longevity, author productivity, engagement drivers, and user retention risks.

---

## 📐 Data Warehouse Schema & Dimensional Modeling

The Data Warehouse is built around a unified **Star Schema** centered on `FACT_DWH_GESTIUNE_ARTICOLE`.

### Central Fact Table
* **`FACT_DWH_GESTIUNE_ARTICOLE`**: Contains quantitative metrics across all 5 KPIs (views, average reading duration, publication rates, ratings, active sessions, retention) linked to all 8 dimensions via Foreign Keys, alongside qualitative JSON metadata (`KPI_METADATA_JSON`).

### Dimension Tables (8 DIMs)
1. **`DIM_TIMP`**: Temporal calendar hierarchy (`Day` -> `Month` -> `Quarter` -> `Semester` -> `Year`, `Is_Workday`).
2. **`DIM_ARTICOL`**: Article metadata, publishing states, and tag JSON attributes.
3. **`DIM_AUTOR`**: Editorial team profiles, specialization areas, and target goals (`PROFIL_JSON`).
4. **`DIM_CATEGORIE`**: Thematic content categories with parent-child hierarchical support and strategic metrics (`META_JSON`).
5. **`DIM_UTILIZATOR`**: User accounts, activity markers, and behavioral segmentation (`SEGMENT_JSON`).
6. **`DIM_ETICHETA`**: Tags/topics metadata and trend analytics.
7. **`DIM_ROL`**: Role-based access levels (`administrator`, `redactor`, `cititor`) and granular permission configurations (`PERMISIUNI_JSON`).
8. **`DIM_STATUS_ARTICOL`**: Article lifecycle states (`draft`, `publicat`, `arhivat`) and editorial approval workflow rules.

---

## 📊 Key Performance Indicators (KPIs)

The analytical system is structured around 5 strategic KPI domains, each split into 2 specific analytical targets (10 targets total):

| Code | Strategic KPI Domain | Derived Objective 1 | Derived Objective 2 |
| :--- | :--- | :--- | :--- |
| **KPI 1** | **Article Performance** | Article Visibility (View Rate) | Reading Depth (Avg. Duration) |
| **KPI 2** | **Author Activity** | Publication Volume per Author | Editorial Flow Quality (Publishing Rate) |
| **KPI 3** | **User Engagement** | Direct Interaction (Comment Rate) | Feedback Quality (Average Rating Score) |
| **KPI 4** | **Category Management**| Content Distribution per Category| Content Update & Revision Rate |
| **KPI 5** | **Platform Activity** | Active Authentication Rate | User Retention Rate |

---

## 🔄 ETL / ELT Pipeline

The ETL process extracts data from MySQL source databases and loads it into MS SQL Server through sequential execution stages:

1. **Extract**: Data ingestion from source tables (`utilizatori`, `articole`, `categorii`, `vizualizari`, `evaluari`, `comentarii`).
2. **Transform**:
   - Surrogate key mapping (`SET IDENTITY_INSERT`).
   - Calculation of derived measures (e.g., `RATA_PUBLICARE = Published / Created`, `MEDIE_EVALUARE = SUM(Note) / COUNT(*)`).
   - JSON aggregation for qualitative context (`PROFIL_JSON`, `SEGMENT_JSON`, `KPI_METADATA_JSON`).
   - Enum normalization and constraint validation (`CHECK` constraints).
   - Date decomposition into calendar hierarchies (`DIM_TIMP`).
3. **Load**: Sequentially loads data to ensure foreign key integrity (Dimensions loaded first, followed by Fact tables).

---

## 📈 BI & Predictive Analytics

### Business Intelligence (Power BI & SSAS)
- **Power BI Dashboards**: Interactive visualizations covering all 5 KPI domains, equipped with dynamic time slicers, matrix visualizers, gauge goal tracking, and DAX measures.
- **SSAS OLAP Cubes**: Dimensional cubes processed in Visual Studio Analysis Services enabling multi-axis slicing, dicing, and drill-down analysis.

### Predictive Modeling (Python & VS Data Mining)
Multiple linear regression models ($Y = f(X_1, X_2, \dots, X_n)$) evaluate system dynamics:
- **$Y_1$ (Update Rate)**: Evaluates article revision frequency based on category volume and revision counts ($R^2 = 0.932$).
- **$Y_2$ (Published Articles)**: Predicts author editorial productivity driven by publishing efficiency rates ($R^2 = 0.976$).
- **$Y_3$ (Average Rating)**: Analyzes content feedback quality driven by user interaction density ($R^2 = 0.210$).
- **$Y_4$ (Retention Rate)**: Forecasts long-term user retention based on session frequency and authentication patterns ($R^2 = 0.797$ in-sample).

---

## 🛠 Tech Stack

- **Database Management Systems**: Microsoft SQL Server 2019, SSMS 2019, MySQL
- **Business Intelligence**: Microsoft Power BI Desktop, SQL Server Analysis Services (SSAS)
- **Data Engineering & ETL**: T-SQL, SQL Server Integration Services (SSIS principles)
- **Data Science & ML**: Python (Pandas, Scikit-Learn, NumPy, Seaborn, Matplotlib), Visual Studio 2019 Data Mining Toolpak
- **Query Languages**: T-SQL, DAX, MDX

---

## 🚀 Getting Started

### Prerequisites
- Microsoft SQL Server 2019
- SQL Server Management Studio (SSMS) 2019
- Microsoft Power BI Desktop
- Visual Studio 2019 (with Analysis Services extension)
- Python 3.x (with `pandas`, `scikit-learn`, `seaborn`, `matplotlib`)

### Installation & Setup
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/BrSerghei/SSMS_Visual_Studio_Gestiune_Articole.git
   cd SSMS_Visual_Studio_Gestiune_Articole
   ```
2. **Database Initialization**:
   - Execute the SQL DDL scripts in SQL Server to create `DWH_GestionareArticole` database, dimension tables, fact tables, and foreign key constraints.
3. **Load Data**:
   - Run the ETL loading scripts to populate the dimensions and fact tables.
4. **Power BI & SSAS**:
   - Open the `.pbix` file in Power BI Desktop and update the connection string to point to your local SQL Server instance (`localhost`).
   - Open the SSAS solution in Visual Studio 2019 to deploy and process the multidimensional OLAP cubes.
5. **Python Predictive Modeling**:
   - Run the included Python scripts or Jupyter Notebooks to execute linear regression analysis on exported dataset queries.
