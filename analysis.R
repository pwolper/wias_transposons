library(ggplot2)
library(stringr)
library(data.table)


# File name parsing function
get_simfiles <- function(path='output/csv', N, teInitialCount, teJumpP, teDeathRate, simTime, selfRate=NULL) {
  pattern <- paste0(
    "output_TE_", model,
    if (!is.null(selfRate)) paste0('_selfRate', selfRate),
    '_N', format(N, scientific=FALSE),
    '_teInitialCount', teInitialCount, '_teJumpP', teJumpP, '_teDeathRate', format(teDeathRate, scientific=FALSE),
    '_simTime', simTime)

  print(pattern)
  files <- list.files(path, pattern = pattern, full.names=TRUE)
  return(files)
}

# Extract values using regular expressions
extract_params <- function(file) {
  N <- as.numeric(str_extract(file, "(?<=_N)\\d+"))
  teJumpP <- as.numeric(str_extract(file, "(?<=_teJumpP)\\d+\\.\\d+"))
  teDeathRate <- as.numeric(str_extract(file, "(?<=_teDeathRate)\\d+\\.\\d+"))
  simTime <- as.numeric(str_extract(file, "(?<=_simTime)\\d+"))

  params <- list(N = N, teJumpP = teJumpP, teDeathRate = teDeathRate, simTime = simTime)
  return(params)
}

# Extract TE mean to dataframe
extract_TE_data <- function(file) {
  df <- fread(file)
  df_matrix <- as.matrix(df)

  means <- rowMeans(df_matrix)
  row_max <- apply(df_matrix, 1, max)  # Row-wise maximum
  row_min <- apply(df_matrix, 1, min)  # Row-wise minimum

  params <- extract_params(file)
  generation <- seq.int(nrow(df))
  replicate <- rep(file, times = length(generation)) # adjust generation time and output in slim

  output_data <- data.frame(replicate, generation, params$N, params$teJumpP, params$teDeathRate, params$simTime, means, row_min, row_max)
  names(output_data)[3:6] <- c("N", "teJumpP", "teDeathRate", "simTime")
  return(output_data)
}

# Inifitite population equilibrium
expected_equilibrium <- function(teJumpP, teDeathRate) {
  (1+(teJumpP/teDeathRate))
}


model <- 'haploid' #haploid, diploid or selfing_diploid
if (model != 'selfing_diploid') selfRate <- NULL else selfRate <- 1
N <- 5000
teInitialCount <- 1
teJumpP <- 0.01
teDeathRate <- 0.0001
simTime <- 2000
files <- get_simfiles('output/csv', N, teInitialCount, teJumpP, teDeathRate, simTime, selfRate)
paste("Simulation files:", length(files)) # vector of files

df <- do.call(rbind, lapply(files, extract_TE_data))
str(df)

title <- paste(' N=', N, ' | ', 'teJumpP=', teJumpP, ' | ', 'teDeathRate:', teDeathRate)

ggplot(df, aes(x = generation, y = means, color = factor(replicate), group = replicate)) +
  geom_line(aes(y = means, color = factor(replicate)), linewidth = 0.5, alpha = 0.7) +
  geom_line(aes(y = row_min, color = factor(replicate)), linewidth = 0.5, alpha = 0.6, linetype = "dotted") +
  geom_line(aes(y = row_max, color = factor(replicate)), linewidth = 0.5, alpha = 0.6, linetype = "dashed") +
  labs(
    title = paste('Parameters: ', title),
    x = "Generation",
    y = "Mean Value",
    color = "Replicate"
  ) +
  scale_y_continuous(trans='log10') +
  #ylim(0, 2000) +
  #ylim(0, 2000) +
  #geom_hline(yintercept = expected_equilibrium(teJumpP, teDeathRate), linetype="dashed", color='red') +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5),  # Center the plot title
        legend.position = "none")               # Place legend on the right)

filename <- paste0(model , if (!is.null(selfRate)) paste0('_selfRate', selfRate), '_N', N,
                   'teJumpP', teJumpP, '_teDeathRate', teDeathRate, '_simTime', simTime, '.png')
print(filename)

ggsave(filename = paste0('output/fig/', filename), height=7, width=10)
