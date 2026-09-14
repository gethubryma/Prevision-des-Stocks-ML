import wbdata

inflation = wbdata.get_dataframe(
    {"FP.CPI.TOTL.ZG": "inflation"}
)

inflation.head()