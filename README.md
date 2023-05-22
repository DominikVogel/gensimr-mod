# gensimrMOD

This is a fork of [gensimr](https://github.com/news-r/gensimr) v. 0.0.1 by John Coene.

I modified it to be able to load a Word2Vec model that was saved with `gensim`'s `save()` function. The modification is made in `R/models.R` line 522:

```r
  gensim$models$Word2Vec$load(file)
```

replaced with

```r
  gensim$models$KeyedVectors$load(file)
````

