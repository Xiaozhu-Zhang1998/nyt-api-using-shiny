library(shiny)
library(DT)
library(spsComps)

source("get_nyt_articles.R")

shinyApp(
  ui = fluidPage(
    titlePanel("NYTimes API: View front page stories"),
    sidebarLayout(
      sidebarPanel(
        # set day
        dateInput("dateid", "Please select the date:",
                  min = "1800-01-01", max = "9999-12-31",),
        
        # API key
        textInput("api_key", "Please input your API key:", 
                  value = "bp6GNSsCWGZA7FjjuraWussAZXi6Nco4"),
        br(),
        
        # action button
        actionButton("check", "View the headlines!"),
        hr(),
        
        # disclaimer
        uiOutput("disclaimer")
      ),
      
      mainPanel(
        dataTableOutput("newstable"),
      )
    )
  ),
  server = function(input, output, session) {
    
    # function for action button
    shinyInput <- function(FUN, len, id, ...) {
      inputs <- character(len)
      for (i in seq_len(len)) {
        inputs[i] <- as.character(FUN(paste0(id, i), ...))
      }
      inputs
    }
    
    
    # retrieve API data
    news = eventReactive(input$check, {
      validate(need(length(input$dateid) != 0, "The date is not complete."))
      year = stringr::str_split(input$dateid, "-")[[1]][1]
      month = stringr::str_split(input$dateid, "-")[[1]][2]
      day = stringr::str_split(input$dateid, "-")[[1]][3]
      shinyCatch({
        get_nyt_articles(year, month, day, input$api_key)
      }, position = "top-center", blocking_level = "error", prefix = "User's")
      
    })
    
    
    # generate news table
    output$newstable = renderDataTable({
      validate(need(nrow(news()) != 0, "No records obtained from API."))
      tibble(
        `News Desk` = news() %>% pull(news_desk),
        Headline = news()$headline %>% tibble(hd = .) %>% unnest_wider(hd) %>% pull(print_headline),
        Read = shinyInput(actionButton, nrow(news()),
                          'button_',
                          label = "Read",
                          onclick = paste0('Shiny.setInputValue(\"select_button\", this.id, {priority: \"event\"})')
        )
      )
    }, escape = FALSE)
    
    
    # specify the selected row
    selected_row = eventReactive(input$select_button, {
      rowid = as.numeric(strsplit(input$select_button, "_")[[1]][2])
      selected_row = news()[rowid, ]
    })
    
    
    # pop up modal dialog
    observeEvent(input$select_button, {
      showModal(modalDialog(
        title = "Details",
        uiOutput("info"),
        easyClose = TRUE
      ))
    })
    
    
    # generate info inside the modal dialog
    output$info = renderUI({
      l0 = uiOutput("newsimg")
      l1 = h4("Title")
      l2 = ifelse(
        selected_row()$headline %>% tibble(hd = .) %>% unnest_wider(hd) %>% nrow() != 0,
        selected_row()$headline %>% tibble(hd = .) %>% unnest_wider(hd) %>% pull(main),
        "Unknown"
      )
      l3 = hr()
      l4 = h4("Byline")
      l5 = ifelse(
        selected_row()$byline %>% tibble(bl = .) %>% unnest_wider(bl) %>% nrow() != 0,
        selected_row()$byline %>% tibble(bl = .) %>% unnest_wider(bl) %>% pull(original),
        "Unknown"
      )
      l6 = hr()
      l7 = h4("Abstact")
      l8 = ifelse(
        !is.na(selected_row() %>% pull(abstract)),
        selected_row() %>% pull(abstract),
        "Unknown"
      )
      l9 = hr()
      l10 = h4("First Paragraph")
      l11 = ifelse(
        !is.na(selected_row() %>% pull(lead_paragraph)),
        selected_row() %>% pull(lead_paragraph),
        "Unknown"
      )
      l12 = hr()
      l13 = h4("URL")
      if(!is.na(selected_row() %>% pull(web_url)))
        l14 = tags$a(selected_row() %>% pull(web_url), href = selected_row() %>% pull(web_url))
      else
        l14 = "Unknown"
      l15 = hr()
      l16 = p(paste0(
        "This article contains ", 
        ifelse(!is.na(selected_row() %>% pull(word_count)), 
               selected_row() %>% pull(word_count), "Unknown"),
        " words. News source: ",
        ifelse(!is.na(selected_row() %>% pull(source)), 
               selected_row() %>% pull(source), "Unknown"),
        "."
      ))
      return(list(l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, 
                  l11, l12, l13, l14, l15, l16))
    })
    
    
    # generate img
    output$newsimg = renderUI({
      if(!("multimedia" %in% colnames(selected_row())) || is.null(selected_row()$multimedia[[1]]))
        return(NULL)
      media = selected_row()$multimedia %>% 
        tibble(media = .) %>% 
        unnest_longer(media) %>% 
        unnest_wider(media)
      type = media$type[1]
      imgurl = paste0("https://www.nytimes.com/", media$url[1])
      
      if(type == "image") {
        if(media$height[1] < media$width[1]) {
          return(list(tags$img(src = imgurl, width = 300), hr()))
        } else {
          return(list(tags$img(src = imgurl, height = 300), hr()))
        }
      }
      else {
        return(NULL)
      }
    })
    
    
    # disclaimer
    output$disclaimer <- renderUI({
      a = tags$i("Disclaimer: ")
      b = p("The retrieving results are completely returned by the 'Article Search API' provided by the New York Times. Any incompleteness of data or mistakes regarding word count, news desk, etc. are due to the API rather than this Shiny App. ")
      c = p("In addition, please note that the publishing date of an article may be different from the date when the article is placed on the front page (due to information lag, time zone difference, scrutiny, etc.). Clarify: the date this Shiny App uses is the date when the article is placed on the front page.")
      return(list(a, b, c))
    })
    
  }
)
