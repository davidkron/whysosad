

import java.util.HashMap;
import java.util.List;

import processing.core.PApplet;
import de.fhpotsdam.unfolding.UnfoldingMap;
import de.fhpotsdam.unfolding.data.Feature;
import de.fhpotsdam.unfolding.data.GeoJSONReader;
import de.fhpotsdam.unfolding.marker.Marker;
import de.fhpotsdam.unfolding.utils.MapUtils;

/**
 * Visualizes happiness of the world as a choropleth map. Countries are shaded in proportion to the happiness level.
 * 
 * 
 * It loads the country shapes from a GeoJSON file via a data reader, and loads the happiness values from
 * our online server (provided by the erlang backend). The data value is encoded to transparency via a simplistic linear
 * mapping.
 */
public class HelloWorldMap extends PApplet {

	UnfoldingMap map;
	String countryID;
	String countryName = "N/A";
	float happiness = 0;
	HashMap<String, DataEntry> dataEntriesMap;
	List<Marker> countryMarkers;
	int scale =10;

	public void setup() {
		size(1366, 768, OPENGL);
		smooth();
		//
		List<Feature> countries = GeoJSONReader.loadData(this, "data/countries.geo.json");
		countryMarkers = MapUtils.createSimpleMarkers(countries);
		//dataEntriesMap = loadPopulationDensityFromCSV("data/test.csv");//("data/countries-population-density.csv");
		dataEntriesMap = getCountry(); 
		//
		map = new UnfoldingMap(this, 0, 0, 1366, 768);//(this, 50, 50, 700, 500);
		map.zoomToLevel(2);
		map.setBackgroundColor(240);//240
		MapUtils.createDefaultEventDispatcher(this, map);

		// Load country polygons and adds them as markers
		//List<Feature> countries = GeoJSONReader.loadData(this, "data/countries.geo.json");
		//countryMarkers = MapUtils.createSimpleMarkers(countries);
		map.addMarkers(countryMarkers);

		// Load population data
		//dataEntriesMap = loadPopulationDensityFromCSV("data/test.csv");//("data/countries-population-density.csv");
		println("Loaded " + dataEntriesMap.size() + " data entries");

		// Country markers are shaded according to its population density (only once)
		//shadeCountries();
	}

	public void draw() {
		background(240);
		shadeCountries();

		// Draw map tiles and country markers
		map.draw();
		//Listener
		
		//for (int i = 0; i < countryMarkers.size(); i++){//countryMarkers.get(i);
		   for( Marker mark : countryMarkers){
		    
		    if(mark.isInside(map, mouseX, mouseY)){
		    	//mark.draw(map);
		    	//
		    	
		    	countryID = mark.getId();  //   .countryName;//.get("countryName").toString();
		    	countryName = "N/A";
		    	happiness = 0;
		    	if (dataEntriesMap.containsKey(countryID)){
		    		countryName = dataEntriesMap.get(countryID).countryName;
		    		happiness = dataEntriesMap.get(countryID).value;
		    	}
		    	//String info =  countryName + "  "+happiness;  // REGION: "+
		    	text(happiness,mouseX, mouseY);
		    	
		    	mark.draw(map);
		    }
		    
		 
		  }
		  
	}
	
	public void mousePressed() {
		if (mouseButton == RIGHT) {
			javax.swing.JOptionPane.showMessageDialog(null, " COUNTRY: "+countryName +"\n"+ " HAPPINESS: " + happiness );
		}
		
		}

	public void shadeCountries() {
		for (Marker marker : countryMarkers) {
			// Find data for country of the current marker
			String countryId = marker.getId();
			DataEntry dataEntry = dataEntriesMap.get(countryId);

			if (dataEntry != null && dataEntry.value != null) {
				// Encode value as brightness (values range: 0-1000) 
				if (dataEntry.value>0){
					float transparency = map(dataEntry.value, 0, scale, 10, 255);
					marker.setColor(color(0,  255, 0,  transparency));//color(255, 0, 0, transparency) blue
				}
				else{
					float transparency = map(-dataEntry.value, 0, scale, 10, 255);
					marker.setColor(color(255, 0, 0, transparency));//color(255, 0, 0, transparency) red
				}
				
			} else {
				// No value available
				marker.setColor(color(100, 120));
			}
		}
	}
	public HashMap<String, DataEntry> getCountry(){
		return DataCollector.entriesMap;
		/*
		HashMap<String, DataEntry> dataEntriesMap = new HashMap<String, DataEntry>();
		DataEntry dataEntry0 = new DataEntry("United States of America","USA",(float)200 );		
		dataEntriesMap.put(dataEntry0.id, dataEntry0);
		
		DataEntry dataEntry1 = new DataEntry("Sweden","SWE",(float) 500);
		dataEntriesMap.put(dataEntry1.id, dataEntry1);
		
		DataEntry dataEntry2 = new DataEntry("D.P.R.K","PRK",(float) -650);
		dataEntriesMap.put(dataEntry2.id, dataEntry2);
		//Japan;JPN;349.659808
		DataEntry dataEntry3 = new DataEntry("Japan","JPN", (float) -250);		
		dataEntriesMap.put(dataEntry3.id, dataEntry3);
		return dataEntriesMap;
		*/
	}
	/*
	public HashMap<String, DataEntry> loadPopulationDensityFromCSV(String fileName) {
		HashMap<String, DataEntry> dataEntriesMap = new HashMap<String, DataEntry>();

		String[] rows = loadStrings(fileName);
		for (String row : rows) {
			// Reads country name and population density value from CSV row
			String[] columns = row.split(";");
			if (columns.length >= 3) {
				DataEntry dataEntry = new DataEntry();
				dataEntry.countryName = columns[0];
				dataEntry.id = columns[1];
				dataEntry.value = Float.parseFloat(columns[2]);
				dataEntriesMap.put(dataEntry.id, dataEntry);
			}
		}

		return dataEntriesMap;
	}
	*/

	

}