# 🏘️ Predicting Housing Prices in the UK 🏠

This repository accompanies the study *"Predicciones del precio de la vivienda a partir de datos del registro de Reino Unido"* (or "Predicting Housing Prices in the UK" in short) conducted as part of my Master's thesis (TFM). The project aims to forecast housing prices using regression models and time series analysis. It incorporates datasets from multiple sources, including Kaggle, census records, and geographic APIs.

---

## 📂 Repository Structure

The project is divided into **Python** and **R** components:

### **Python**
The Python code is the backbone of the project, focusing on data processing, modeling, and preliminary analysis. Recommended order of exploration:
1. **`Carga_de_datos.ipynb`**:
   - Constructs `.parquet` files for train and test datasets.
   - Prepares reduced samples for data analysis using auxiliary functions from `funciones_auxiliares.py`.

2. **`Data_collection_&_EDA.ipynb`**:
   - Develops the data pipeline to process the datasets.
   - Based on the exploratory data analysis, several tools to transform and preprocess data are developed, such us the variable scaler and transformations on the target variable.

3. **`Coordenadas_API.ipynb`**:
   - Enriches the dataset by extracting geographic coordinates (latitude, longitude) of UK towns and cities via the OpenCage and Nominatim APIs.
   - This notebook extends from the previous one.

4. **`pipeline.ipynb`**:
   - Transforms `.parquet` datasets into suitable formats for regression modeling.

**Subfolders**:
- **`series-temporales`**: Contains notebooks for time series modeling:
  - **`series_temporales_granularidad.ipynb`**: Analyzes optimal temporal granularity (daily, monthly, annual).
  - **`series_temporales_Price.ipynb`**: Builds SARIMA models to capture trends and seasonal effects in housing prices.

- **`wsl-models`**: Includes notebooks leveraging RAPIDS on GPU for faster regression model training.

### **R**
The R scripts generate final visualizations for the thesis report:
- **`Quarto-Markdown`**: Contains the R Markdown file for creating graphs shown in the thesis.
- **`funciones_auxiliares.R`**: Auxiliary R functions for data handling.
- **`pickle_to_R.ipynb`**: Converts Python Pickle files into R-readable formats.

---

## 📈 Project Overview

### 🔍 Objective
The project aims to:
- Predict housing prices based on location and features.
- Identify key factors influencing price trends.
- Forecast regional price trends to guide investment decisions.

### 💡 Highlights
1. **Regression Models**:
   - Employed **XGBoost** for accurate price predictions.
   - Achieved a **Coefficient of Determination ($R^2$)** of **0.83** and a **Mean Squared Error (MSE)** of **0.20** for district-level predictions.

2. **Time Series Analysis**:
   - Built **SARIMA models** to predict long-term price trends.
   - Identified annual and weekly seasonality patterns in the data.

3. **Geospatial Features**:
   - Enriched datasets with proximity metrics (e.g., distance to London) and clustering-based regional attributes.
