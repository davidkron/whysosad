%%%-------------------------------------------------------------------
%%% @author David
%%% @copyright (C) 2014, <Pegasus>
%%% @doc
%%%
%%% @end
%%% Created : 24. okt 2014 19:04
%%%-------------------------------------------------------------------
-module(worldmap).
-author("David").
-export([get_country_from_geolocation/1]).

get_country_from_geolocation({Latitude,Longitude}) ->
  %Todo, put in database or keep in ram someway(otp server f.ex)
  Lines = easyio:readlines("countries.csv"),
  BoundingBoxes = [string:tokens(Line,",") || Line<-Lines],

  %Convert coordinates to float
  FloatBoundinBoxes = [{list_to_float(Left),list_to_float(Bottom),list_to_float(Right),list_to_float(Top),Country}
    || [Left,Bottom,Right,Top,Country]<-BoundingBoxes],

  %Check if inside bounding boxes
  InsideList = [{Left,Bottom,Right,Top,Country} || {Left,Bottom,Right,Top,Country}<-FloatBoundinBoxes,
  (Longitude > Left) and (Longitude < Right)
  and  (Latitude > Bottom) and (Latitude < Top)],

  %Calculate distance to middle of bounding box
  DistList = [{Country,distance(Longitude,Latitude,(Left+Right)/2,(Top+Bottom)/2)}
    || {Left,Bottom,Right,Top,Country}<-InsideList],

  %Take out the closest
  [H | T] = DistList,
  lists:foldl(fun({CountryA,DistanceA},{_,DistanceB})
    when DistanceA < DistanceB -> CountryA;
    (_,{CountryB,_}) -> CountryB end, H,T).

%Calculate Long,Lat distance on ellipsoid
%Too: Simplify? Overkill?
distance(Lng1, Lat1, Lng2, Lat2) ->
  Deg2rad = fun(Deg) -> math:pi()*Deg/180 end,
  [RLng1, RLat1, RLng2, RLat2] = [Deg2rad(Deg) || Deg <- [Lng1, Lat1, Lng2, Lat2]],

  DLon = RLng2 - RLng1,
  DLat = RLat2 - RLat1,

  A = math:pow(math:sin(DLat/2), 2) + math:cos(RLat1) * math:cos(RLat2) * math:pow(math:sin(DLon/2), 2),
  C = 2 * math:asin(math:sqrt(A)),

  %% Radius of Earth is ~6372.8 km
  Km = 6372.8 * C,Km.