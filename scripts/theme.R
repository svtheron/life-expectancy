# ============================================================
# Title:   Theme and Palette
# Purpose: Defines my_theme(), a minimal ggplot2 theme, and the colours
#          shared by every figure
# Inputs:  None
# Outputs: my_theme(), pick_font(), col_* colour constants
# ============================================================

# One accent for the focus group (Africa), one for everyone else
col_africa  <- "#D55E00"
col_rest    <- "#0072B2"
col_ink     <- "#1F2933"
col_text    <- "#52606D"
col_muted   <- "#9AA5B1"
col_context <- "#B8C2CC"
col_grid    <- "#E4E7EB"

# Prefer Atkinson Hyperlegible; fall back to the system sans font
pick_font <- function(preferred = "Atkinson Hyperlegible") {
  if (preferred %in% systemfonts::system_fonts()$family) preferred else "sans"
}

my_theme <- function(base_font = pick_font(), base_size = 13) {
  theme_minimal(base_family = base_font, base_size = base_size) +
    theme(
      text                  = element_text(colour = col_ink),
      plot.title            = element_text(face = "bold", size = rel(1.4), margin = margin(b = 4)),
      plot.subtitle         = element_text(colour = col_text, size = rel(0.95), margin = margin(b = 14)),
      plot.caption          = element_text(colour = col_muted, size = rel(0.7), hjust = 0, margin = margin(t = 14)),
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.margin           = margin(14, 18, 10, 14),
      plot.background       = element_rect(fill = "white", colour = NA),
      axis.title            = element_text(colour = col_text, size = rel(0.85)),
      axis.text             = element_text(colour = col_text, size = rel(0.85)),
      legend.title          = element_text(size = rel(0.85)),
      legend.text           = element_text(size = rel(0.85)),
      legend.margin         = margin(0, 0, 0, 0),
      legend.box.spacing    = unit(2, "pt"),
      panel.grid.minor      = element_blank(),
      panel.grid.major      = element_line(colour = col_grid, linewidth = 0.35),
      strip.text            = element_text(face = "bold", size = rel(0.95), hjust = 0)
    )
}
