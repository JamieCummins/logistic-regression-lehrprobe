# Fit the model to the lecture class and print every number that appears on the slides.
# Usage: Rscript R/slide_numbers.R

options(digits = 3)
students <- read.csv("data/students.csv")

# Linear regression on the 0/1 outcome (the "why not a straight line" slide)
line <- lm(pass ~ hours, data = students)
cat("\n--- Straight line through the 0s and 1s ---\n"); print(coef(line))

# Logistic regression: a straight line for the log-odds, fitted by maximum likelihood
fit <- glm(pass ~ hours, family = binomial, data = students)
cat("\n--- summary(fit) ---\n"); print(summary(fit))

cat("\n--- Coefficients on the log-odds scale ---\n"); print(coef(fit))
cat("\n--- Back to odds: exp(coef(fit)) ---\n"); print(exp(coef(fit)))

# The table: hours 4 to 8
h <- 4:8
p <- predict(fit, data.frame(hours = h), type = "response")
odds <- p / (1 - p)
tab <- data.frame(hours = h,
                  probability = paste0(round(100 * p), "%"),
                  change = c(NA, paste0("+", round(100 * diff(p)))),
                  odds = round(odds, 2),
                  ratio = c(NA, round(odds[-1] / odds[-length(odds)], 2)))
cat("\n--- One more hour ---\n"); print(tab, row.names = FALSE)

# Step by step for a student with 6 hours
cat("\n--- Six hours, by hand ---\n")
odds6 <- exp(predict(fit, data.frame(hours = 6)))
cat("log-odds:", predict(fit, data.frame(hours = 6)), " odds:", odds6, " probability:", odds6 / (1 + odds6), "\n")
cat("\n--- predict(fit, data.frame(hours = 5), type = \"response\") ---\n")
print(predict(fit, data.frame(hours = 5), type = "response"))
