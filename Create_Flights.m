clear all
AvgVel=1000; %km/hr

startRow=2;
endRow=67664;

[AirlineID,SourceAirportID,DestinationAirportID,PlaneID]=importfileRouteInfo('Data Set - Vuelos - Completo.xlsx','DM_Ruta',startRow,endRow);
for k=1:numel(AirlineID)
    AirlineID_array(k)=str2double(AirlineID{k});
    PlaneID_array(k)=str2double(PlaneID{k});
end
AirlineID=AirlineID_array';
PlaneID=PlaneID_array';
clear AirlineID_array PlaneID_array

startRow=2;
endRow=10669;

[AirportID,Latitude,Longitude,TimeZone]=importfileAirportInfo('Data Set - Vuelos.xlsx','Airports',startRow,endRow);
for k=1:numel(AirportID)
    AirportID_array(k)=str2double(AirportID{k});
end

AirportID=AirportID_array';
clear AirportID_array

startRow=2;
endRow=175;

[Plane_ID,Capacity]=importfilePlaneInfo('Data Set - Vuelos - Completo - Prueba.xlsx','DM_Avion',startRow,endRow);

%pick randomly different routes from Route pool
Number_Routes=length(SourceAirportID); %number of loaded routes
Routes=ceil(Number_Routes*rand(1,1000)); %generate 1000 routes from sample of loaded routes
% hist(Routes,500)
k=1;
SourceAirportLat=nan(size(Routes));
SourceAirportLong=nan(size(Routes));
DestinationAirportLat=nan(size(Routes));
DestinationAirportLong=nan(size(Routes));
d=nan(size(Routes));
%for each route, calculate times
for i=Routes
    Source=str2double(SourceAirportID{i});
    indx_SourceAirport=find(AirportID==Source);
    
    Destination=str2double(DestinationAirportID{i});
    indx_DestinationAirport=find(AirportID==Destination);
    
    
    
    try
        SourceAirportLat(k)=str2double(Latitude{indx_SourceAirport});
        SourceAirportLong(k)=str2double(Longitude{indx_SourceAirport});
        DestinationAirportLat(k)=str2double(Latitude{indx_DestinationAirport});
        DestinationAirportLong(k)=str2double(Longitude{indx_DestinationAirport});
        d(k) = getDistanceFromLatLonInKm(SourceAirportLat(k),SourceAirportLong(k),DestinationAirportLat(k),DestinationAirportLong(k));
        %Average time in minutes
        AvgTime=60*d(k)/AvgVel; %velocity in km/h, distance in km. Multiply by 60 to convert time to minutes
        %Flight time in minutes
        FlightTime(k)=AvgTime+30+30*rand(1,1); %mean 30 min, std dev 30 min of the calculated duration using the formula getDistanceFromLatLonInKm
        Plane(k)=PlaneID(i);
        Max_Capacity(k)=Capacity(find(PlaneID(i)==Plane_ID));
    catch
    end
    k=k+1;
end


%clean flights with no Source or Destination Airport ID
Invalid=isnan(d);
d(Invalid)=[];
FlightTime(Invalid)=[];
SourceAirportLat(Invalid)=[];
SourceAirportLong(Invalid)=[];
DestinationAirportLat(Invalid)=[];
DestinationAirportLong(Invalid)=[];
Routes(Invalid)=[];


