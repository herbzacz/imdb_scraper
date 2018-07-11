#Webscrape of IMDb
install.packages("pacman")
pacman::p_load(rvest,xml2, magrittr, stringr, xml2, dplyr) 

setwd("C:/Temp")

years <- 2012:2017
imdb_genres <- read_html("https://www.imdb.com/search/title") %>% html_nodes(".clause:nth-child(8) label") %>% html_text()
missing_genres <- c("Documentary", "Film-Noir", "Game-Show")
genres <- setdiff(imdb_genres, missing_genres)

for (year in years){
  for (genre in genres){
    url <- paste0("https://www.imdb.com/search/title?title_type=feature&release_date=",year,"-01-01,",year,"-12-31&genres=",genre,"&languages=en&count=250&view=simple")
    
   
    # WebScraping -------------------------------------------------------------
    
    #Look up html structure
    #a <- html_structure(imdb)
    
    #Scraping movie titles
    imdb <- read_html(url)
    
    title <- imdb %>% html_nodes(".lister-item-header a")
    
    titletext <- html_text(title)
    titletext <- data.frame(titletext)
    
    
    # Adding IMDb ID  ---------------------------------------------------------
    
    # Scraping URLs, which contain IMDb id
    imdbid <- imdb %>% html_nodes(css = ".lister-item-header a") %>% html_attr('href')
    
    #
    imdb_ids <- data.matrix(imdbid)
    imdb_ids <- imdb_ids %>% str_replace_all(pattern = "/title/", replacement="")
    imdb_ids <- substr(imdb_ids,1, nchar(imdb_ids)-16)
    imdb_ids <- data.frame(imdb_ids)
    
    data <- cbind(titletext,imdb_ids)
    colnames(data[1]) <- "imbd_id"

    # Scraping IMDb Ratings
    imdbrating <- imdb %>% html_nodes(css =".col-imdb-rating strong") 
    imdb_ratings <- bind_rows(lapply(xml_attrs(imdbrating), function(x) data.frame(as.list(x), stringsAsFactors=FALSE)))
    colnames(imdb_ratings) <- "imbd_rating"
    imdb_ratings <- data.frame(imdb_ratings)
    
    
    # Enriching data ----------------------------------------------------------
    
    year <- c(year)
    genre <- c(genre)
    data <- cbind(data, year,genre, imdb_ratings)
    
    
    # Exporting dataframe into CSV --------------------------------------------
    
    datacsv <- paste0(genre,"_",year) 
    datacsv <- write.csv(data, file=paste0(genre,year,".csv"), row.names = F, fileEncoding = "UTF-8")
 }}