# Student Transportation & Mobility Analytics

An interactive, static-first analysis of transportation choices, travel behavior, and reported spending among TSD 2022 students. The visitor-facing dashboard runs entirely in the browser on GitHub Pages. R produces versioned JSON; the visitor does **not** need R, a database, an API, or credentials.

## Overview

The original academic study, **Analisis Penggunaan Alat Transportasi Terhadap Pengeluaran Mahasiswa TSD 2022**, has been preserved at the repository root. This portfolio edition separates the reproducible analysis from presentation and calls out sample-size and source-data limitations.

## Live Demo

After publishing, use the URL reported by the GitHub Pages deployment. This repository does not yet contain a verified live URL.

## Dashboard Preview

Run the app locally with `npm install` and `npm run dev`. The dashboard presents a filterable overview, distribution and box charts, relationship explorer, inferential tests, cleaning audit, and methodology in one analytical story.

## Business / Research Questions

1. Which transportation modes are most common among TSD 2022 respondents?
2. How much do respondents report spending on transportation?
3. Does reported spending differ across transportation modes?
4. Are distance, time, mobility score, or age associated with spending?
5. Which data-quality issues matter before interpretation?

## Dataset

`data baru.csv` contains **61 anonymous observations and nine variables**: gender, age, mode, vehicle type, distance, time, cost, vehicle performance, and mobility level. Its reported cost appears to refer to weekly transportation spending in the original research question, but the CSV contains no explicit unit/period metadata. Several very small reported values (0, 20, 30, 40, 100, and 350) remain exactly as recorded; confirm their units before external use. No respondent identifiers are included in the published dataset copy.

## Data Cleaning

`scripts/prepare-data.R` checks missing and blank cells programmatically, preserves the untouched CSV and raw JSON, normalizes `Kurang Baik` → `Kurang baik` in the analytical copy (**3 affected labels**), and applies the original **sequential** 1.5×IQR rule across numeric fields. Distance values **14 km (CSV row 14)** and **8.5 km (CSV row 40)** exceed the original distance upper bound of **7.25 km**; the cleaned sample is **59**. No missing cells were detected. Filtering does not silently delete raw records.

## Exploratory Data Analysis

The full raw sample has 41 private-vehicle users (67.2%), 18 ride-hailing users (29.5%), and two public-transport users (3.3%). Motorcycles appear in 56 records (91.8%). Raw median reported cost is Rp30.000 (mean Rp34.648), median distance 2.7 km, and median travel time 10 min. Descriptive metrics use the raw dataset by default, or whichever dataset and filters the visitor selects.

## Statistical Methods

Inferential results are generated from the **full cleaned sample, n = 59**, not the interactive filters. R runs `shapiro.test`, `kruskal.test`, `cor.test(method = "kendall", exact = FALSE)` (tie-aware asymptotic test), and standardized `prcomp`. Cramér's V uses Pearson χ² / [n × (min(rows, columns) − 1)] on categorical contingency tables. Significance threshold: α = 0.05. The Kruskal–Wallis test is omnibus; no pairwise post-hoc comparison was conducted. Small/sparse cells weaken interpretation of the categorical association matrix.

## Key Findings

- Transportation mode is associated with differences in reported cost (Kruskal–Wallis **H = 11.84, p = 0.00268**). This is an omnibus finding, not proof of a particular pairwise difference or causality.
- Cleaned group medians are ride hailing **Rp50.000** (n = 18), private vehicle **Rp27.000** (n = 39), and public transport **Rp1.000** (n = 2). The public-transport estimate is especially fragile.
- Gender (p = 0.3866), vehicle type (p = 0.1516), and normalized vehicle performance (p = 0.9329) have no statistically significant omnibus cost difference at α = 0.05.
- Age has a weak negative Kendall association with cost (τ = −0.2297, p = 0.0345); the narrow age range limits generalization. Distance, time, and mobility score are not statistically significant.
- All five cleaned numeric variables have Shapiro–Wilk p-values below 0.05; two distance observations are flagged and there are no missing values.

## Dashboard Features