%number of flights in those routes
N_flights=100000;
Flights=ceil(length(Routes)*rand(1,N_flights)); %generate N_flights from selected routes
% hist(Flights)
meses30=[4,6,9,11];
f=1;
for m=Flights
    % % Create date of departure and date of arrival
    % dates of flights from 2010 to 2018
    
    %Create date and time for stipulated departure
    Stipulated_Date_Departure(f).year=round(2010 + (2018-2010)*rand(1));
    Stipulated_Date_Departure(f).month=round(1 + (12-1)*rand(1));
    if ismember(Stipulated_Date_Departure(f).month,meses30)
        Stipulated_Date_Departure(f).day=round(1 + (30-1)*rand(1));
    elseif Stipulated_Date_Departure(f).month==2
        if leapyear(Stipulated_Date_Departure(f).year) % leap years have 29 days in february
            Stipulated_Date_Departure(f).day=round(1 + (29-1)*rand(1));
        else
            Stipulated_Date_Departure(f).day=round(1 + (28-1)*rand(1));
        end
    else Stipulated_Date_Departure(f).day=round(1 + (31-1)*rand(1));
    end
    Stipulated_Time_Departure(f).Hour=round(23*rand(1));
    Stipulated_Time_Departure(f).Min=round(59*rand(1));
    Stipulated_Date_Departure(f).complete=datetime(Stipulated_Date_Departure(f).year,Stipulated_Date_Departure(f).month,Stipulated_Date_Departure(f).day,Stipulated_Time_Departure(f).Hour,Stipulated_Time_Departure(f).Min,0);
    
    %Stipulated arrival: add Flight time to Stipulated_Time
    Stipulated_Date_Arrival(f).complete=Stipulated_Date_Departure(f).complete + minutes(FlightTime(m));
    Stipulated_Date_Arrival(f).year=year(Stipulated_Date_Arrival(f).complete);
    Stipulated_Date_Arrival(f).month=month(Stipulated_Date_Arrival(f).complete);
    Stipulated_Date_Arrival(f).day=day(Stipulated_Date_Arrival(f).complete);
    Stipulated_Time_Arrival(f).Hour=hour(Stipulated_Date_Arrival(f).complete);
    Stipulated_Time_Arrival(f).Min=minute(Stipulated_Date_Arrival(f).complete);
    
    %Real departure: add a random delay to Stipulated time of departure
    Delay(f)=120*rand(1);%average delay is zero with std dev 120 min
    Tiempo_Vuelo(f)=FlightTime(m);
    
    Real_Date_Departure(f).complete=Stipulated_Date_Departure(f).complete + minutes(Delay(f));
    Real_Date_Departure(f).year=year(Real_Date_Departure(f).complete);
    Real_Date_Departure(f).month=month(Real_Date_Departure(f).complete);
    Real_Date_Departure(f).day=day(Real_Date_Departure(f).complete);
    Real_Time_Departure(f).Hour=hour(Real_Date_Departure(f).complete);
    Real_Time_Departure(f).Min=minute(Real_Date_Departure(f).complete);
    
    % Real arrival: add Flight time to Real_Time
    Real_Date_Arrival(f).complete=Real_Date_Departure(f).complete + minutes(FlightTime(m));
    Real_Date_Arrival(f).year=year(Real_Date_Arrival(f).complete);
    Real_Date_Arrival(f).month=month(Real_Date_Arrival(f).complete);
    Real_Date_Arrival(f).day=day(Real_Date_Arrival(f).complete);
    Real_Time_Arrival(f).Hour=hour(Real_Date_Arrival(f).complete);
    Real_Time_Arrival(f).Min=minute(Real_Date_Arrival(f).complete);
    
    
    Maximum_Capacity(f)=Max_Capacity(m);
    Number_Passengers(f)=round(0.5+(1-0.5)*rand(1)*Max_Capacity(m)); %at least 50% ocupation
    %Convert real time of arrival to the time in the corresponding time
    %zone NO LO HACEMOS, consideramos todo hora local del origen del vuelo
    f=f+1;
end

% fileID = fopen('Flights.dat','w');
% formatSpec = '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n';
% formatSpec = '%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n';

% FT=['SK_Geografia_origen ' 'SK_Geografia_destino ' 'SK_Avion ' 'SK_Aerolinea ' 'SK_Ruta ',...
%     ...
%     'Fecha_Salida_Real_anio ' 'Fecha_Salida_Real_mes ' 'Fecha_Salida_Real_dia ' ...
%     'Fecha_Salida_Estipulada_anio ' 'Fecha_Salida_Estipulada_mes ' 'Fecha_Salida_Estipulada_dia ' ...
%     'Hora_Salida_Real_hora ' 'Hora_Salida_Real_min ' ...
%     'Hora_Salida_Estipulada_hora ' 'Hora_Salida_Estipulada_min ' ...
%     ...
%     'Fecha_Llegada_Real_anio ' 'Fecha_Llegada_Real_mes ' 'Fecha_Llegada_Real_dia ' ...
%     'Fecha_Llegada_Estipulada_anio ' 'Fecha_Llegada_Estipulada_mes ' 'Fecha_Llegada_Estipulada_dia ' ...
%     'Hora_Llegada_Real_hora ' 'Hora_Llegada_Real_min ' ...
%     'Hora_Llegada_Estipulada_hora ' 'Hora_Llegada_Estipulada_min '];

