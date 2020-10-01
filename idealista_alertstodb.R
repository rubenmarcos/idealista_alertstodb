library(dplyr)
library(zoo)
library(gmailr)
library(stringr)


# NOTIFY - GMAIL --------------------------------------------------------------------

# Configuring was a pain in the ass, but once you have it done and get the tokens, you can use it for any other project.
# This script was intended to be automatised with cronr, so if you are using it on other circumstances, you may need to make some changes to the gm_auth options.


# Configure your app based on the JSON file obtained from Google APIs console.
# Create and OAuth 2.0 Client IDs on the Credentials section on https://console.developers.google.com/ and download the file.
# Gmail API has to be enabled. Find it on the Library section on the left menu.

gm_auth_configure(path = "my_file.json")

options(
  gargle_oauth_cache = ".my_cache",
  gargle_oauth_email = "my_mail@gmail.com"
)

gm_auth(email = "my_mail@gmail.com", cache = ".my_cache")

#Get the Label ID for your selected label using gmailr::labels()
my_threads <- gm_messages(label_ids = "Label_123456789000000000")

#New data frame with mail_id, including empty subject and date fields
my_threads <- data.frame(mail_id = unique(unlist(my_threads))) %>% mutate(subject = "",date = "")

#Validation check for ids
my_threads <- my_threads[nchar(my_threads$mail_id)==16,]


#Extracting subjects and dates
for (i in 1:nrow(my_threads)) {
  
 tryCatch({
  
  details <- data.frame(matrix(unlist(gm_message(my_threads$mail_id[i])[["payload"]][["headers"]]), ncol = 2, byrow = T)) 
  my_threads$subject[i] <- details$X2[details$X1== "Subject"]
  my_threads$date[i] <- details$X2[details$X1== "Date"]
  
 }, error=function(e){})
  
}

#From string to date format
my_threads$date <- as.Date(str_replace(tolower(gsub(" ","-",substring(my_threads$date,6,16))),"-\\d",".-2"), "%d-%b-%Y")


#Creating a new data frame for the full content
my_contents <- data.frame(mail_id = my_threads$mail_id)


#Extracting listing ID, and snippet (source for valuable information)
for (i in 1:nrow(my_contents)) {

  tryCatch({
    
    my_contents$mail_body[i] <- gmailr:::base64url_decode_to_char(gm_message(my_contents$mail_id[i])[["payload"]][["parts"]][[1]][["parts"]][[1]][["body"]][["data"]])
    my_contents$id_listing[i] <- sub("inmueble/","",str_extract(my_contents$mail_body[i], "inmueble\\/[0-9]+"))
    my_contents$snippet[i] <- gm_message(my_contents$mail_id[i])[["snippet"]]
  }, error=function(e){})
    
}

my_contents$mail_body <- NULL


#Joining both data frames
total <- my_threads %>% left_join(my_contents)


#Classifying kind of alert
total$event <- case_when(
  grepl("¡Nuevo",total$subject) ~ "Primera publicación",
  grepl("¡Bajada",total$subject) ~ "Bajada de precio",
  grepl("¡Subida",total$subject) ~ "Subida de precio")

#Extracting listing price
total$pricing <- as.numeric(sub("\\.","",str_extract(total$snippet, "[0-9]+\\.[0-9]+\\s")))

#Kind of listing based on listing data
total$type <- gsub("\\sen","",str_extract(total$snippet,"(.*?)\\sen"))

#Street location
total$location<- gsub("\\sen\\s||,\\sCollado\\sVillalba||(C||c)alle\\s","",str_extract(total$snippet,"\\sen\\s(.*?),\\sCollado\\sVillalba"))

#Neighbourhood
total$neighbourhood <- gsub("(,\\s[0-9]+,\\s)||(,\\s)||(,\\ss/n)","",str_extract(total$location,"(,.+)$?")) 
total$neighbourhood <- ifelse(is.na(total$neighbourhood),total$location,total$neighbourhood)


#Selecting relevant fields
total <- total %>% select(mail_id,date,id_listing,pricing,event,type,location,neighbourhood)


#Exporting to CSV
write.csv(total,"total_idealista.csv", row.names = FALSE)