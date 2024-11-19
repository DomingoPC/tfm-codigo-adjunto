# Sobre el código adjunto

Este proyecto contiene una parte en Python (principal) y otra en R (gráficas de los resultados finales).

## Indicaciones de la carpeta "Python"

Esta contiene los archivos principales del proyecto. El orden recomendado de visualización es:

1. **Carga_de_datos.ipynb**: contiene la construcción de los archivos .parquet que se usan como conjunto de test y entrenamiento y las muestras más reducidas que usamos para el estudio de los datos. Se apoya en las funciones creadas en el fichero **funciones_auxiliares.py**.

2. **Data_collection_&_EDA.ipynb**: desarrollo del pipeline utilizado para adecuar los datos a los modelos. Se usa, en su mayoría, la muestra de entrenamiento. A partir de ella, se construyen herramientas fundamentales para el uso del pipeline, como puede ser el escalador de variables.

3. **Coordenadas_API.ipynb**: fuente de datos de enriquecimiento. Concretamente, se extrae la posición geográfica (latitud, longitud) de los pueblos y ciudades de Reino Unido. Este notebook se menciona en el del punto 2, por lo que podría resultar interesante analizarlo en ese momento.

4. **pipeline.ipynb**: transformación de los conjuntos de entrenamiento y test guardados en formato parquet. Con ellos, entrenamos los modelos de **regresión**.

Las subcarpetas de series temporales y modelos wsl contienen la información sobre los modelos de series temporales autorregresivos y los modelos de regresión, respectivamente.

### Modelos de series temporales autorregresivas

En la carpeta *series-temporales* se tienen dos notebooks. Siguiendo el orden que marca el análisis realizado, el primero en visualizarse debe ser el de **series_temporales_granularidad.ipynb**, en el que se analiza la granularidad temporal óptima con la que trabajar. Después, se utiliza **series_temporales_Price.ipynb** para analizar el modelo óptimo.

### Modelos de regresión

En la carpeta *wsl-models* se tiene un único notebook en el que se trabaja con la librería RAPIDs para construir los modelos usando la GPU para acelerar el proceso. No obstante, la versión utilizada no está disponible en *Windows*, aunque se puede hacer una instalación de *Linux* con *WSL*.

## Indicaciones de la carpeta "R"

En el archivo *Quarto-Markdown* en la carpeta *R* se construyen las gráficas mostradas en el documento PDF del proyecto. Además, se tiene un script con funciones auxiliares (**funciones_auxiliares.R**) y un notebook de *Jupyter* para transformar algunos de los datos almacenados con la función *Pickle* de *Python* a un formato legible por *R*.