%Generate Flight Table
FT={'SK_Geografia_origen','SK_Geografia_destino','SK_Avion','SK_Aerolinea','SK_Ruta',...
    'Max_Capacidad_Avion','Nro_Pasajeros','Delay','Tiempo_Vuelo',...
    ...
    'Fecha_Salida_Real_anio','Fecha_Salida_Real_mes','Fecha_Salida_Real_dia',...
    'Fecha_Salida_Estipulada_anio','Fecha_Salida_Estipulada_mes','Fecha_Salida_Estipulada_dia',...
    'Hora_Salida_Real_hora','Hora_Salida_Real_min',...
    'Hora_Salida_Estipulada_hora','Hora_Salida_Estipulada_min',...
    ...
    'Fecha_Llegada_Real_anio','Fecha_Llegada_Real_mes','Fecha_Llegada_Real_dia',...
    'Fecha_Llegada_Estipulada_anio','Fecha_Llegada_Estipulada_mes','Fecha_Llegada_Estipulada_dia',...
    'Hora_Llegada_Real_hora','Hora_Llegada_Real_min',...
    'Hora_Llegada_Estipulada_hora','Hora_Llegada_Estipulada_min'};

% fprintf(fileID,formatSpec,FT);

xlswrite('Data Set - Vuelos - Completo - Prueba.xlsx',FT,'Fact_Table','A1');
FT2=nan(length(Flights),29);
for t=1:length(Flights)
%     FT2{t}={SourceAirportID{Flights(t)} DestinationAirportID{Flights(t)} PlaneID(Flights(t)) AirlineID(Flights(t)) Flights(t) ...
%         Maximum_Capacity Number_Passengers ...
%         ...
%         Real_Date_Departure(t).year Real_Date_Departure(t).month Real_Date_Departure(t).day ...
%         Stipulated_Date_Departure(t).year Stipulated_Date_Departure(t).month Stipulated_Date_Departure(t).day ...
%         Real_Time_Departure(t).Hour Real_Time_Departure(t).Min ...
%         Stipulated_Time_Departure(t).Hour Stipulated_Time_Departure(t).Min ...
%         ...
%         Real_Date_Arrival(t).year Real_Date_Arrival(t).month Real_Date_Arrival(t).day ...
%         Stipulated_Date_Arrival(t).year Stipulated_Date_Arrival(t).month Stipulated_Date_Arrival(t).day ...
%         Real_Time_Arrival(t).Hour Real_Time_Arrival(t).Min ...
%         Stipulated_Time_Arrival(t).Hour Stipulated_Time_Arrival(t).Min};

FT2(t,:)=[str2double(SourceAirportID{Routes(Flights(t))}) str2double(DestinationAirportID{Routes(Flights(t))}) PlaneID(Routes(Flights(t))) AirlineID(Routes(Flights(t))) Routes(Flights(t)) ...
        Maximum_Capacity(t) Number_Passengers(t) Delay(t) Tiempo_Vuelo(t) ...
        ...
        Real_Date_Departure(t).year Real_Date_Departure(t).month Real_Date_Departure(t).day ...
        Stipulated_Date_Departure(t).year Stipulated_Date_Departure(t).month Stipulated_Date_Departure(t).day ...
        Real_Time_Departure(t).Hour Real_Time_Departure(t).Min ...
        Stipulated_Time_Departure(t).Hour Stipulated_Time_Departure(t).Min ...
        ...
        Real_Date_Arrival(t).year Real_Date_Arrival(t).month Real_Date_Arrival(t).day ...
        Stipulated_Date_Arrival(t).year Stipulated_Date_Arrival(t).month Stipulated_Date_Arrival(t).day ...
        Real_Time_Arrival(t).Hour Real_Time_Arrival(t).Min ...
        Stipulated_Time_Arrival(t).Hour Stipulated_Time_Arrival(t).Min];

end

save('Flights_Table.mat')
% 
% T = cell2table(FT2,'VariableNames',FT);
% writetable(T,'tabledata.dat');

% FT={FT;FT2};

% 
% for t=1:length(Flights)
%     F=FT2{t};
%     t
% xlswrite('Data Set - Vuelos - Completo - Prueba.xlsx',F,'Fact_Table',['A' num2str(1+t)]);
% end