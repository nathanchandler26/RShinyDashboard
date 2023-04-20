library(tidyverse)
library(data.table)
library(shiny)
library(shinythemes)
library(shinydashboard)
library(plotly)
library(bslib)
library(feather)
library(DT)

assignee <- read_feather('data/g_assignee_disambiguated_2012_2021.feather')
location <- read_feather('data/g_location_disambiguated_2012_2021.feather')
patent <- read_feather('data/g_patent_2012_2021.feather')
cpc <- fread('data/g_cpc_current_2012_2021.csv')
cpc$patent_id <- as.character(cpc$patent_id)

load("data/unique_group.Rdata")
cpc_class <- substr(unique_group, 1, 3)
cpc_class<-unique(cpc_class)
choices <- sapply(unique_group, sub, pattern = "/.*", replacement = "")

subclass <- unique_group