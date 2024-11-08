# Cargar una fecha concreta y columnas concretas (o todo)
# https://stackoverflow.com/questions/10128617/test-if-characters-are-in-a-string
# https://fanwangecon.github.io/R4Econ/development/inout/htmlpdfr/fs_path.html#14_Get_Subset_of_Path_Folder_Names
# https://stackoverflow.com/questions/25640161/r-how-to-test-for-character0-in-if-statement

load_sample <- function(year, requested_columns = c(), folder='../data/sample/') {
  requested_data = paste(folder, toString(year), '.csv', sep='')
  requested_columns = as.list(requested_columns)
  
  
  # Column types of requested columns (all if none are specefied)
  columns_dtype = list(`...1` = col_skip(),
                       `Transaction.unique.identifier` = col_character(),
                       Price = col_integer(),
                       `Date.of.Transfer` = col_datetime(format = '%Y-%m-%d %H:%M'),
                       `Postcode` = col_character(),
                       `Property.Type` = col_character(),
                       `Old.New` = col_character(),
                       Duration = col_character(),
                       PAON = col_character(),
                       SAON = col_character(),
                       Street = col_character(),
                       Locality = col_character(),
                       `Town.City` = col_character(),
                       District = col_character(),
                       County = col_character(),
                       `PPD.Category.Type` = col_character(),
                       `Record.Status...monthly.file.only` = col_character()
  )
  
  # Filter columns if specified
  if (!identical(requested_columns, list())) {
    for (column in names(columns_dtype)) {
      if (!(column %in% requested_columns)) {
        columns_dtype[[column]] = col_skip()
      }
    }
  }
  
  # Load sample
  return(suppressMessages(
    read_csv(requested_data,
             col_types = do.call(cols, columns_dtype))
  ))
}


# --- Load a specific column with year or without it ---
load_column <- function(year, column, with_year=F, list_NAs_by_year=list()) {
  temp <- load_sample(year, column)
  
  if (!(identical(list_NAs_by_year, list()))) {temp <- temp[list_NAs_by_year[[toString(year)]], ]}
  if (with_year == TRUE) {temp['year'] <- as.integer(year)}
  
  return(temp)
}

# --- Load a specific variable of all years ---
load_variable <- function(column, init=1995, end=2023, with_year=F, list_NAs_by_year=list()) {
  
  # Load first year
  requested_var <- load_column(init, column, with_year, list_NAs_by_year)
  
  # Rest of the years
  seq_years <- seq(init+1, end, 1)
  
  for (year in seq_years) {
    temp_col <- load_column(year, column, with_year, list_NAs_by_year)
    requested_var <- rbind(requested_var, temp_col)
  }
  return(requested_var)
}


# --- Load all data: use only with samples!! ---
load_all <- function(requested_columns=c(), init = 1995, end = 2023, folder='../data/sample/') {
  
  # Load first year
  requested_data <- load_sample(init, requested_columns, folder)
  
  # Load the rest of the years
  for (year in seq(init+1, end, 1)) {
    requested_data <- rbind(requested_data, 
                            load_sample(year, requested_columns, folder))
  }
  
  return(requested_data)
}


# --- Build formula ---
build_formula <- function(y_name, x_names='.') {
  return(
    formula(paste("`", y_name ,"` ~ ", 
                  paste("`", x_names ,"`", sep="", collapse="+"),
                  sep=""))
  )
}



# ________________________________________________________________________________
# --- Data initialization ---

# Label encoding
custom_encoding <- function(datos) {
  
  # Binary variables
  # datos$SAON_specified <- as.numeric(!(datos %>% 
  #                                        dplyr::select(SAON) %>%
  #                                        is.na()))
  
  datos$First_hand <- as.numeric(datos$Old.New == "nuevo")
  datos <- datos %>% dplyr::select(-Old.New)
  
  datos$Aditional.Price.Paid <- as.numeric(datos$PPD.Category.Type == "b")
  datos <- datos %>% dplyr::select(-PPD.Category.Type)
  
  # Label encoding (few categories)
  for (var in c("Property.Type", "Duration")) {
    datos[[var]] <- as.numeric(as.factor(datos[[var]]))
    }
  
  # Label encoding (many categories)
  # C:/Users/domin/OneDrive - UNIVERSIDAD DE SEVILLA/TFM/3. Gráficas.Rmd
  for (var in c("County", "Postcode", "Street", "Locality", "Town.City", "District", "PAON", "SAON")) {
    labels <- readRDS(file=paste("output/", var, "_labels.RData", collapse="", sep=""))
    datos <- datos %>% 
      left_join(labels %>% dplyr::select(-Price), by=var)
    
    new_name <- paste(var,"_label", sep="", collapse="")
    datos <- datos %>% rename({{new_name}} := label) %>% dplyr::select(-all_of(var))
    datos[new_name][is.na(datos[new_name])] = -1
  }
  
  return(datos)
}


# Frequency encoding
fun.freq_encoding <- function(data) {
  freq_col <- table(data)
  return(as.numeric(freq_col[data]))
}

freq_encoding <- function(data, skip_variable.names=c()) {
  
  # Get categorical columns
  factor.names <- setdiff(names(data)[sapply(data, is.factor)], skip_variable.names)
  
  # Encoding
  data <- data %>% 
    mutate(across(all_of(factor.names), fun.freq_encoding))
  
  # Output
  return(data)
}

