# Optional: regenerate the committed Shinylive assets after changing shiny-app/.
# Install shiny + shinylive first, then run from the repository root.
stopifnot(requireNamespace("shinylive", quietly = TRUE))
shinylive::export("shiny-app", "public/shiny",
  template_params = list(title = "Student Transportation & Mobility Analytics"))
