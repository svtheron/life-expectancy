my_theme <- function(base_font = "mono") {
  theme_minimal(base_family = base_font) +
    theme(
      plot.title       = element_text(face = "bold", size = 14),
      plot.subtitle    = element_text(colour = "grey40", size = 11),
      plot.caption     = element_text(colour = "grey60", size = 8),
      axis.title       = element_text(size = 10),
      axis.text        = element_text(size = 9),
      legend.title     = element_text(size = 10),
      legend.text      = element_text(size = 9),
      panel.grid.minor = element_blank(),
      strip.text       = element_text(face = "bold", size = 10)
    )
}