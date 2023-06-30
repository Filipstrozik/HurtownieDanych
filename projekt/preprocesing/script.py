import csv
import re
from datetime import datetime
# funkcja konwersji DMS na DD
def DMS2DD(coord):
    if coord == '':
        return ''
    else:
        direction = coord[-1]
        seconds = float(coord[-3:-1]) if coord[-3:-1].isdigit() else 0.0
        minutes = float(coord[-5:-3]) if coord[-5:-3].isdigit() else 0.0
        degrees = float(coord[:-5]) if coord[:-5].isdigit() else 0.0
        dd = degrees + minutes/60 + seconds/3600
        if direction in ('S', 'W'):
            dd *= -1
        return round(dd,6)


# wczytanie pliku csv
with open('AviationData.csv', newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    data = []
    for row in reader:
        # konwersja Latitude
        if re.search('[NS]', row['Latitude']):
            if row['Latitude'] != '':
                row['Latitude'] = DMS2DD(row['Latitude'])
            else:
                row['Latitude'] = None
        else:
            if row['Latitude'] != '':
                row['Latitude'] = float(row['Latitude'])
            else:
                row['Latitude'] = None
        
        # konwersja Longitude
        if re.search('[EW]', row['Longitude']):
            if row['Longitude'] != '':
                row['Longitude'] = DMS2DD(row['Longitude'])
            else:
                row['Longitude'] = None
        else:
            if row['Longitude'] != '':
                row['Longitude'] = float(row['Longitude'])
            else:
                row['Longitude'] = None
        
        # konwersja Publication_Date
        if row['Publication.Date'] != '':
            row['Publication.Date'] = datetime.strptime(row['Publication.Date'], '%d-%m-%Y').strftime('%Y-%m-%d')
        else:
            row['Publication.Date'] = None
        
        data.append(row)

# zapisanie zmodyfikowanego pliku csv
with open('AciationData_modified.csv', 'w', newline='') as csvfile:
    fieldnames = data[0].keys()
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    for row in data:
        writer.writerow(row)
