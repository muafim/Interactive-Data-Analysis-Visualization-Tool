# Reproduce the original sequential 1.5 x IQR cleaning with base R only.
# Run from the repository root: Rscript scripts/prepare-data.R
source_file <- "data baru.csv"
stopifnot(file.exists(source_file))
raw <- read.csv(source_file, check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(identical(names(raw), c("gender", "umur", "transportasi", "jenis_kendaraan", "jarak", "waktu", "biaya", "performa_kendaraan", "tingkat_mobilitas")))
numeric_fields <- names(raw)[vapply(raw, is.numeric, logical(1))]
categorical_fields <- c("gender", "transportasi", "jenis_kendaraan", "performa_kendaraan")
missing_by_field <- vapply(raw, function(x) sum(is.na(x) | (is.character(x) & trimws(x) == "")), integer(1))

# Keep the original CSV unchanged; normalize only the in-memory analytical copy.
normalized <- raw
normalized$performa_kendaraan[normalized$performa_kendaraan == "Kurang Baik"] <- "Kurang baik"
label_changes <- sum(raw$performa_kendaraan != normalized$performa_kendaraan)
cleaned <- normalized
outlier_log <- list()
for (field in numeric_fields) {
  q <- quantile(cleaned[[field]], c(.25, .75), na.rm = TRUE)
  bounds <- c(q[1] - 1.5 * diff(q), q[2] + 1.5 * diff(q))
  flagged <- which(!is.na(cleaned[[field]]) & (cleaned[[field]] < bounds[1] | cleaned[[field]] > bounds[2]))
  if (length(flagged)) for (i in flagged) outlier_log[[length(outlier_log) + 1L]] <- list(
    sourceRow = as.integer(rownames(cleaned)[i]) + 1L, variable = field,
    value = cleaned[[field]][i], lower = unname(bounds[1]), upper = unname(bounds[2]))
  if (length(flagged)) cleaned <- cleaned[-flagged, , drop = FALSE]
}

# Small dependency-free JSON writer; only serializes the finite scalars and objects
# produced here. This keeps the reproducibility script runnable on a fresh R install.
escape_json <- function(x) {
  x <- gsub("\\\\", "\\\\\\\\", x)
  x <- gsub('"', '\\\"', x, fixed = TRUE)
  x <- gsub("\n", "\\n", x, fixed = TRUE)
  x <- gsub("\r", "\\r", x, fixed = TRUE)
  paste0('"', x, '"')
}
to_json <- function(x) {
  if (is.data.frame(x)) return(paste0("[", paste(vapply(seq_len(nrow(x)), function(i) to_json(as.list(x[i, , drop = FALSE])), character(1)), collapse = ","), "]"))
  if (is.list(x)) {
    if (!is.null(names(x))) return(paste0("{", paste(paste0(escape_json(names(x)), ":", vapply(x, to_json, character(1))), collapse = ","), "}"))
    return(paste0("[", paste(vapply(x, to_json, character(1)), collapse = ","), "]"))
  }
  if (length(x) != 1L) return(paste0("[", paste(vapply(as.list(x), to_json, character(1)), collapse = ","), "]"))
  if (is.na(x) || !is.finite(if (is.numeric(x)) x else 0)) return("null")
  if (is.character(x)) return(escape_json(x))
  if (is.logical(x)) return(tolower(as.character(x)))
  format(x, scientific = FALSE, digits = 16, trim = TRUE)
}
write_json <- function(object, path) writeLines(to_json(object), path, useBytes = TRUE)

records <- function(d) {
  names(d) <- c("gender", "umur", "transportasi", "jenisKendaraan", "jarak", "waktu", "biaya", "performaKendaraan", "tingkatMobilitas")
  d
}
distribution <- function(x) as.list(table(x))
descriptive <- function(d) lapply(d[numeric_fields], function(x) list(
  mean = mean(x), median = median(x), min = min(x), max = max(x),
  q1 = unname(quantile(x, .25)), q3 = unname(quantile(x, .75))))
shapiro <- lapply(numeric_fields, function(field) {
  test <- shapiro.test(cleaned[[field]])
  list(variable = field, statistic = unname(test$statistic), pValue = test$p.value)
})
kruskal <- lapply(categorical_fields, function(field) {
  test <- kruskal.test(cleaned$biaya, as.factor(cleaned[[field]]))
  list(variable = field, statistic = unname(test$statistic), degreesOfFreedom = unname(test$parameter), pValue = test$p.value)
})
kendall <- lapply(setdiff(numeric_fields, "biaya"), function(field) {
  # R's asymptotic test accounts for ties, as in the original analysis.
  test <- suppressWarnings(cor.test(cleaned$biaya, cleaned[[field]], method = "kendall", exact = FALSE))
  list(variable = field, tau = unname(test$estimate), pValue = test$p.value)
})
cramers_v <- function(a, b) {
  tab <- table(a, b)
  if (min(dim(tab)) < 2L) return(NULL)
  test <- suppressWarnings(chisq.test(tab, correct = FALSE))
  sqrt(unname(test$statistic) / (sum(tab) * (min(dim(tab)) - 1)))
}
matrix_data <- lapply(seq_along(categorical_fields), function(i) {
  lapply(seq_along(categorical_fields), function(j) {
    if (i == j) return(1)
    cramers_v(cleaned[[categorical_fields[i]]], cleaned[[categorical_fields[j]]])
  })
})
pca <- prcomp(cleaned[numeric_fields], center = TRUE, scale. = TRUE)
variance <- pca$sdev^2 / sum(pca$sdev^2)

summary <- list(
  sample = list(raw = nrow(raw), cleaned = nrow(cleaned), removed = nrow(raw) - nrow(cleaned)),
  quality = list(missingByField = as.list(missing_by_field), missingTotal = sum(missing_by_field),
    normalizedLabels = label_changes, normalization = list(from = "Kurang Baik", to = "Kurang baik", field = "performa_kendaraan"),
    outliers = outlier_log),
  descriptive = list(raw = descriptive(normalized), cleaned = descriptive(cleaned)),
  distributions = list(transportation = distribution(normalized$transportasi), vehicle = distribution(normalized$jenis_kendaraan)),
  groupCost = lapply(split(cleaned$biaya, cleaned$transportasi), function(x) list(n = length(x), median = median(x))),
  shapiro = shapiro, kruskal = kruskal, kendall = kendall,
  cramersV = list(variables = categorical_fields, values = matrix_data),
  pca = list(explainedVariance = as.list(variance)), alpha = .05
)
dir.create("src/data", recursive = TRUE, showWarnings = FALSE)
write_json(records(raw), "src/data/transportation.json")
write_json(records(cleaned), "src/data/transportation-cleaned.json")
write_json(summary, "src/data/analysis-summary.json")
cat("Generated JSON:", nrow(raw), "raw,", nrow(cleaned), "cleaned;", length(outlier_log), "outliers.\n")
print(data.frame(test = vapply(kruskal, `[[`, "", "variable"), p = vapply(kruskal, `[[`, 0, "pValue")))
