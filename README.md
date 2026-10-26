# Logistic regression: the class from the lecture

This repository goes with the lecture on **interpreting a logistic regression**. In the lecture we looked at one class of 60 students: how many hours each of them studied, and whether they passed the exam. Every number on the slides comes from that class and from one model:

```r
fit <- glm(pass ~ hours, family = binomial, data = students)
```

log-odds of passing = −3.94 + 0.80 × hours, which is an odds ratio of 2.2 per extra hour.

Here you can re-run those numbers yourself, play with the demo from the lecture, and simulate classes of your own. Nothing in this repository needs more than R.

## What is here

| Path | What it is |
|---|---|
| `data/students.csv` | The class from the lecture: 60 students, `hours` studied, exam `score` (0–100, pass at 60), `pass` (0/1). |
| `R/slide_numbers.R` | Fits the model to that class and prints every number on the slides: the coefficients, `exp(coef)`, the hours-4-to-8 table, the six-hour example and `summary(fit)`. Start here. |
| `R/simulate_class.R` | Draws a fresh class with the recipe below, so you can see what changes and what stays the same when the students change. |
| `app/probabilities-and-odds-demo.html` | The **Probabilities and Odds Demo** from the lecture: one self-contained HTML file. Open it in a browser (double-click it, no R and no server needed). Simulate a class, change the slope, and watch the probability curve, the odds curve and the log-odds line move together. |
| `shiny/app.R` | The same demo written in R as a Shiny app, for anyone who wants to read how the plots are made or extend it. |

## Start here

```sh
Rscript R/slide_numbers.R                 # the numbers on the slides
Rscript R/simulate_class.R 60 1 my.csv    # a new class: n, seed, output file
R -e 'shiny::runApp("shiny")'             # the Shiny version (needs shiny, ggplot2)
```

Or, in RStudio, open `R/slide_numbers.R` and run it line by line. The two lines to try changing are the model call (`glm(...)`) and the hours in the table (`h <- 4:8`).

## Three things to try

1. **Check the slides.** Run `R/slide_numbers.R` and compare the output with your notes: −3.94, 0.80, 2.2, and the table from 32% at four hours to 92% at eight.
2. **Read the coefficients three ways.** `coef(fit)` is on the log-odds scale, `exp(coef(fit))` is on the odds scale, and `predict(fit, type = "response")` is on the probability scale. Same model, three scales. Which one would you report to a friend who has not taken this course?
3. **Simulate a new class.** `Rscript R/simulate_class.R 60 2 my.csv`, then fit the model to `my.csv`. The slope will not be exactly 0.80. Why not? How different is it with 600 students instead of 60?

## The recipe

The class is simulated, so we know the truth behind the data. Each student is drawn like this:

```
hours studied ~ Uniform(0, 10)
grade         = 2 + 0.4 × hours + logistic noise (scale 0.5), clipped to the Swiss 1–6 scale
exam score    = 20 + 10 × grade          (60 points = grade 4 = pass)
```

The students in the lecture are an ordinary draw from this recipe, chosen so that the fitted slope is a round 0.80. Nothing was hand-edited. That draw is stored in `data/students.csv`, so every number on the slides is reproducible from the file.

## Why the materials look like this

A short note on the thinking behind this repository.

- **Simulated data, known truth.** Students meet logistic regression on a class whose data-generating recipe is written out above. They can check what the model recovers against what we put in, and see that the model is a description of a pattern, not the pattern itself.
- **One model behind every number.** Every value on the slides is produced by `R/slide_numbers.R` from `data/students.csv`. If a student does not believe a number, they can run the script.
- **Three scales, one curve.** The demo exists because the hardest step in this topic is seeing that probability, odds and log-odds are three views of the same model. Moving one slider and watching all three plots respond makes the link visible in a way a formula does not.
- **Everything in R.** The course is taught in R, so the data, the numbers and the Shiny version of the demo are R. The HTML demo is there so the app also works on a phone in the lecture hall with no installation.
- **Same recipe every week.** Simulate, fit, interpret, predict is the pattern of every lecture in the course. This repository is one week of it.

## Licence

Code: MIT (see `LICENSE`). Data: CC0. The slides are not part of this repository.
