# Essential imports and constants
import numpy as np
import pandas as pd
from sqlalchemy import create_engine
from pandas_datareader import data
import sqlite3 as sql
import matplotlib.pyplot as plt
import networkx as nx
import seaborn as sb; sb.set()
import requests, time, datetime, re, math, pickle
from multiprocessing import Pool

# if executed locally
TEST = 'Rationale/test.csv'
TICKER = 'Metadata/ticker.txt'
FORM4_LINK = 'Database/form4_data.csv'
FORM4_LINK_XML = 'Database/form4_data_xml.csv'
FORM4_LINK_HTM = 'Database/form4_data_htm.csv'
FORM4_LINK_TXT = 'Database/form4_data_txt.csv'
FORM4_DETAIL = 'Database/form4_detail.csv' 
FORM4_DETAIL_XML = 'Database/form4_detail_xml.csv'
FORM4_DETAIL_CLEAN = 'Database/form4_detail_clean.csv'
FORM4_DETAIL_HTM = 'Database/form4_detail_htm.csv'
FORM4_DETAIL_TXT = 'Database/form4_detail_txt.csv'
FORM4_TX = 'Database/form4_tx.csv'
FORM4_TX_XML = 'Database/form4_tx_xml.csv'
FORM4_TX_CLEAN = 'Database/form4_tx_clean.csv'
FORM4_TX_HTM = 'Database/form4_tx_htm.csv'
FORM4_TX_TXT = 'Database/form4_tx_txt.csv'
META_DJ30 = 'Metadata/ticker_dj30.txt' 
META_SP500 = 'Metadata/ticker_sp500.txt'
META_SP500_RAN = 'Metadata/ticker_sp500_ran.txt'
CODE_EXTRACT = 'DataProcessingPipelining/extract_file.sh'
CODE_EXTRACT_ONE = 'DataProcessingPipelining/extract_1_quarter.sh'
CODE_EXTRACT_NOPAR = 'DataProcessingPipelining/extract_noPAR.sh'

detail_data = pd.read_csv(FORM4_DETAIL_CLEAN, sep='|', parse_dates = ['Date'], index_col = 'Date')
tx_data = pd.read_csv(FORM4_TX_CLEAN, sep = '|', parse_dates = ['date'], index_col = 'date')

unique_company_list = detail_data.Company.unique()
company_insider_list = detail_data.groupby(['Company']).apply(lambda group: group.reporter_cik.unique().tolist())

def similarity(tx_set1, tx_set2):
    numerator = 0
    for i in range(len(tx_set1)):
        tx = tx_set1[i]
        for j in range(len(tx_set2)):
            tx2 = tx_set2[j]
            if abs((tx - tx2)).days == 0:
                numerator+=1
                break
    numerator = numerator*numerator
    similarity_index = numerator/len(tx_set1)/len(tx_set2)
    return similarity_index

def build_network(unique_company_list):
    print("start reading")
    hz = 5
    hm = 0.3
    G = nx.Graph()
    for counter, company in enumerate(unique_company_list):
        Gprime = nx.Graph()
        N, E = set(), set()
        unique_insider_list = company_insider_list[company]
        record = []
        for insider in unique_insider_list:
            unique_tx_data = detail_data.loc[(detail_data.reporter_cik == insider) | (detail_data.Company == company)].index.unique().sort_values().tolist()
            record.append([insider, unique_tx_data])
        tx_dates = pd.DataFrame(record, columns = ['insider', 'transaction_date'])

        for i in range(len(unique_insider_list) - 1):
            for j in range(i + 1, len(unique_insider_list)):
                insider1, insider2 = unique_insider_list[i], unique_insider_list[j]
    #             print(insider1, insider2)
                tx_set1, tx_set2 = tx_dates.loc[tx_dates.insider == insider1, 'transaction_date'].squeeze(), tx_dates.loc[tx_dates.insider == insider2, 'transaction_date'].squeeze()
                if len(tx_set1) >= hz and len(tx_set2) >= hz:
                    if similarity(tx_set1, tx_set2) >= hm:
                        N.update({insider1, insider2})
                        if insider1 < insider2:
                            E.add((insider1, insider2))
                        else:
                            E.add((insider2, insider1))
        print(counter, company, end = ' ')
        if len(N) > 1:
            Gprime.add_nodes_from(N)
            Gprime.add_edges_from(E)
        if Gprime.number_of_nodes() >= 1:
            G.add_node(Gprime, firm = company)
            print("included into graph", end = '')
        print('\n')
    return G

if __name__ == '__main__':
    graphs = None
    with Pool(15) as p:
        graphs = p.map(build_network, np.split(unique_company_list, 15))
        for i in range(len(graphs)):
            pickle.dump(graphs[i], open(r'Database/group' + i + r'.txt', 'w'))
    for i in range(len(graphs)):
            pickle.dump(graphs[i], open(r'Database/temp' + i + r'.txt', 'w'))