# --- All steps ---
data_initialization <- function(data, 
                                date_column = 'Date.of.Transfer',
                                skip_columns = c('Date.of.Transfer', 
                                                 'Record.Status...monthly.file.only', 
                                                 'Transaction.unique.identifier'),
                                na_name = 'No registrado',
                                frequency_encoding = FALSE,
                                skip_frequency_encoding = c(),
                                numeric_names = c("Price"),
                                only_map_regions = FALSE) {
  
  # Divide date into year, month and day; then, skip some columns
  data <- data %>% 
    mutate(
      Year = lubridate::year(.[[date_column]]),
      Month = lubridate::month(.[[date_column]]),
      Day = lubridate::day(.[[date_column]])
    ) 
  
  if ("...1" %in% colnames(data)) {skip_columns = c(skip_columns, "...1")}
  data <- data %>% 
    dplyr::select(-all_of(skip_columns)) 
    
  
  # Rename NAs
  if (na_name != "NA") {data[is.na(data)] <- na_name}
  
  # --- Change some county and districts names to match map names ---
  numeric_names = c(numeric_names, "Year", "Month", "Day")
  categorical.names = setdiff(colnames(data), numeric_names)
  data <- data %>% 
    mutate(across(all_of(categorical.names), tolower))
  
  corrections.county <- list(c("wrekin", "telford and wrekin"), # West Midlands
                             c('windsor and maidenhead', # South East
                               'royal borough of windsor and maidenhead'),
                             c('isle of anglesey','anglesey'), # East Wales
                             c('rhondda cynon taff','rhondda, cynon, taff')) # East Wales
  
  for (correction in corrections.county) {
    data$County <- gsub(correction[[1]], correction[[2]], data$County)
  }
  
  corrections.district <- list(c('city of westminster','westminster'), # Greater London
                               c('city of london','city')) # Greater London
  
  for (correction in corrections.district) {
    data$District <- gsub(correction[[1]], correction[[2]], data$District)
  }
  
  # Region variable refering to the exact map location it refers to
  if (only_map_regions) {
    data$Region <- NA
    skip_frequency_encoding <- c(skip_frequency_encoding, "Region")
    load("output/county_district_names.RData")
    
    data <- rbind(
      data %>% 
        filter(data$County %in% county_district_names[[1]]$name) %>% 
        mutate(Region = County),
      data %>% 
        filter(data$District %in% county_district_names[[2]]$name) %>% 
        mutate(Region = District)
    ) 
  }
    
  # Set correct data type for each column
  categorical.names = setdiff(colnames(data), numeric_names)
  data <- data %>% 
    mutate(across(all_of(numeric_names), as.numeric)) %>% 
    mutate(across(all_of(categorical.names), as.factor))
  
  
  # Frequency encoding
  if (frequency_encoding) {
    data <- freq_encoding(data, skip_variable.names = skip_frequency_encoding)
  }
  
  # Output
  return(data)
  
}


# ________________________________________________________________________________
# --- Fit Quality ---
fit_quality <- function(y, yp, name.conjunto)
{
  residuos <- y-yp
  RMSE <- sqrt(mean(residuos^2))
  MAE <- mean(abs(residuos))
  R2 <- cor(y,yp)^2
  
  plot(y, yp, col="blue",
       xlab="Observado", ylab="Predicciones",
       main=name.conjunto)
  abline(a=0, b=1, col="red", lwd=2)
  
  plot(yp, residuos, col="blue",
       xlab="Predicciones", ylab="Residuos",
       main=name.conjunto)
  abline(h=0, col="lightgrey", lwd=2)
  
  return(list(RMSE=RMSE, MAE=MAE, R2=R2))
}

fit_quality.binary <- function(real, prediccion) {
  cat(' Matriz de confusión\n')
  conf <- table(Real = real, 
                Prediccion = prediccion)
  print(conf)
  
  # Porcentaje de acierto global
  cat("\n Precisión global:", 100 * sum(diag(prop.table(conf))), '%\n')
  
  
  # Porcentaje de acierto por clase
  cat("\n Precisión por clase:\n")
  print(100 * diag(prop.table(conf, 1)))
}

# ________________________________________________________________________________
# --- Custom Transform ---
# Custom transform = Scaling -> Box-Cox
# The initial scaling is necessary to avoid large numbers overflow (Inf, NA..)

data_transform <- function(x, lambda=Inf, scaling=1e-4) {
  x_trans <- x / scaling
  
  if (!(identical(lambda, Inf))) {best_lambda = lambda}
  else {box_cox_trans <- boxcox(lm(Price ~ 1, data = train), 
                                lambda = seq(-3, 3, by = 0.1),
                                plotit = FALSE)
  best_lambda <- box_cox_trans$x[which.max(box_cox_trans$y)]  # Optimal lambda
  }
  
  # Apply transformation
  if (best_lambda != 0) {
    x_trans <- (x_trans^best_lambda - 1) / best_lambda
  } else {
    x_trans <- log(x_trans)
  }
  return(list(x_trans, best_lambda))
}

data_transform.inv <- function(x, lambda, scaling=1e-4) {
  # https://stats.stackexchange.com/questions/572400/inverse-differencing-and-inverse-box-cox-on-forecasted-arima-predictions
  if (lambda == 0L) {x_trans <- exp(x)}
  else {x_trans <- (x*lambda+1)^(1/lambda)}
  
  return(x_trans * scaling)
}