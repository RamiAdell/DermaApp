import ast
from flask import Flask, request, jsonify
import requests
import pandas as pd
import json
import numpy as np
from sklearn.cluster import KMeans
import math
API_KEY = "AIzaSyCEiN_zfOmYirRa2c2gbhumce4S0kz7n9E"
app = Flask(__name__)

#days = 0
#activities = 0
#lng = ""
#lat = ""
#radius = 0
food = False
level = ""
priceLevel = 0
numOfChoosenCategouries = 0

arrTest = []

nameofcat = []

days_dict = {}
def decimal(NeededPerCateg , NumberOfCateg):
  tempo = NeededPerCateg//1
  tempo = NeededPerCateg - tempo
  tempo = tempo * NumberOfCateg
  return tempo

@app.route('/hello')
def hello():
   
   return jsonify("final")
@app.route('/your_endpoint', methods=['GET'])
def your_endpoint():
    
    df_tourist = pd.DataFrame()
   
    
    z =  pd.DataFrame()
    
    arrayOfClusters = []
    c=0
    j=0
    first_string = ""
    temp = []
    days = int(request.args.get('day'))
    activities = int(request.args.get('act'))
    lng = request.args.get('lng')
    lat = request.args.get('lat')
    priceLevel = int(request.args.get('price'))
    radius = int(request.args.get('rad'))
    your_array = request.args.getlist('your_array')
    first_string = ""
    food=False
    indexat = [
    ["", "natural_feature"],
    ["park", "tourist_attraction"],
    ["", "amusement_park"],
     ["museum", "museum"],
    ["mall", "shopping_mall"],
    ["historical", "tourist_attraction"],
    ["restaurant", "restaurant"]
    ]
    
    your_array = [int(item) for item in your_array]

    for index , i in enumerate(your_array):
        if i == 1 :
            temp.append(indexat[int(index)])
    
    numOfChoosenCategouries = len(temp)

    
    

    
    for item in temp:
        first_string, second_string = item[0], item[1]

        def build_url(first_string, second_string, page_token=None):
            url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={lat},{lng}&radius={radius}&key={API_KEY}"
            if first_string != "":
                url += f"&keyword={first_string}"
            url += f"&type={second_string}"
            if page_token:
                url += f"&pagetoken={page_token}"
            print(url)
            return url

        # Sending the initial request
        response = requests.get(build_url(first_string, second_string))
        data = response.json()

        # Checking for errors
        if data["status"] != "OK":
            print(f"Error: {data['status']}")
            

        # Extracting results from the initial response
        places = data["results"]

        # Checking if there are more results available
        while "next_page_token" in data:
            import time
            time.sleep(2)
            response = requests.get(build_url(first_string, second_string, data["next_page_token"]))
            data = response.json()
            places.extend(data["results"])

        df = pd.DataFrame(places)
        if first_string == "restaurant":
          food = True
          print(f"restaurant with length {len(df)}")
          df = weighted_score(df,first_string)
          df['type'] = first_string
          nameofcat.append(first_string)
          df = df[df['price_level'] == priceLevel]
          df['type'] = first_string
          



          columns_to_keep_df = ['name', 'rating', 'user_ratings_total', 'geometry','weighted_score','type','types','lat','lng','price_level' , 'vicinity']
          df = df.loc[:, columns_to_keep_df]
          df_tourist = pd.concat([df_tourist, df], ignore_index=True)
          df_tourist.reset_index(drop=True, inplace=True)
        else :
          print(f"tourist with length {len(df)}")
          if first_string == "":
            df['type'] = second_string
            nameofcat.append(second_string)
          else :
            df['type'] = first_string
            nameofcat.append(first_string)
          
          df = weighted_score(df,first_string)
          
          if(len(df) != 0):
            columns_to_keep_df = ['name', 'rating', 'user_ratings_total', 'geometry','weighted_score','type','types','lat','lng','price_level' , 'vicinity']
            df['price_level'] = ''
            df = df.loc[:, columns_to_keep_df]
            df_tourist = pd.concat([df_tourist, df], ignore_index=True)
          
          
          print(f"tourist shape{df_tourist.shape[0]}")

    result = df_tourist
    print(f"result shape{result.shape[0]}")
    X = result[['lat', 'lng']]
    kmeans = KMeans(n_clusters=4)
    kmeans.fit(X)
    cluster_labels = kmeans.labels_
    result['cluster'] = cluster_labels
    result = result.sort_values(by=['cluster','type'])
    cluster_counts = result['cluster'].value_counts()

    # count_cluster_1 = cluster_counts.get(0, 0)  # Get count for cluster 1, default to 0 if not found
    # count_cluster_2 = cluster_counts.get(1, 0)  # Get count for cluster 2, default to 0 if not found
    # count_cluster_3 = cluster_counts.get(2, 0)  # Get count for cluster 3, default to 0 if not found
    # count_cluster_4 = cluster_counts.get(3, 0)  # Get count for cluster 4, default to 0 if not found


    data = pd.DataFrame(columns=result.columns)
    food_df = result[result['type'] == 'restaurant']

    for i in range(4):
      clust = result[result['cluster'] == i ]
      clust['cluster'] = i
      for i in range(100):
        df2 = clust[clust['type'] == nameofcat[c]]
        if nameofcat[c] == "restaurant" :
          if c < numOfChoosenCategouries - 1:
            c = c + 1
          elif c == numOfChoosenCategouries - 1:
            c = 0
        df2 = clust[clust['type'] == nameofcat[c]]
        print(f"c ====================== {c} , nameofcat[c] =  {nameofcat[c]} number of cat = {numOfChoosenCategouries}")
        if len(df2) == 0 :
          if c < numOfChoosenCategouries - 1:
            c = c + 1
          elif c == numOfChoosenCategouries - 1:
            c = 0
          continue
        else :
          subset = df2.iloc[0:1]
          data = pd.concat([data, subset], axis=0)
          clust = clust.drop(subset.index)
          if c < numOfChoosenCategouries - 1:
            c = c + 1
          elif c == numOfChoosenCategouries - 1:
            c = 0

    tempo = pd.DataFrame(columns=data.columns)
    ToDelete = pd.DataFrame(columns=data.columns)
    final = pd.DataFrame(columns=data.columns)
    

    # data = data.reset_index(drop=True)
    for i in range(days):
      print(f"day {i}")
      #testSize ()
      max = getSize(data)
      tempo = data[data['cluster'] == j]
      
      if len(tempo) < activities :
        tempo = data[data['cluster'] == max]
        tempo = tempo.iloc[0:activities]
      else :
         tempo = tempo.iloc[0:activities]
           
           
      
      ToDelete = tempo
      # if food :
      #   print("adding food")
      #   terpo = food_df[food_df['cluster'] == j]
      #   testo = terpo[terpo['type'] == "restaurant"]
      #   testo2 = testo[testo['price_level'] == priceLevel]
      #   if len(testo2) != 0 :
      #     testo2 = testo2.iloc[0:1]
      #     print(testo2)
      #     food_df = food_df.drop(testo2.index)
      #     tempo = pd.concat([tempo, testo2], ignore_index=True)
      if food:
        #tempo.reset_index(drop=True, inplace=True)
        print('adding food')
        print('tempooooooooooooo')
        print(tempo)
        if len(tempo) > 0 :
           
          restLat = tempo.iloc[0]['lat']
          restLng = tempo.iloc[0]['lng']

          food_only= food_df[food_df['type'] == 'restaurant']

          sortedDistance = sort_locations_by_distance(food_only,restLat,restLng)

          filterPrice = sortedDistance[sortedDistance['price_level']==priceLevel]


          
          if len(filterPrice) > 0 :
            filterPrice = filterPrice.sort_values(by='distance')
            testo = filterPrice.iloc[0:1]
            testo.drop(columns='distance', inplace=True)

            print(f" before adding /////////////////// {tempo.shape[0]} ///////////////////")
            tempo = pd.concat([tempo, testo], ignore_index=True)
            print(f" after adding /////////////////// {tempo.shape[0]} ///////////////////")

            food_df = food_df.drop(testo.index)
          else :
            print("no restaurant wiht these specific here")


          print(f"latiitude  = {restLat}")
          print(f"longitude  = {restLng}")
        

      if j < 3:
        j += 1
      elif j == 3:
          j = 0
      tempo['day'] = i+1
      data = data.drop(ToDelete.index)
      final = pd.concat([final, tempo],axis=0)
      print(f"shape cluster{j} = {tempo.shape[0]}")
    columns_to_drop = ['lat','lng']
    #final.drop(columns=columns_to_drop, inplace=True)
    print(f"final {final.shape[0]}")
  
    

