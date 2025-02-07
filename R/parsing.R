#' Porter Stemmer
#' 
#' The Porter stemming algorithm (or ‘Porter stemmer’) is a process 
#' for removing the commoner morphological and inflexional endings 
#' from words in English. Its main use is as part of a term normalisation 
#' process that is usually done when setting up Information Retrieval systems.
#' 
#' @param stemmer A porter stemmer as returned by \code{\link{porter_stemmer}}.
#' @param text Text to parse.
#' 
#' @examples
#' \dontrun{
#' # create model
#' stemmer <- porter_stemmer()
#'
#' # stem
#' stemmer$stem("survey")
#' # or convenience method
#' stem_porter(stemmer, "survey")
#' }
#' 
#' @name porter_stemmer
#' @export
porter_stemmer <- function() {
  model <- gensim$parsing$porter$PorterStemmer()
  model <- structure(model, class = c("porter_stemmer_model", class(model)))
  invisible(model)
}

#' @rdname porter_stemmer
#' @export
stem_porter <- function(stemmer, text) UseMethod("stem_porter")

#' @rdname porter_stemmer
#' @method stem_porter porter_stemmer_model
#' @export
stem_porter.porter_stemmer_model <- function(stemmer, text){
  assert_that(!missing(text), msg = "Missing `text`.")

  purrr::map(text, stemmer$stem) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' Remove stopwords
#' 
#' Remove stopwords from a character string.
#' 
#' @param s A Character string or data.frame.
#' @param text bare name of text column.
#' @param ... Any other options.
#' 
#' @name remove_stopwords
#' 
#' @export
remove_stopwords <- function(s, ...) UseMethod("remove_stopwords")

#' @rdname remove_stopwords
#' @method remove_stopwords character
#' @export
remove_stopwords.character <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$remove_stopwords) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname remove_stopwords
#' @method remove_stopwords list
#' @export
remove_stopwords.list <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$remove_stopwords) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname remove_stopwords
#' @method remove_stopwords data.frame
#' @export
remove_stopwords.data.frame <- function(s, text, ...){
  assert_that(!missing(text), msg = "Missing `text`")
  s %>% 
    dplyr::pull(!!dplyr::enquo(text)) %>% 
    purrr::map(gensim$parsing$preprocessing$remove_stopwords) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' Strip Short Words
#' 
#' Remove words less than a certain length.
#' 
#' @param s A Character string or data.frame.
#' @param text bare name of text column.
#' @param min_len Minimum word length.
#' @param ... Any other options.
#' 
#' @name strip_short
#' 
#' @export
strip_short <- function(s, min_len = 5, ...) UseMethod("strip_short")

#' @rdname strip_short
#' @method strip_short character
#' @export
strip_short.character <- function(s, min_len = 5, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_short, minsize = min_len) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_short
#' @method strip_short list
#' @export
strip_short.list <- function(s, min_len = 5, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_short, minsize = min_len) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_short
#' @method strip_short data.frame
#' @export
strip_short.data.frame <- function(s, min_len = 5, text, ...){
  assert_that(!missing(text), msg = "Missing `text`")
  s %>% 
    dplyr::pull(!!dplyr::enquo(text)) %>% 
    purrr::map(gensim$parsing$preprocessing$strip_short, minsize = min_len) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' Preprocess text
#' 
#' Remove stopwords from a character string.
#' 
#' @param s A Character string or data.frame.
#' @param text bare name of text column.
#' @param filters Filters to apply, see filter section.
#' @param to_lower Whether to convert to lowercase before processing.
#' @param ... Any other options.
#' 
#' @section Filters:
#' \itemize{
#'   \item{\code{strip_tags}}
#'   \item{\code{strip_punctuation}}
#'   \item{\code{strip_multiple_spaces}}
#'   \item{\code{strip_numeric}}
#'   \item{\code{remove_stopwords}}
#'   \item{\code{strip_short}}
#'   \item{\code{stem_text}}
#' }
#' 
#' @name preprocess
#' 
#' @export
preprocess <- function(s, ..., 
  filters = c("strip_tags", "strip_punctuation", "strip_multiple_spaces", "strip_numeric",
    "remove_stopwords", "strip_short", "stem_text"), to_lower = TRUE) UseMethod("preprocess")

#' @rdname preprocess
#' @method preprocess character
#' @export
preprocess.character <- function(s, ...,
  filters = c("strip_tags", "strip_punctuation", "strip_multiple_spaces", "strip_numeric",
    "remove_stopwords", "strip_short", "stem_text"), to_lower = TRUE){

  custom_filters <- .custom_filters(filters) 

  if(to_lower)
    s <- tolower(s)

  s %>% 
    purrr::map(gensim$parsing$preprocessing$preprocess_string, custom_filters) %>% 
    purrr::map(reticulate::py_to_r)
}

#' @rdname preprocess
#' @method preprocess list
#' @export
preprocess.list <- preprocess.character

#' @rdname preprocess
#' @method preprocess data.frame
#' @export
preprocess.data.frame <- function(s, text, ...,
  filters = c("strip_tags", "strip_punctuation", "strip_multiple_spaces", "strip_numeric",
    "remove_stopwords", "strip_short", "stem_text"), to_lower = TRUE){
  assert_that(!missing(text), msg = "Missing `text`")

  custom_filters <- .custom_filters(filters) 

  s <- s %>% 
    dplyr::pull(!!dplyr::enquo(text))
  
  if(to_lower)
    s <- tolower(s)

  s %>% 
    purrr::map(gensim$parsing$preprocessing$preprocess_string, custom_filters) %>% 
    purrr::map(reticulate::py_to_r)
}

#' Filter Rarely
#' 
#' Filter rarely appearing keywords from documents.
#' 
#' @param s A Character string or a list.
#' @param min_freq Minimum term frequency to keep terms in. 
#' 
#' @name filter_rare
#' 
#' @export
filter_rare <- function(s, min_freq = 1) UseMethod("filter_rare")

#' @rdname filter_rare
#' @method filter_rare character
#' @export
filter_rare.character <- function(s, min_freq = 1){
  assert_that(min_freq >= 0)

  # count
  tf <- tibble::tibble(
    word = unlist(s)
  ) %>% 
    dplyr::count(word) %>% 
    dplyr::filter(n > min_freq) %>% 
    dplyr::pull(word)

  # predicate
  .keep <- function(x){
    x %in% tf
  }

  # map over lists
  purrr::map(
    s,
    function(x){
      purrr::keep(x, .keep)
    }
  )
}

#' @rdname filter_rare
#' @method filter_rare list
#' @export
filter_rare.list <- filter_rare.character

.availabale_filters <- function(){
  tibble::tibble(
    args = c("strip_tags", "strip_punctuation", "strip_multiple_spaces", "strip_numeric",
      "remove_stopwords", "strip_short", "stem_text"),
    func = c(
      gensim$parsing$preprocessing$strip_tags,
      gensim$parsing$preprocessing$strip_punctuation,
      gensim$parsing$preprocessing$strip_multiple_whitespaces,
      gensim$parsing$preprocessing$strip_numeric,
      gensim$parsing$preprocessing$remove_stopwords,
      gensim$parsing$preprocessing$strip_short,
      gensim$parsing$preprocessing$stem_text
    )
  )
}

.custom_filters <- function(filters){
  .availabale_filters() %>% 
    dplyr::filter(args %in% filters) %>%
    dplyr::pull(func) %>% 
    as.list()
}

#' Split Alphanumerics
#' 
#' Split Alphanumerics from a character string.
#' 
#' @param s A Character string or data.frame.
#' @param text bare name of text column.
#' @param ... Any other options.
#' 
#' @name split_alphanum
#' 
#' @export
split_alphanum <- function(s, ...) UseMethod("split_alphanum")

#' @rdname split_alphanum
#' @method split_alphanum character
#' @export
split_alphanum.character <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$split_alphanum) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname split_alphanum
#' @method split_alphanum list
#' @export
split_alphanum.list <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$split_alphanum) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname split_alphanum
#' @method split_alphanum data.frame
#' @export
split_alphanum.data.frame <- function(s, text, ...){
  assert_that(!missing(text), msg = "Missing `text`")
  s %>% 
    dplyr::pull(!!dplyr::enquo(text)) %>% 
    purrr::map(gensim$parsing$preprocessing$split_alphanum) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' Stem
#' 
#' Transform into lowercase and stem a character string.
#' 
#' @param s A Character string or data.frame.
#' @param text bare name of text column.
#' @param ... Any other options.
#' 
#' @name stem_text
#' 
#' @export
stem_text <- function(s, ...) UseMethod("stem_text")

#' @rdname stem_text
#' @method stem_text character
#' @export
stem_text.character <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$stem_text) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname stem_text
#' @method stem_text list
#' @export
stem_text.list <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$stem_text) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname stem_text
#' @method stem_text data.frame
#' @export
stem_text.data.frame <- function(s, text, ...){
  assert_that(!missing(text), msg = "Missing `text`")
  s %>% 
    dplyr::pull(!!dplyr::enquo(text)) %>% 
    purrr::map(gensim$parsing$preprocessing$stem_text) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' Strip Punctuation
#' 
#' Replace punctuation characters with spaces.
#' 
#' @param s A Character string or data.frame.
#' @param text bare name of text column.
#' @param ... Any other options.
#' 
#' @name strip_punctuation
#' 
#' @export
strip_punctuation <- function(s, ...) UseMethod("strip_punctuation")

#' @rdname strip_punctuation
#' @method strip_punctuation character
#' @export
strip_punctuation.character <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_punctuation) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_punctuation
#' @method strip_punctuation list
#' @export
strip_punctuation.list <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_punctuation) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_punctuation
#' @method strip_punctuation data.frame
#' @export
strip_punctuation.data.frame <- function(s, text, ...){
  assert_that(!missing(text), msg = "Missing `text`")
  s %>% 
    dplyr::pull(!!dplyr::enquo(text)) %>% 
    purrr::map(gensim$parsing$preprocessing$strip_punctuation) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' Strip Tags
#' 
#' Remove tags from character string.
#' 
#' @param s A Character string or data.frame.
#' @param text bare name of text column.
#' @param ... Any other options.
#' 
#' @name strip_tags
#' 
#' @export
strip_tags <- function(s, ...) UseMethod("strip_tags")

#' @rdname strip_tags
#' @method strip_tags character
#' @export
strip_tags.character <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_tags) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_tags
#' @method strip_tags list
#' @export
strip_tags.list <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_tags) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_tags
#' @method strip_tags data.frame
#' @export
strip_tags.data.frame <- function(s, text, ...){
  assert_that(!missing(text), msg = "Missing `text`")
  s %>% 
    dplyr::pull(!!dplyr::enquo(text)) %>% 
    purrr::map(gensim$parsing$preprocessing$strip_tags) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' Strip Numerics
#' 
#' Remove digits from character string.
#' 
#' @param s A Character string or data.frame.
#' @param text bare name of text column.
#' @param ... Any other options.
#' 
#' @name strip_numeric
#' 
#' @export
strip_numeric <- function(s, ...) UseMethod("strip_numeric")

#' @rdname strip_numeric
#' @method strip_numeric character
#' @export
strip_numeric.character <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_numeric) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_numeric
#' @method strip_numeric list
#' @export
strip_numeric.list <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_numeric) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_numeric
#' @method strip_numeric data.frame
#' @export
strip_numeric.data.frame <- function(s, text, ...){
  assert_that(!missing(text), msg = "Missing `text`")
  s %>% 
    dplyr::pull(!!dplyr::enquo(text)) %>% 
    purrr::map(gensim$parsing$preprocessing$strip_numeric) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' Strip Non Alphanumerics
#' 
#' Remove non-alphabetic characters from string.
#' 
#' @param s A Character string or data.frame.
#' @param text bare name of text column.
#' @param ... Any other options.
#' 
#' @name strip_non_alphanum
#' 
#' @export
strip_non_alphanum <- function(s, ...) UseMethod("strip_non_alphanum")

#' @rdname strip_non_alphanum
#' @method strip_non_alphanum character
#' @export
strip_non_alphanum.character <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_non_alphanum) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_non_alphanum
#' @method strip_non_alphanum list
#' @export
strip_non_alphanum.list <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_non_alphanum) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_non_alphanum
#' @method strip_non_alphanum data.frame
#' @export
strip_non_alphanum.data.frame <- function(s, text, ...){
  assert_that(!missing(text), msg = "Missing `text`")
  s %>% 
    dplyr::pull(!!dplyr::enquo(text)) %>% 
    purrr::map(gensim$parsing$preprocessing$strip_non_alphanum) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' Strip Multiple space
#' 
#' Remove repeating whitespace characters (spaces, tabs, line breaks) from s and turns tabs & line breaks into spaces.
#' 
#' @param s A Character string or data.frame.
#' @param text bare name of text column.
#' @param ... Any other options.
#' 
#' @name strip_multiple_spaces
#' 
#' @export
strip_multiple_spaces <- function(s, ...) UseMethod("strip_multiple_spaces")

#' @rdname strip_multiple_spaces
#' @method strip_multiple_spaces character
#' @export
strip_multiple_spaces.character <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_multiple_whitespaces) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_multiple_spaces
#' @method strip_multiple_spaces list
#' @export
strip_multiple_spaces.list <- function(s, ...){
  s %>% 
    purrr::map(gensim$parsing$preprocessing$strip_multiple_whitespaces) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}

#' @rdname strip_multiple_spaces
#' @method strip_multiple_spaces data.frame
#' @export
strip_multiple_spaces.data.frame <- function(s, text, ...){
  assert_that(!missing(text), msg = "Missing `text`")
  s %>% 
    dplyr::pull(!!dplyr::enquo(text)) %>% 
    purrr::map(gensim$parsing$preprocessing$strip_multiple_whitespaces) %>% 
    purrr::map(reticulate::py_to_r) %>% 
    unlist()
}