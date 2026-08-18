# make_figs.R -------------------------------------------------------------
# Figure: EUA price series with the proposed sample window marked.
#
# SCOPE NOTE. The paper is a design proposal and does not estimate anything.
# This script is the only part of the repository that reads external data,
# and it produces an illustrative price series for the policy background.
# It performs no estimation.
#
# DATA. Ember, EU ETS carbon price viewer:
#   https://ember-energy.org/data/carbon-price-viewer/
# Download the CSV export(s) into this directory before running. The script
# accepts either the single current export or the two historical files, and
# de-duplicates the overlap between them.
#
# USAGE   Rscript make_figs.R          (run from inside figs/)
# OUTPUT  eua_price.pdf
#
# Base R only. No packages, no network access.
# -------------------------------------------------------------------------

candidates   <- c("eua-price.csv", "EMBER_Coal2Clean_EUETSPrices.csv",
                  "carbon-price-viewer.csv", "eua_price.csv")
outfile      <- "eua_price.pdf"
sample_start <- as.Date("2005-01-01")
sample_end   <- as.Date("2021-12-31")

# ---- read -----------------------------------------------------------------
# Column names differ between Ember exports, so take the first two columns
# positionally and coerce, rather than relying on a header string.
read_one <- function(path) {
  if (!file.exists(path)) return(NULL)
  d <- utils::read.csv(path, stringsAsFactors = FALSE)
  if (ncol(d) < 2L) {
    warning("Fewer than two columns in ", path, "; skipped.")
    return(NULL)
  }
  out <- data.frame(Date  = as.Date(d[[1]]),
                    Price = suppressWarnings(as.numeric(d[[2]])))
  out <- out[!is.na(out$Date) & !is.na(out$Price), ]
  message("Read ", nrow(out), " rows from ", path)
  out
}

parts <- Filter(Negate(is.null), lapply(candidates, read_one))

if (length(parts) == 0L) {
  stop("No input CSV found in this directory. Expected one of: ",
       paste(candidates, collapse = ", "),
       "\nDownload the series from https://ember-energy.org/data/carbon-price-viewer/")
}

eua <- do.call(rbind, parts)

# The two historical Ember exports OVERLAP (the first runs to Feb 2021, the
# second starts Jan 2021). A plain rbind therefore double-counts that period
# and, because the rows are not ordered, draws a line that doubles back on
# itself. Sort by date and drop duplicate dates, keeping the first occurrence.
eua <- eua[order(eua$Date), ]
dup <- duplicated(eua$Date)
if (any(dup)) message("Dropped ", sum(dup), " duplicate dates from the overlap.")
eua <- eua[!dup, ]

message("Series: ", format(min(eua$Date)), " to ", format(max(eua$Date)),
        " (", nrow(eua), " observations); max ",
        format(round(max(eua$Price), 2), nsmall = 2), " EUR/tCO2")

if (min(eua$Date) > sample_start) {
  message("NOTE: series begins ", format(min(eua$Date)),
          ", after the ", format(sample_start), " sample start. ",
          "Phase I (2005-2007) is not covered by this source; ",
          "say so in the caption or add a Phase I series.")
}

# ---- plot -----------------------------------------------------------------
ymax <- ceiling(max(eua$Price) / 10) * 10

grDevices::pdf(file = outfile, width = 7.5, height = 4.2, pointsize = 11)
par(mar = c(3.0, 3.4, 0.8, 0.8), mgp = c(2.0, 0.6, 0), las = 1)

plot(eua$Date, eua$Price, type = "n", ylim = c(0, ymax),
     xlab = "", ylab = "", axes = FALSE)

# proposed sample window
rect(sample_start, 0, sample_end, ymax,
     col = grDevices::rgb(0.85, 0.89, 0.95, 0.7), border = NA)

# policy events
events <- data.frame(
  date  = as.Date(c("2019-01-01", "2021-07-14", "2026-01-01")),
  label = c("MSR operational", "CBAM proposal", "CBAM definitive")
)
events <- events[events$date >= min(eua$Date) & events$date <= max(eua$Date), ]
if (nrow(events) > 0L) {
  abline(v = events$date, lty = 3, col = "grey40")
  text(events$date, ymax * 0.97, events$label,
       cex = 0.7, col = "grey25", pos = 2, srt = 90, offset = 0.3)
}

lines(eua$Date, eua$Price, col = "firebrick", lwd = 1.8)

axis.Date(1, at = seq(as.Date("2008-01-01"), max(eua$Date), by = "2 years"),
          format = "%Y", tck = -0.02, cex.axis = 0.85)
axis(2, tck = -0.02, cex.axis = 0.85)
box(bty = "l")

mtext("EUR per tonne of CO2", side = 2, line = 2.2, cex = 0.95, las = 0)
text(sample_start + (sample_end - sample_start) / 2, ymax * 0.06,
     "proposed sample window", cex = 0.75, col = "grey25")

invisible(grDevices::dev.off())
message("Wrote ", outfile)
