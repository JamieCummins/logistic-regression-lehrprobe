# Logistic regression: the class from the lecture

This repository accompanies the lehrprobe for **logistic regression**. In this lecture section, we look at one class of 60 students, examining how many hours each of them studied and whether they passed an exam. Every number on the slides comes from that class and from one model:

```r
fit <- glm(pass ~ hours, family = binomial, data = students)
```

log-odds of passing = −3.94 + 0.80 × hours, which is an odds ratio of 2.2 per extra hour.

Here you can re-run those numbers yourself, play with the demo from the lecture, and simulate classes of your own. 

## What is here

| Path | What it is |
|---|---|
| `data/students.csv` | The class from the lecture, which consists of 60 students, `hours` studied, exam `score` (0–100, pass at 60), our dichotomous `pass` variable (0/1). |
| `R/slide_numbers.R` | Fits the model to that class and prints every number seen on the slides, including the coefficients, `exp(coef)`, table content, the six-hour example and `summary(fit)`. |
| `R/simulate_class.R` | Simulates a new class, so you can see what changes and what stays the same when the students change. |
| `app/probabilities-and-odds-demo.html` | The **Probabilities and Odds Demo** from the lecture: one self-contained HTML file. Open it in a browser (just double-click it). Simulate a class, change the slope, and watch how the probability curve, the odds curve and the log-odds line move together. |
| `shiny/app.R` | The same demo written in R as a Shiny app, for anyone who wants to read how the plots are made or extend it. |

## Start here

From the shell:

```sh
Rscript R/slide_numbers.R                 # the numbers on the slides
Rscript R/simulate_class.R 60 1 my.csv    # a new class: n, seed, output file
R -e 'shiny::runApp("shiny")'             # the Shiny version (needs shiny, ggplot2)
```

Or, in RStudio, open `R/slide_numbers.R` and run it line by line. The two lines to try changing are the model call (`glm(...)`) and the hours in the table (`h <- 4:8`).

## Three things to try out

If you are reading this, I'm glad you got this far! I would provide students with some follow-up questions like the following:

1. **Read the coefficients three ways.** `coef(fit)` is on the log-odds scale, `exp(coef(fit))` is on the odds scale, and `predict(fit, type = "response")` is on the probability scale. Which one do you think is most interpretable (i.e., which would you report to a friend who has not taken this course?).
2. **Simulate a new class.** `Rscript R/simulate_class.R 60 2 my.csv`, then fit the model to `my.csv`. The slope will not be exactly 0.80. Think about why not. How different is it with 600 students instead of 60?

## The data-generating process

The class is simulated, so we know the truth behind the data. Each student is drawn like this:

```
hours studied ~ Uniform(0, 10)
grade         = 2 + 0.4 × hours + noise, with bounds of 1–6 (i.e., standard Swiss grading scale)
exam score    = 20 + 10 × grade (60 points = grade 4 = pass)
```

The students in the lecture are an ordinary draw from this data-generated process, chosen so that the fitted slope is around 0.80.

## Why the materials look like this

A short note on the thinking behind this repository (again, if you got this far!).

- **Simulated data and a known truth.** Students meet logistic regression on a class whose data-generating process is written out above. They can check what the model recovers against what we put in. This is something I would bring to all classes when teaching statistics: namely, the use of simulation to give students a "correct" answer.
- **Moving from probabilities to log-odds and back.** The demo exists because the hardest step in this topic is seeing that probability, odds and log-odds are three views of the same model. Moving one slider and watching all three plots respond makes the link visible and practical to students.
- **Everything in R.** The course is taught in R, so the data, the numbers and the Shiny version of the demo are R. The HTML demo is there so the app also works on a phone in the lecture hall with no installation.
- **Same approach every week.** For all models, I would teach with the same overarching formula: simulate data, fit the model, interpret coefficients, and predict observations. 

## Licence

Code: MIT (see `LICENSE`). Data: CC0. 