# Iterate over unique days
    for day in final['day'].unique():
        day_data = final[final['day'] == day][['name', 'rating', 'user_ratings_total', 'geometry', 'weighted_score', 'type', 'types', 'lat', 'lng', 'cluster','price_level', 'vicinity']]
        day_dict = day_data.to_dict(orient='records')
        days_dict[f'day {int(day)}'] = day_dict
    
    print(temp)
    return days_dict
  

def changeC():
    global c
    if c < numOfChoosenCategouries - 1:
        c = c + 1
    elif c == numOfChoosenCategouries - 1:
        c = 0
def getSize(data):
  test1 = data[data['cluster'] == 0]
  test2 = data[data['cluster'] == 1]
  test3 = data[data['cluster'] == 2]
  test4 = data[data['cluster'] == 3]
  arrTest.append(test1)
  arrTest.append(test2)
  arrTest.append(test3)
  arrTest.append(test4)
  max = 0
  maxIndex = 0

  for i , t in enumerate(arrTest):
    if t.shape[0] > max :
      max = t.shape[0]
      maxIndex = i
  return maxIndex
  
def changeJ():
    global j
    if j < 3:
        j += 1
    elif j == 3:
        j = 0
def get_good_for_children(place_id, api_key):
    details = get_place_details(place_id, api_key)
    if details is not None:
        return details.get('goodForChildren', 'NA'), details.get('editorialSummary', {}).get('text', 'NA')
    else:
        return 'NA', 'NA'
