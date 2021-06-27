# URECA-Research
## Background
This research has two objectives
1. To replicate the results of the reference paper "Inside insider trading: Patterns & discoveries from a large scale exploratory analysis" by A. Tamersoy et al. on 150 random S&P 500 companies from 1993 to December 2020. Insider trading data will be analysed from temporal and network-centric aspects. 
2. Produce a data pipeline to automate the scraping and cleaning of Form 4 data as much as possible. Large-scale analysis of Form 4 data only began in 2012 by the reference paper.

## Setup
After cloning this repository,  
`pip install -r setup/requirements.txt`  

Alternatively, for Anaconda users,  
`conda env create --file setup/conda_env.txt`

## Research Code
Two methods
1. Run 'Research.ipynb' file
2. First run 'Research_Insider_Trading (Actual).ipynb' to process all the raw data, and then run 'Exploratory_Analysis.ipynb' to clean the data and carry out the actual exploratory analysis

## Folder Organisation
- Metadata: stores the ticker data
- Database: stores the data obtained from web scraping or cleaned data
- Results: stores the graphs obtained from Exploratory Analysis section
- DataProcessingPipelining: stores the shell code to scrape Form 4 data. Only Bash scripts are stored
