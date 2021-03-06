% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_CCF_clusters.R
\name{plot_CCF_clusters}
\alias{plot_CCF_clusters}
\title{Plot CCF clusters data (tile).}
\usage{
plot_CCF_clusters(x, ...)
}
\arguments{
\item{x}{A \code{ctree} tree.}

\item{...}{Extra parameters, not used.}
}
\value{
A \code{ggplot} plot.
}
\description{
This function creates a \code{ggplot}-style
heatmap of the input CCF cluster of each clone in the data.
The heatmap is annotated for the drivers status of each
clone (with/ without driver). The CCF values are used to
colour the heatmap (`NA` values are in light gray).
}
\examples{
data(ctree_input)

x = ctrees(
ctree_input$CCF_clusters, 
ctree_input$drivers,
ctree_input$samples,
ctree_input$patient,
ctree_input$sspace.cutoff,
ctree_input$n.sampling,
ctree_input$store.max
)

plot_CCF_clusters(x[[1]])
}