def get_place_details(place_id, api_key):
    url =  url = f"https://places.googleapis.com/v1/places/{place_id}?fields=goodForChildren,editorialSummary.text&key={API_KEY}"
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error retrieving details for place ID {place_id}: {e}")
        return None



def extract_lat_lng(geometry):
    """
    Extract latitude and longitude from the 'geometry' column
    """
    location = geometry['location']
    return location['lat'], location['lng']

def haversine(lat1, lon1, lat2, lon2):
    # Convert latitude and longitude values to floats
    lat1 = float(lat1)
    lon1 = float(lon1)
    lat2 = float(lat2)
    lon2 = float(lon2)
    
    # Convert decimal degrees to radians
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])

    # Haversine formula
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    r = 6371 # Radius of earth in kilometers. Use 3956 for miles
    return r * c

def sort_locations_by_distance(df, my_lat, my_lon):
    """
    Sort locations based on their distance from a given latitude and longitude
    """
    # Convert latitude and longitude values to floats
    my_lat = float(my_lat)
    my_lon = float(my_lon)
    
    df['distance'] = df.apply(lambda row: haversine(my_lat, my_lon, row['lat'], row['lng']), axis=1)
    sorted_df = df.sort_values(by='distance')
    return sorted_df


def weighted_score(df,first_string):
  if len(df) == 0 :
    return df
  else :
    df['weighted_score'] = df['rating'] * np.log1p(df['user_ratings_total'])
    df['lat'] = df['geometry'].apply(lambda x: str(x['location']['lat']))
    df['lng'] = df['geometry'].apply(lambda x: str(x['location']['lng']))
    # df['photo_reference'] = df['photos'].apply(extract_photo_ref)
    # df['width'] = df['photos'].apply(extract_width)
    # df['height'] = df['photos'].apply(extract_height)

    



    # if first_string != "restaurant":
    #   df = df[df['weighted_score'] >= 15]
    return df.sort_values(by='weighted_score', ascending=False)

    
def reset():
    numOfChoosenCategouries = len(temp)
    overallAct = days*activities
    neededPerCateg = 0
    neededPlaces = 0
    temp = []
    days = 0
    activities = 0
    lng = 0
    lat = 0
    radius = 0


if __name__ == '__main__':
    app.run(debug=True)
