library(tidyverse)
library(data.table)
library(shiny)
library(shinythemes)
library(shinydashboard)
library(plotly)
library(bslib)
library(feather)
library(DT)


# load('data/unique_cpc_group.Rdata')
load("data/unique_cpc_group.Rdata")
choices <- unique_cpc_group
assignee <- read_feather('data/g_assignee_disambiguated_2012_2021.feather')
location <- read_feather('data/g_location_disambiguated_2012_2021.feather')
patent <- read_feather('data/g_patent_2012_2021.feather')
cpc <- fread('data/g_cpc_current_2012_2021.csv')
cpc$patent_id <- as.character(cpc$patent_id)
