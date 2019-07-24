
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/news-r/gensimr.svg?branch=master)](https://travis-ci.org/news-r/gensimr)
<!-- badges: end -->

# gensimr

Brings [gensim](https://radimrehurek.com/gensim) to R.

## Installation

Install the package.

``` r
install.packages("gensimr")
```

Install the python dependency.

``` r
gensimr::install_gensim()
```

Ideally one should use a virtual environment and pass it to
`install_gensim`.

``` r
system2("python3", "-m venv ./env") # create environment
reticulate::use_virtualenv("./env") # force reticulate to use env
gensimr::install_gensim("./env") # install gensim in environment
```

## Example

Use data from another [news-r](https://news-r.org) package.

Firdt we preprocess the corpus.

``` r
library(gensimr)

docs <- preprocess(corpus)
#> → Preprocessing 9 documents
#> ← 9 documents after perprocessing
```

Once preprocessed we can build a dictionary.

``` r
dictionary <- corpora_dictionary(docs)
```

A dictionary essentially assigns an integer to each term.

``` r
reticulate::py_to_r(dictionary$token2id)
#> $computer
#> [1] 0
#> 
#> $human
#> [1] 1
#> 
#> $interface
#> [1] 2
#> 
#> $response
#> [1] 3
#> 
#> $survey
#> [1] 4
#> 
#> $system
#> [1] 5
#> 
#> $time
#> [1] 6
#> 
#> $user
#> [1] 7
#> 
#> $eps
#> [1] 8
#> 
#> $trees
#> [1] 9
#> 
#> $graph
#> [1] 10
#> 
#> $minors
#> [1] 11
```

`doc2bow` simply maps the \`method of the same name to every documents;
it counts the number of occurrences of each distinct word, converts the
word to its integer word id and returns the result as a sparse vector.

``` r
# native method
dictionary$doc2bow(docs[[1]])
#> [(0, 1), (1, 1), (2, 1)]

# apply to all documents
corpus <- doc2bow(dictionary, docs)
```

Then convert to matrix market format and serialise, the function returns
the path to the file.

``` r
(mm_corpus <- mmcorpus_serialize(corpus))
```

Then initialise a model.

``` r
model <- model_tfidf(mm_corpus)
```

``` r
corpus_transformed <- corpora_transform(model, corpus)
```

``` r
lsi <- model_lsi(corpus_transformed, dictionary)
lsi$print_topics()

wrapped_corpus <- wrap_corpus(lsi, corpus_transformed)
wrapped_corpus_docs <- wrap_corpus_docs(wrapped_corpus)
```
