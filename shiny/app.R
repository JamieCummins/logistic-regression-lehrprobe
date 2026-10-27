# Probabilities and Odds Demo (Shiny version): the same model on three scales.
# Run with: shiny::runApp("shiny")   (needs shiny and ggplot2)
#
# The app used in the lecture is the self-contained HTML version in app/, which needs no R.
# This Shiny version mirrors it: simulate a class, fit the logistic regression, and watch the
# probability curve, the odds curve and the log-odds line move together.
library(shiny)
library(ggplot2)

RED <- "#CF2C3F"; INK <- "#1d1d1f"; GREY <- "#5f5f66"; LIGHT <- "#a3a3aa"
PASS <- 60; NOISE <- 0.5; SEED <- 116; HRS <- 4:8
lecture_class <- if (file.exists("../data/students.csv")) read.csv("../data/students.csv") else NULL

css <- "
  body { font-family: Inter, Helvetica, Arial, sans-serif; color: #1d1d1f; background: #ffffff; }
  .container-fluid { max-width: 1180px; padding: 24px 28px; }
  h1 { font-size: 28px; font-weight: 700; color: #CF2C3F; margin: 0 0 18px; }
  h3 { font-size: 16px; font-weight: 700; margin: 0 0 8px; }
  .lab { font-size: 12px; letter-spacing: 1.5px; text-transform: uppercase; color: #5f5f66; font-weight: 700; margin: 0 0 6px; }
  .well { background: #f4f4f6; border: 0; border-radius: 14px; box-shadow: none; padding: 18px; }
  .btn { border-radius: 10px; font-weight: 700; background: #CF2C3F; color: #fff; border: 0; }
  .irs--shiny .irs-bar, .irs--shiny .irs-single, .irs--shiny .irs-handle { background: #CF2C3F; border-color: #CF2C3F; }
  table.t { width: 100%; max-width: 720px; border-collapse: collapse; font-size: 15px; }
  table.t th { font-size: 11px; letter-spacing: 1px; text-transform: uppercase; color: #5f5f66; font-weight: 700; padding: 6px 8px; border-bottom: 2px solid #1d1d1f; text-align: right; }
  table.t th:first-child, table.t td:first-child { text-align: left; }
  table.t td { padding: 7px 8px; text-align: right; border-bottom: 1px solid #e2e2e6; }
  table.t td.or { color: #CF2C3F; font-weight: 700; } table.t td.dp { font-weight: 700; }
  .note { color: #5f5f66; font-size: 13px; margin-top: 8px; }
"

ui <- fluidPage(
  tags$head(tags$style(HTML(css))),
  titlePanel(NULL, windowTitle = "Probabilities and Odds Demo"),
  h1("Probabilities and Odds Demo"),
  sidebarLayout(
    sidebarPanel(width = 3,
      div(class = "lab", "Simulate"),
      sliderInput("n", "Students", min = 10, max = 500, value = 60, step = 10, ticks = FALSE),
      sliderInput("b0", "Grade at 0 hours", min = 1, max = 6, value = 2, step = 0.5, ticks = FALSE),
      sliderInput("b1", "Grade points per hour", min = 0, max = 1, value = 0.4, step = 0.05, ticks = FALSE),
      actionButton("newclass", "New class")
    ),
    mainPanel(width = 9,
      fluidRow(
        column(4, h3("Probability of passing"), plotOutput("p_prob", height = 250)),
        column(4, h3("Odds of passing"), plotOutput("p_odds", height = 250)),
        column(4, h3("Log-odds of passing"), plotOutput("p_logodds", height = 250))
      ),
      h3("One more hour"),
      uiOutput("tbl")
    )
  )
)

simulate_class <- function(n, b0, b1, seed) {
  set.seed(seed)
  hours <- runif(n, 0, 10)
  grade <- pmin(6, pmax(1, b0 + b1 * hours + rlogis(n, scale = NOISE)))
  score <- 20 + 10 * grade
  data.frame(hours = hours, score = score, pass = as.integer(score >= PASS))
}

server <- function(input, output, session) {
  dat <- reactive({
    k <- input$newclass
    if (k == 0 && !is.null(lecture_class) && input$n == 60 && input$b0 == 2 && input$b1 == 0.4) return(lecture_class)
    simulate_class(input$n, input$b0, input$b1, SEED + k)
  })
  fit <- reactive({
    d <- dat()
    npass <- sum(d$pass)
    if (npass == 0 || npass == nrow(d)) return(list(ok = FALSE, why = if (npass == 0) "Nobody passed: there is nothing to model." else "Everybody passed: there is nothing to model."))
    m <- suppressWarnings(glm(pass ~ hours, family = binomial, data = d))
    b <- coef(m)
    if (any(!is.finite(b)) || abs(b[2]) > 20) return(list(ok = FALSE, why = "Pass and fail are (almost) perfectly separated by hours, so the slope cannot be estimated."))
    list(ok = TRUE, a = unname(b[1]), b = unname(b[2]), why = "")
  })

  base_theme <- theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank(), panel.grid.major = element_line(colour = "#ececef"),
          axis.title = element_text(colour = INK, face = "bold"), axis.text = element_text(colour = GREY),
          plot.background = element_rect(fill = "white", colour = NA))
  curve <- function(f) { x <- seq(0, 10, length.out = 201); data.frame(hours = x, y = f(x)) }

  output$p_prob <- renderPlot({
    d <- dat(); f <- fit()
    g <- ggplot() + geom_point(data = d, aes(hours, pass), colour = ifelse(d$pass == 1, INK, LIGHT), size = 2.4, alpha = 0.6)
    if (f$ok) {
      P <- function(h) plogis(f$a + f$b * h)
      st <- data.frame(x = HRS[-length(HRS)], xend = HRS[-1], y = P(HRS[-length(HRS)]), yend = P(HRS[-1]))
      g <- g + geom_line(data = curve(P), aes(hours, y), colour = RED, linewidth = 1.4) +
        geom_segment(data = st, aes(x = x, xend = xend, y = y, yend = y), colour = INK, linewidth = 0.8) +
        geom_segment(data = st, aes(x = xend, xend = xend, y = y, yend = yend), colour = INK, linewidth = 0.8) +
        geom_point(data = data.frame(hours = HRS, y = P(HRS)), aes(hours, y), colour = INK, size = 3)
    }
    g + scale_x_continuous(limits = c(0, 10), breaks = seq(0, 10, 2)) + scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
      labs(x = "Hours studied", y = "Probability of passing") + base_theme
  })
  output$p_odds <- renderPlot({
    f <- fit()
    g <- ggplot() + scale_x_continuous(limits = c(0, 10), breaks = seq(0, 10, 2)) + labs(x = "Hours studied", y = "Odds of passing") + base_theme
    if (!f$ok) return(g + ylim(0, 1.5))
    O <- function(h) exp(f$a + f$b * h); top <- min(max(O(10), O(0), 1.5), 1e6)
    g + geom_line(data = curve(function(h) pmin(O(h), top)), aes(hours, y), colour = RED, linewidth = 1.4) +
      geom_point(data = data.frame(hours = HRS, y = O(HRS)), aes(hours, y), colour = INK, size = 3) + ylim(0, top)
  })
  output$p_logodds <- renderPlot({
    f <- fit()
    g <- ggplot() + scale_x_continuous(limits = c(0, 10), breaks = seq(0, 10, 2)) + labs(x = "Hours studied", y = "Log-odds of passing") + base_theme
    if (!f$ok) return(g + ylim(-4, 4))
    L <- function(h) f$a + f$b * h
    g + geom_line(data = curve(L), aes(hours, y), colour = RED, linewidth = 1.4) +
      geom_point(data = data.frame(hours = HRS, y = L(HRS)), aes(hours, y), colour = INK, size = 3)
  })
  output$tbl <- renderUI({
    f <- fit()
    if (!f$ok) return(tagList(HTML("<table class='t'><tr><th>Hours</th><th>Probability</th><th>Change</th><th>Odds</th><th>Ratio to hour before</th></tr></table>"), div(class = "note", f$why)))
    p <- plogis(f$a + f$b * HRS); odds <- exp(f$a + f$b * HRS); OR <- exp(f$b)
    rows <- vapply(seq_along(HRS), function(i) sprintf("<tr><td>%d</td><td>%d%%</td><td class='dp'>%s</td><td>%s</td><td class='or'>%s</td></tr>",
      HRS[i], round(100 * p[i]), if (i == 1) "–" else sprintf("+%d points", round(100 * (p[i] - p[i - 1]))),
      formatC(odds[i], digits = 2, format = "f"), if (i == 1) "–" else sprintf("×%.2f", OR)), character(1))
    HTML(sprintf("<table class='t'><tr><th>Hours</th><th>Probability</th><th>Change</th><th>Odds</th><th>Ratio to hour before</th></tr>%s</table>", paste(rows, collapse = "")))
  })
}

shinyApp(ui, server)
