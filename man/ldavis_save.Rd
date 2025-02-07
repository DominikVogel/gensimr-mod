% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ldavis.R
\name{ldavis_save}
\alias{ldavis_save}
\alias{save_ldavis_html}
\alias{save_ldavis_json}
\title{Save Visualisation}
\usage{
save_ldavis_html(prepared_vis, file, ...)

save_ldavis_json(prepared_vis, file)
}
\arguments{
\item{prepared_vis}{Prepapred vis as returned by \code{\link{ldavis}}.}

\item{file}{A file name to save the html or json.}

\item{...}{Additional arguments from \href{https://pyldavis.readthedocs.io/en/latest/modules/API.html}{the official documentation}.}
}
\value{
Invisibly returns \code{file}.
}
\description{
Save Latent Dirichlet Allocation visualisation.
}
\examples{
docs <- prepare_documents(corpus)
dict <- corpora_dictionary(docs)
corpora <- doc2bow(dict, docs)

# lda model
model <- model_lda(
  corpus = corpora, 
  id2word = dict, 
  iterations = 50L, 
  num_topics = 2L
)

# visualise
vis <- prepare_ldavis(model, corpora, dict)
\dontrun{save_ldavis_html(vis, "lda.html")}

}
