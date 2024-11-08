import numpy as np
import pandas as pd
import os
import random
import re

def load_date(requested_date, columns=[], nrows=-1, columns_dtype={}, percentage=1, seed=33, folder="../data/Por fecha/"):
    """
    Using percentage gets a random sample of the data.
    Using nrows gets the first rows.
    
    Random sample on stream:
    https://stackoverflow.com/questions/22258491/read-a-small-random-sample-from-a-big-csv-file-into-a-pandas-data-frame
    """
    # --- Initialization ---
    requested_date = str(requested_date)

    # Random seed
    np.random.seed(seed)
    random.seed(seed)

    # Search file requested
    file_list = os.listdir(path=folder)
    requested_file = [file for file in file_list if requested_date in file]

    # If a file is NOT found, return None with a warning
    try:
        requested_file = requested_file[0]
    except:
        print(f"Error: 'requested_date' debe ser una fecha de entre {(np.arange(1995, 2024))}")
        return None
        
    # --- Prepare pd.read_csv kwargs ---
    kwargs = {
        "filepath_or_buffer" : f"{folder}{requested_file}",
        "header" : 0,
        "sep" : ",",
        'na_values' : ''
    }

    if nrows != -1:
        kwargs.update({"nrows" : nrows})

    if columns:
        kwargs.update({'usecols' : columns})

    if columns_dtype:
        kwargs.update(dtype = {col : columns_dtype[col] for col in columns})

    if percentage < 1:
        # i>0 skips header
        kwargs.update({'skiprows' : lambda i: i>0 and random.random() > percentage})

    # --- Read file and adapt column names ---
    file = pd.read_csv(**kwargs)

    # Replace column names with regexp
    replacements = (
        (' ', '.'), ("-", "."), ("/", ".")
    )
    for (old, new) in replacements:
        file = file.rename(columns=lambda x: re.sub(old, new, x))


    # --- Modify categories for better understanding ---
    dic_property_type = {'D' : 'Unifamiliar',
                     'S' : 'Semi-adosado',
                     'T' : 'Adosado',
                     'F' : 'Piso/Apartamento',
                     'O' : 'Otro'}

    dic_duration = {'F' : 'Propiedad',
                    'L' : 'Alquiler',
                    'U' : 'Desconocido'}
    # Old.New
    try:
        file['Old.New'] = file['Old.New'].apply(
            lambda x: 'Nuevo' if x == "Y" else 'Segunda_mano')
    except:
        pass

    # Property Type
    try:
        file['Property.Type'] = file['Property.Type'].apply(
            lambda x: dic_property_type[x] if x in dic_property_type.keys() else x)
    except:
        pass

    # Duration
    try:
        file['Duration'] = file['Duration'].apply(
            lambda x: dic_duration[x] if x in dic_duration.keys() else x)
    except:
        pass

    # --- Output ---
    return file




