#' @importFrom insight format_p format_pd format_bf format_value export_table
#' @export
format.easycormatrix <- function(x, digits = 2, stars = TRUE, ...) {
  orig_x <- x
  nums <- sapply(as.data.frame(x), is.numeric)

  # Find attributes
  p <- attributes(x)

  if ("stars" %in% names(p)) {
    stars <- p$stars
  }

  # Significance
  type <- names(p)[names(p) %in% c("BF", "pd", "p")][1]
  p <- p[[type]]

  if (!is.null(p)) {
    if (type == "p") {
      p[, nums] <- sapply(p[, nums], insight::format_p, stars_only = TRUE)
    } else if (type == "pd") {
      p[, nums] <- sapply(p[, nums], insight::format_pd, stars_only = TRUE)
    } else if (type == "BF") {
      p[, nums] <- sapply(p[, nums], insight::format_bf, stars_only = TRUE)
    }

    # Round and eventually add stars
    x[, nums] <- sapply(as.data.frame(x)[, nums], insight::format_value, digits = digits)
    if (stars) {
      x[, nums] <- paste0(as.matrix(as.data.frame(x)[, nums]), as.matrix(p[, nums]))
    }
  } else {
    x[, nums] <- sapply(as.data.frame(x)[, nums], insight::format_value, digits = digits)
  }

  as.data.frame(x)
}


#' @importFrom insight export_table
#' @export
print.easycormatrix <- function(x, digits = 2, stars = TRUE, ...) {
  formatted_table <- format(x, digits = digits, stars = stars)

  table_caption <- NULL
  if (!is.null(attributes(x)$method)) {
    table_caption <- c(paste0("# Correlation Matrix (", unique(attributes(x)$method), "-method)"), "blue")
  }

  footer <- attributes(x)$p_adjust
  if (!is.null(footer)) {
    footer <- paste0("\np-value adjustment method: ", parameters::format_p_adjust(footer))
    if (!is.null(attributes(x)$n)) {
      footer <- list(footer, paste0("\nObservations: ", unique(attributes(x)$n)))
    }
  }

  formatted_table$Method <- NULL
  formatted_table$n_Obs <- NULL

  cat(insight::export_table(formatted_table, format = "text", caption = table_caption, footer = footer))
  invisible(x)
}