Five filters (gender, mode, vehicle, performance, dataset), five KPIs, mode and vehicle bars, cost histogram with median/mean markers, cost-by-mode boxplots, selectable scatter, Kendall dot chart, Shapiro and Kruskal tables, Cramér's V matrix, PCA variance detail, before/after outlier inspection, cleaning audit, limitations, and accessible chart summaries. Empty filter combinations show a clear empty state. Charts and descriptive metrics update together; inferential tests do not.

## R Shiny Version

`shiny-app/app.R` is a lightweight, dataset-specific Shiny counterpart using only the `shiny` package and base R. Its **Shinylive/webR export is committed under `public/shiny/`** and linked from the dashboard. The export was served over local HTTP and its Overview and Statistics tabs were verified in a browser. The initial browser load can take longer than the static React dashboard because webR starts in the browser.

Run the R source locally after installing Shiny:

```r
install.packages("shiny")
shiny::runApp("shiny-app")
```

To regenerate the static export after changing `shiny-app/`, install `shinylive` and run `Rscript scripts/export-shiny.R`. Test the result through a local HTTP server, never `file://`. For example, after `npm run build`, `httpuv::runStaticServer("dist")` serves the app at `/shiny/`; its Overview and Statistics tabs were verified at that nested path. Because the verified export is versioned, GitHub Actions does not need to install R or download webR assets on every deployment.

## Tech Stack

R, Shiny, Shinylive/webR, React, TypeScript, Vite, Tailwind CSS, Apache ECharts / `echarts-for-react`, Lucide React, GitHub Pages. Neither dashboard requires a running R server after deployment.

## Project Structure

```text
App.R / EVD_A1_*.R / EVD_A1_*.Rmd / EVD_A1_*.pdf  original files, unchanged
data baru.csv                  original survey CSV, unchanged
scripts/prepare-data.R        reproducible R preprocessing/statistics
src/data/                     generated raw, cleaned, and summary JSON
src/components/dashboard/     charts, tables, insights, quality audit
src/utils/analytics.ts        descriptive calculations and formatting
shiny-app/                    Shiny source + CSV copy
public/shiny/                 verified static Shinylive export
public/data-baru.csv          anonymous downloadable dataset
.github/workflows/deploy.yml  static Pages build and deploy
```

## Running Locally

Node 22 is used in CI. Run `npm ci`, then `npm run dev` and open the printed local URL. Run `npm run build` and `npm run preview` for the production bundle. Windows paths containing `&` can confuse npm-generated executable shims; the scripts call the dependency CLIs through Node directly. If your global `npm` launcher is broken, invoke its installed `npm-cli.js` directly or repair the Node installation.

## Reproducing the Analysis

From the repository root, run `Rscript scripts/prepare-data.R` (base R only). It regenerates all three committed JSON files. Review changes before committing. The generated summary contains sample sizes, missingness, outliers, descriptives, distributions, Shapiro–Wilk, Kruskal–Wallis, Kendall, Cramér's V, and PCA explained variance. The React app never runs R in a visitor's browser.

## GitHub Pages Deployment

Push to `main`, then in **Settings → Pages → Build and deployment**, choose **GitHub Actions**. The workflow installs locked npm dependencies, builds, uploads `dist` (including `dist/shiny/`), and deploys it. `base: './'` supports project repositories without a hardcoded repository name. The versioned Shinylive export is copied from `public/shiny/`; CI does not need R. If your default branch is not `main`, change the workflow's `push.branches` entry. For a nonstandard repository URL, set `VITE_SOURCE_URL` at build time to point the header to the correct source repository.

## Limitations

Small convenience sample, observational design, no causal claims, only two public-transport users, narrow ages, and possible ambiguity in very small cost reports. Shapiro–Wilk on highly discrete variables has interpretive limitations; results are reported transparently. Multiple exploratory tests were not adjusted for multiplicity. The dashboard does not claim representative population estimates.

## Original Academic Project

The original `App.R`, `.R`, `.Rmd`, `.pdf`, and `data baru.csv` remain unchanged in place as historical evidence. The original Shiny upload app was generic; this portfolio redesign is dataset-specific and static-first.
