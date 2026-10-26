# Simulate a class with the recipe used in the lecture.
#
# hours studied ~ Uniform(0, 10)
# grade         = 2 + 0.4 * hours + logistic noise (scale 0.5), clipped to 1..6
# exam score    = 20 + 10 * grade   (60 points = grade 4 = pass)
#
# The class on the slides is stored in data/students.csv; this script draws a fresh class
# with the same recipe. Usage: Rscript R/simulate_class.R [n] [seed] [out.csv]

args <- commandArgs(trailingOnly = TRUE)
n    <- if (length(args) >= 1) as.integer(args[1]) else 60
seed <- if (length(args) >= 2) as.integer(args[2]) else 116
out  <- if (length(args) >= 3) args[3] else "data/students_new.csv"

simulate_class <- function(n = 60, intercept = 2, slope = 0.4, noise = 0.5, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  hours <- runif(n, 0, 10)
  grade <- pmin(6, pmax(1, intercept + slope * hours + rlogis(n, scale = noise)))
  score <- 20 + 10 * grade
  data.frame(hours = round(hours, 3), score = round(score, 1), pass = as.integer(score >= 60))
}

students <- simulate_class(n, seed = seed)
write.csv(students, out, row.names = FALSE)
cat("wrote", out, ":", nrow(students), "students,", sum(students$pass), "passed\n")
