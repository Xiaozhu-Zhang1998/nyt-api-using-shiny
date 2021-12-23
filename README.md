# New York Times API: Read Front Page Headlines

This is an Shiny App that takes advantage of the [NYTimes Article Search API](https://developer.nytimes.com/docs/articlesearch-product/1/overview) which retreives the New York Times headlines given the date. Among all the articles that can be fetched by this API, we only focus on the *front page articles* (i.e. `document_type` is "article", `print_page` is 1 and `print_section` is "A").

## API Key

To access this or any of the other API keys you will need to register with the NY Times [here](https://developer.nytimes.com/accounts/create). Once you have created and verified your account you can then create an App (using the menu under your email address) and enable access to the Article Search API. In creating this App you will be given an API key to authenticate yourself with when making API requests. You API key will be limited to at most 10 requests / minute and 4000 requests / day. **Note that the author has hard coded her API key as the default value for this field.**

## Details
| File                        | Description        |
| --------------------------- | ------------------ |
| nty-api-using-shiny.Rproj   | The R project file |
| get_nyt_articles.R          | The file that includes a core funtion `get_nyt_articles()` which retrieves article data from the NY Times Article Search API  |
| app.R                       | The Shiny App file |

## How to launch this app
### Option 1: Use the link
If you are only interested in the functionality of this Shiny App, please use the link [https://xzzhang1998.shinyapps.io/nyt-api-using-shiny/](https://xzzhang1998.shinyapps.io/nyt-api-using-shiny/) to play around.

### Option 2: Understand and Modify
If you are interested in the codes of this Shiny App, and would like to modify some features based on your own needs, please
- Review the Article Search API [documentation](https://developer.nytimes.com/docs/articlesearch-product/1/overview) and Lucene syntax [documentation](http://www.lucenetutorial.com/lucene-query-syntax.html) used for the filter query (`fq`) parameter. Note that the list of filter query fields in the documentation is not complete, as you can query most document entries in the responses (e.g. `print_page` and `print_section`) even if they are not explicitly listed.
- Fork, clone, and change.

## Acknowledgement
This is a project from the course [STA 523](https://sta523-fa21.github.io/) instructed by Colin Rundel at Duke University. 
