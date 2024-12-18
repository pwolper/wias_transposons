library(ggplot2)
library(stringr)

N <- 50000
teInitialCount <- 1
teJumpP <- 0.01
teDeathRate <- 0.0005
simTime <- 2000

# File name parsing function
get_simfiles <- function(path='output/csv', N, teInitialCount, teJumpP, teDeathRate, simTime) {
  pattern <- paste0('haploid_', 'N', N, '_teInitialCount', teInitialCount, '_teJumpP', teJumpP, '_teDeathRate',
                    format(teDeathRate, scientific=FALSE), '_simTime', simTime)
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
  df <- read.csv(file, stringsAsFactors = FALSE)

  params <- extract_params(file)
  means <- rowMeans(df)
  generation <- seq.int(nrow(df))
  replicate <- rep(file, times = length(generation)) # adjust generation time and output in slim

  output_data <- data.frame(replicate, generation, params$N, params$teJumpP, params$teDeathRate, params$simTime, means)
  names(output_data)[3:6] <- c("N", "teJumpP", "teDeathRate", "simTime")
  return(output_data)
}

# Inifitite population equilibrium
expected_equilibrium <- function(teJumpP, teDeathRate) {
  (1+(teJumpP/teDeathRate))
}


files <- get_simfiles('output/csv', N, teInitialCount, teJumpP, teDeathRate, simTime)
paste("Simulation files:", length(files)) # vector of files

df <- do.call(rbind, lapply(files, extract_TE_data))
str(df)

title <- paste(' N=', N, ' | ', 'teJumpP=', teJumpP, ' | ', 'teDeathRate:', teDeathRate)

ggplot(df, aes(x = generation, y = means, color = factor(replicate), group = replicate)) +
  geom_line(size = 0.5, alpha=0.4) +  # Line plot for trajectories
  labs(
    title = paste('Parameters: ', title),
    x = "Generation",
    y = "Mean Value",
    color = "Replicate"
  ) +
  #ylim(0, 100) +
  geom_hline(yintercept = expected_equilibrium(teJumpP, teDeathRate), linetype="dashed", color='red') +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5),  # Center the plot title
        legend.position = "none")               # Place legend on the right)

filename <- paste0('haploid_N', N, 'teJumpP', teJumpP, '_teDeathRate', teDeathRate, '_simTime', simTime, '.png')
ggsave(filename = paste0('output/fig/', filename), height=7, width=10)
