library(tidyverse)
get_nyt_articles = function(year, month, day, api_key) {
  # sanity checks
  if(length(year) != 1 | length(month) != 1 | length(day) !=1 | length(api_key) != 1) 
    stop("input parameter must be of length 1!")
  # for year
  if(is.character(year)){
    if(!is.na(stringr::str_extract(year, "[^0-9]+")))
      stop("year must be an integer!")
  } else {
    if(as.integer(year) != as.numeric(year) | as.integer(year) <= 0)
      stop("year must be an positive integer!")
  }
  if(year %>% as.numeric() >= 10000)
    stop("year should be of smaller than 10000!")
  # for month
  if(is.character(month)){
    if(!is.na(stringr::str_extract(month, "[^0-9]+")))
      stop("month must be an integer!")
  } else {
    if(as.integer(month) != as.numeric(month))
      stop("month must be an integer!")
  }
  if(as.integer(month) <= 0 | as.integer(month) >= 13)
    stop("month must be within 1 to 12!")
  # for day
  if(is.character(day)){
    if(!is.na(stringr::str_extract(day, "[^0-9]+")))
      stop("day must be an integer!")
  } else {
    if(as.integer(day) != as.numeric(day) | as.integer(day) <= 0)
      stop("day must be an positive integer!")
  }
  if(as.integer(month) %in% c(1, 3, 5, 7, 8, 10, 12) & 
     as.integer(day) > 31)
    stop("day cannot be greater than 31!")
  if(as.integer(month) %in% c(4, 6, 9, 11) & as.integer(day) > 30)
    stop("day cannot be greater than 30!")
  if(as.integer(month) == 2) {
    if(lubridate::leap_year(as.integer(year))) {
      if(as.integer(day) > 29)
        stop("day cannot be greater than 29!")
    }
    else if(as.integer(day) > 28)
      stop("day cannot be greater than 28!")
  }
  # for api_key
  if(!is.character(api_key))
    stop("api key must be a string!")
  
  # handle year, month and day
  year = year %>% as.numeric() %>% as.character() %>% stringr::str_pad(4, side = "left", pad = "0")
  month = month %>% as.numeric() %>% as.character() %>% stringr::str_pad(2, side = "left", pad = "0")
  day = day %>% as.numeric() %>% as.character() %>% stringr::str_pad(2, side = "left", pad = "0")
  
  # compose URL
  base = "https://api.nytimes.com/svc/search/v2/articlesearch.json?"
  begin_date = paste0(year, month, day)
  end_date = begin_date
  url = paste0(
    base,
    "begin_date=",
    begin_date,
    "&end_date=",
    end_date,
    "&fq=print_page:(%221%22)%20AND%20print_section:(%22A%22)",
    "%20AND%20document_type:(%22article%22)",
    "&api-key=",
    api_key
  )
  
  # extract news 
  t1 = Sys.time()
  tryCatch(
    {dat = jsonlite::read_json(url)},
    warning = function(w) { stop("The API key you entered is invalid!", call. = FALSE) }
  )
  
  count = 1
  total = dat$response$meta$hits
  page = 0
  news <- list()
  repeat{
    news <- c(news, dat$response$docs)
    page = page + 1
    if(page >= ceiling(total / 10)){
      break
    } 
    else{
      url.temp = paste0(url, "&page=", page)
      t2 = Sys.time()
      if(t2 - t1 <= 60 & count == 10) {
        Sys.sleep(60 - (t2 - t1))
        count = 0
        t1 = Sys.time()
      }
      dat = jsonlite::read_json(url.temp)
      count = count + 1
    }
  }
  
  # clean data
  news %>%
    tibble(news = .) %>%
    unnest_wider(news)
}