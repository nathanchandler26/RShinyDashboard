library(tidyverse)
library(shiny)
library(shinythemes)
library(shinydashboard)
library(plotly)
library(bslib)
library(shinycssloaders)
library(data.table)
library(bslib)
library(feather)
library(DT)
library(shinyWidgets)


# load('data/unique_cpc_group.Rdata')
load("data/unique_cpc_group.Rdata")
choices <- unique_cpc_group
# assignee <- read_feather('data/g_assignee_disambiguated_2012_2021.feather')
# location <- read_feather('data/g_location_disambiguated_2012_2021.feather')
# patent <- read_feather('data/g_patent_2012_2021.feather')
# cpc <- fread('data/g_cpc_current_2012_2021.csv')
# cpc$patent_id <- as.character(cpc$patent_id)



# Work together in class: 
# Design a UI that has the following
# A landing page and two analysis pages (competition and trends pages)
# Each analysis page needs a place for inputs and a place for outouts (charts)
# Inputs: 3 text inputs and 1 action button
# Outputs: blank for now, just give it a title



# patent <- fread('data/g_patent_2012_2021.csv')
# write_feather(patent, 'data/g_patent_2012_2021.feather')
# # disambiguated assignee (company name)
# assignee <- fread('data/g_assignee_disambiguated_2012_2021.csv')
# write_feather(assignee, 'data/g_assignee_disambiguated_2012_2021.feather')
# # term grant (expiration date)
# location <- fread('~/490R Files/g_location_disambiguated_2012_2021.csv')
# write_feather(location,'data/g_location_disambiguated_2012_2021.feather')