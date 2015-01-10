read_training_data <- function() {
  data_path <- 'data/pml-training.csv'
  tdata <- read.csv(data_path, na.strings=c('NA', '#DIV/0!'), strip.white=T)
  # > nrow(tdata)
  # [1] 19622
  # > ncol(tdata)
  # [1] 160
  
  #############################################################################
  # data cleansing
  
  ## col X ----------------------------
  # - line id (running number)
  # - data type (integer) detected correctly
  # - no NA values
  
  ## user_name ------------------------
  # - factor with levels 'adelmo', 'carlitos', 'charles', 'eurico', 'jeremy',
  #   'pedro' representing user names
  # - adelmo: 3892, carlitos: 3112, charles: 3536, eurico: 3070, jeremy: 3402
  # - no NA values
  
  ## raw_timestamp_part_1 -------------
  # - timestamps
  # - no NA values
  # - TODO: What's the meaning?
  tdata$raw_timestamp_part_1 <- as.POSIXlt(tdata$raw_timestamp_part_1, origin='1970-01-01')
  
  ## raw_timestamp_part_2
  # - more or less equally distributed between 0 and 1e+06
  # - guessing that these values represent a duration
  # - no NA values
  # - TODO: What's the meaning?
  
  ## cvtd_timestamp -------------------
  # - strings representing dates in the format '%d/%m/%Y %H:%M', e.g.
  #   '05/12/2011', '11:23 05/12/2011', '11:23 05/12/2011', '11:23 05/12/2011'
  # - no NA values
  # - TODO: What's the meaning?
  tdata$cvtd_timestamp <- strptime(tdata$cvtd_timestamp, '%d/%m/%Y %H:%M')
  
  ## new_window -----------------------
  # - 'yes'/'no' factor
  # - no NA values
  # - TODO: What's the meaning?
  # - convert factors to booleans
  tdata$new_window <- ifelse((tdata$new_window == 'yes'), T, F)
  
  ## num_window -----------------------
  # - integer vector
  # - [1, 864]
  # - more or less equally distributed (see imgs/tdata_num_window_density.png)
  # - no NA values
  # - TODO: What's the meaning?
  
  ## roll_belt ------------------------
  # - numeric vector
  # - [-28.9, 162]
  # - two local maxima (0, ~120) (see imgs/tdata_roll_belt_density.png)
  # - no NA values
  # - TODO: What's the meaning?
  
  ## pitch_belt -----------------------
  # - numeric vector
  # - [-55.8, 60.3]
  # - no NA values
  # - multiple local maxima (~-43, *6*, 17, 27) (see imgs/tdata_pitch_belt_density.png)
  
  ## yaw_belt -------------------------
  # - numeric vector
  # - [-180, 179]
  # - no NA values
  # - three local maxima (-80, ~-2, ~168) (see imgs/tdata_yaw_belt_density.png)
  
  ## total_accel_belt -----------------
  # - integer vector
  # - [0, 29]
  # - no NA values
  # - two local maxima (3, 18) (see imgs/tdata_total_accel_belt_density.png)
  
  ## kurtosis_roll_belt ---------------
  # - factor with a lot of numeric levels and '#DIV/0!' --> added '#DIV/0!' to
  #   na.strings for read.csv call
  # - numeric vector
  # - [-2.121212, 33]
  # - has (a lot of) NA values
  # - one maximum at -0.1 (see imgs/tdata_kurtosis_roll_belt_density.png)
  
  ##  kurtosis_picth_belt -------------
  # - wrong name, should be kurtosis_pitch_belt (I guess)
  # - numeric vector
  # - [-2.190476, 58]
  # - has (a lot of) NA values
  # - one maximum at ~-1 (see imgs/tdata_kurtosis_pitch_belt_density.png)
  
  ## kurtosis_yaw_belt ----------------
  # - only NA values
  
  ## skewness_roll_belt ---------------
  # - numeric vector
  # - [-5.744563, 3.595369]
  # - 19225 of 19622 values are NA (~98%)
  # - maximum at ~0 (see imgs/tdata_skewness_roll_belt_density.png)
  
  tdata
}