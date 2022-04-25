require(httr)
require(jsonlite)
require(readr)
require(stringr)

options(stringsAsFactors = FALSE)

access_token = read_file('token.txt')

# read and parse first page 
dishes_raw <- httr::GET(paste("http://api.menus.nypl.org/dishes?token=", access_token, sep = ""))
dishes <- fromJSON(rawToChar(dishes_raw$content))$dishes

# extract the next url from the link header
next_url <- str_extract(gsub("next.*", "", dishes_raw$headers$link), pattern = "(?<=<).*(?=>)")

# while there is a next page
while(str_detect(dishes_raw$headers$link[1], 'next')) {
  
  # read and parse page
  dishes_raw <- httr::GET(next_url)
  dishes_page <- fromJSON(rawToChar(dishes_raw$content))$dishes
  
  # extract the next url from the link header
  next_url <- str_extract(gsub(".*prev","",gsub("next.*", "", dishes_raw$headers$link)), pattern = "(?<=<).*(?=>)")
  dishes <- rbind(dishes, dishes_page)
  print(next_url)
  
}

# write file 
write.csv(dishes, "data/nypl_dishes.csv")

