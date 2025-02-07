% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/parsing.R
\name{remove_stopwords}
\alias{remove_stopwords}
\alias{remove_stopwords.character}
\alias{remove_stopwords.list}
\alias{remove_stopwords.data.frame}
\title{Remove stopwords}
\usage{
remove_stopwords(s, ...)

\method{remove_stopwords}{character}(s, ...)

\method{remove_stopwords}{list}(s, ...)

\method{remove_stopwords}{data.frame}(s, text, ...)
}
\arguments{
\item{s}{A Character string or data.frame.}

\item{...}{Any other options.}

\item{text}{bare name of text column.}
}
\description{
Remove stopwords from a character string.
}
