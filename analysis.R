N <- 10
teInitialCount <- 1
teJumpP <- 0.01
teDeathRate <- format(0.0005, scientific = FALSE)
simTime <- 100

## File name parsing function
path <- file.path('output/csv')   # portable

pattern <- paste0('haploid_', 'N', N, '_teInitialCount', teInitialCount,
                  '_teJumpP', teJumpP, '_teDeathRate', teDeathRate, '_simTime', simTime)
print(pattern)

files <- list.files(path, pattern = pattern, full.names=TRUE)
##print(str(files[1]))


i <- 1

file <-  files[i]

df <- read.csv(file, stringsAsFactors = FALSE)
df

meanTE <- rowMeans(df)
generation <- seq.int(nrow(df))
rep <- rep(i, times = length(generation)) # adjust generation time and output in slim
means <- data.frame(rep, generation, meanTE)
means
