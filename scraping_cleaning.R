require(httr)
require(jsonlite)
require(readr)
require(stringr)

options(stringsAsFactors = FALSE)

access_token = read_file('token.txt')

dishes_raw <- httr::GET(paste("http://api.menus.nypl.org/dishes?token=", access_token, sep = ""))

dishes <- fromJSON(rawToChar(dishes_raw$content))$dishes

next_url <- str_extract(gsub("next.*", "", dishes_raw$headers$link), pattern = "(?<=<).*(?=>)")

while(str_detect(dishes_raw$headers$link[1], 'next')) {
  dishes_raw <- httr::GET(next_url)
  
  dishes_page <- fromJSON(rawToChar(dishes_raw$content))$dishes
  
  next_url <- str_extract(gsub(".*prev","",gsub("next.*", "", dishes_raw$headers$link)), pattern = "(?<=<).*(?=>)")
  dishes <- rbind(dishes, dishes_page)
  print(next_url)
  
}

write.csv(dishes, "data/nypl_dishes.csv")

