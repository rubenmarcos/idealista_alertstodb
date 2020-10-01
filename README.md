# Idealista AlertsToDB
Script for extracting information from alerts sent to a Gmail address in order to create a data frame with relevant information. Applied to the real estate market and the site Idealista, but easy to customize for other purposes.

## - Main goal:
As real estate sites don't show all the historical evolution of their listings, a good to have for those researching the market could be having the chance of checking evolution of a single listing or listings for one area. In order to do that, we need to extract useful information and make it ready to store in an easy way to be queried and analysed in the future. Scraping a site is a common way to do that, but it's quite aggresive and not always accepted by partner sites.

This scripts allow us to extract that information not directly from the site, but from the alerts sent to our very own mailbox. No scraping techniques are used on it. The script detect the relevant e-mails, extract the text and subjects and give us some ground to use regular expressions to detect patterns in order to clean and extract the main data.

It's been initially tailored to be used on the Idealista.com site, but can be easily modified to be used for any other similar alert.

## - Potential uses:
The main goal for that is being able to have an historical tracking and creating a database for market behaviour on listings in a certain geographical area. Could be useful both for buyers, sellers and agents in order to have a data base for detecting market trends or finding potential opportunities in the market. Some potential uses could include:

- Knowing when has a listing been published for the first time.

- Knowing how many times has the price been modified and if a quick histoy of changes could point to someone who is in a hurry to sell.

- Finding trends on which is the favourite month to create a listing.

- (Combined with the favourites alert) Detect trends on how long takes a house to be sold after listing and how much has the price been modified since the first time it was listed.

## - Requirements:
- R
- Packages: gmailr, dplyr, stringr
- Connection with Gmail API

## - How does it work?:
- An e-mail alert on idealista.com site has to be configured with an account linked to the Gmail address where we want to receive our alerts.
- Proper filtering and labeling on Gmail have to be set for those alerts, so only relevant e-mails are assigned to that label. 
- Gmailr package requires connection to the Gmail API and an oAuth token that can be obtained from https://console.developers.google.com and has to be configured according the instructions of the gmailr package: https://rdrr.io/cran/gmailr/f/README.md
- Gmailr will extract all the ids for the e-mails labeled that way and will extract subject, text and snippet details.
- Regular expressions will be used to extract the desired data from the main strings and assing them to the right field on the data frame.
- The final data frame is stored on a .csv file on the Home working directory (Other destinations or ways of storing -BigQuery, Google Drive, MySQL...- can be easily defined too).
- Final user is supposed to update and add new records to this data base periodically -not a difficult task at all-. Scheduling for automation is also quite easy from RStudio Server defining a cronR scheduled task.
