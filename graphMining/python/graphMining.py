import pandas as pd

from ggplot import *
from datetime import datetime

workingDirectory = "/home/owen/Dropbox/graphMining/"

df = pd.DataFrame.from_csv(path=workingDirectory + "trafficData2.tsv", sep = '\t', header = 0, index_col = False)
timestamp = datetime.strptime(df.timestamp, '%Y-%m-%d %X')

p = ggplot(aes(x = 'timestamp'), data = df)
p + geom_histogram(binwidth = 30)
