# Customer 360 - Advanced SQL Analytics

> **E-commerce data engineering project: Building a Customer 360 ETL pipeline and answering 30 complex business queries using advanced PostgreSQL.**

## 📌 Project Overview
The Customer 360 project is a comprehensive SQL-based analytics solution designed to extract, clean, and analyze complex e-commerce and web traffic data. Moving beyond basic aggregations, this project utilizes advanced PostgreSQL techniques to build a robust ETL pipeline and solve real-world operational challenges. Key achievements include standardizing dirty datasets using Regex, tracking consecutive purchase streaks (Gaps & Islands), and calculating Month-over-Month (MoM) revenue growth.

## 💾 Data Source
The raw data for this project is sourced from Kaggle:
* **Dataset:** [Customer 360 Dataset by Vinay Kandimalla](https://www.kaggle.com/datasets/vinaykandimalla/customer-360/data)
*(Note: To keep this repository lightweight and adhere to version control best practices, the heavy raw `.csv` files are not included in this repo. Follow the reproduction steps below to run the code locally).*

## 🗂️ Repository Structure
The core logic of the project is broken into modular SQL scripts located in the `/sql` directory:
* `raw_file_schema_creation.sql`: Establishes the `staging` and `analytics` schemas and defines the raw table structures.
* `cleaning_to_import_data.sql`: Exploratory Data Analysis (EDA) queries to identify orphan records and parse malformed text.
* `cleaned_analytics_tables.sql`: The ETL pipeline that sanitizes data using Regex, standardizes timestamps, and enforces Primary/Foreign Key constraints.
* `real_world_questions_answers.sql`: The master script containing 30 advanced business queries (including CTE chaining and window functions).

## 🛠️ Key Technical Skills Demonstrated
* **Data Hygiene & Regex**: Sanitized financial metrics by removing alphabetic characters from amounts (`order_amount !~ '^[0-9\.]+$'`). Standardized text fields using `INITCAP()` and `TRIM()`.
* **Advanced Date Parsing**: Safely converted various, inconsistent string date formats (e.g., `YYYY-MM-DD"T"HH24:MI:SS.US`) into strictly typed timestamps.
* **Relational Integrity**: Enforced database architecture by deleting duplicate customer records via `ctid` and establishing foreign keys linking orders and support tickets to the primary customer table.
* **Advanced Window Functions**: 
  * **Sessionisation:** Grouped raw web clicks into logical browsing sessions based on a 60-minute inactivity threshold (`LAG`).
  * **Gaps & Islands:** Identified user purchase streaks by subtracting `DENSE_RANK()` values from chronological order dates.
  * **Moving Averages:** Evaluated support agent performance using a moving average defined by `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`.
  * **VIP Stratification:** Segmented customers into quartiles using `NTILE(4)` based on lifetime successful spend.

## 🚀 How to Reproduce This Project
To recreate this database and run the analysis locally, follow these steps:

**1. Get the Data**
* Download the raw `.csv` files from the [Kaggle dataset link](https://www.kaggle.com/datasets/vinaykandimalla/customer-360/data).

**2. Setup the Database**
* Run `sql/raw_file_schema_creation.sql` in PostgreSQL to build the empty `staging` and `analytics` schemas.

**3. Import the Raw Data**
* Import the downloaded `.csv` files into their respective `staging` tables. You can do this using the pgAdmin Import/Export GUI, or by using the PostgreSQL `COPY` command (e.g., `COPY staging.raw_clickstream FROM '/path/to/file.csv' CSV HEADER;`).

**4. Run the ETL Pipeline**
* Execute `sql/cleaned_analytics_tables.sql`. This script will clean the messy staging data, parse dates/currencies, apply constraints, and populate the final `analytics` schema.

**5. Execute Business Analytics**
* Run `sql/real_world_questions_answers.sql` to view the solutions to the 30 scenario-based business questions.

## 🗺️ Future Roadmap
* [ ] **Business Intelligence:** Connect the cleaned `analytics` tables to Tableau/Power BI to build an executive-level Customer 360 dashboard.
* [ ] **Data Orchestration:** Convert the manual SQL scripts into a `dbt` (Data Build Tool) project to automate the transformation pipeline.