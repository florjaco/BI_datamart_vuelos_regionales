function d = getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2)
  R = 6371; % Radius of the earth in km
  dLat = deg2rad(lat2-lat1);  % deg2rad below
  dLon = deg2rad(lon2-lon1); 
  a =sin(dLat/2) * sin(dLat/2) + cos(deg2rad(lat1))*cos(deg2rad(lat2))*sin(dLon/2)*sin(dLon/2); 
  c = 2 * atan(sqrt(a)/sqrt(1-a)); 
  d = R * c; % Distance in km
end

