
import java.io.*;
import java.net.*;
import java.util.HashMap;
import java.util.Iterator;

//import javax.net.ssl.HttpsURLConnection;



import org.json.JSONObject;


public class DataCollector {
	HashMap<String,Integer> rawdat = new HashMap<String, Integer>();
	public static HashMap<String, DataEntry> entriesMap = new HashMap<String, DataEntry>();
	HashMap <String, String[]>  countryConvert= new HashMap <String, String[]>();;
	public DataCollector (String URL){
		BufferedReader reader = null; 
		
		try {
			reader = new BufferedReader(new FileReader("./data/data/country.txt"));
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		String line = null;
		try {
			while (( line = reader.readLine()) != null) {
				//System.out.println(line);
				String[] st = line.split(",");
				countryConvert.put(st[0], st);
				
			}
			//for (String key : countryConvert.keySet()) {
			//System.out.println(key +" "+ countryConvert.get(key)[2]);
			//}
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		    
		//read data from server for test propose, read from file instead 
		String response = null;
			try {
				 response= sendGet(URL);
				 //System.out.println(response.toString());
				 
				
				
				//for (String key : rawdat.keySet()) {
					//System.out.println(key +" "+ rawdat.get(key));
				//}
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			/*
			try {
				reader = new BufferedReader(new FileReader("./data/data/testdata.txt"));
				try {
					 
					response = reader.readLine().trim();
					System.out.println(response);
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			} catch (FileNotFoundException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			*/
			parse(response);
			adapt();
		}
	
	 
		private final String USER_AGENT = "Mozilla/5.0";
		
		
		
	 
		// HTTP GET request
		public String  sendGet(String url) throws Exception { // private JSONObject
			URL obj = new URL(url);
			HttpURLConnection con = (HttpURLConnection) obj.openConnection();
	 
			// optional default is GET
			con.setRequestMethod("GET");
	 
			//add request header
			con.setRequestProperty("User-Agent", USER_AGENT);
	 
			//int responseCode = con.getResponseCode();
			//System.out.println("\nSending 'GET' request to URL : " + url);
			//System.out.println("Response Code : " + responseCode);
	 
			BufferedReader in = new BufferedReader(
			        new InputStreamReader(con.getInputStream()));
			String inputLine;
			StringBuffer response = new StringBuffer();
	 
			while ((inputLine = in.readLine()) != null) {
				response.append(inputLine);
			}
			in.close();				
			
			return response.toString().trim();
	 
		}
		
		public void parse( String response ){
			
			try {
				
				JSONObject jsonObj = new JSONObject(response);
		        Iterator<?> keys = jsonObj.keys();

		        while(keys.hasNext()){
		            String key = (String)keys.next();		           
		           rawdat.put(key,(Integer) jsonObj.get(key));
		            
		        }
			}
			catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		public void adapt(){
			for (String key : rawdat.keySet()) {
				//System.out.println(key +" "+ rawdat.get(key));
				//System.out.println(countryConvert.get(key)[2]);
				entriesMap.put(countryConvert.get(key)[1], new DataEntry(countryConvert.get(key)[2],key,Float.valueOf(rawdat.get(key))));
				//System.out.println(key +" "+ countryConvert.get(key)[2]+" "+ Float.valueOf(rawdat.get(key)));
			}
		}
		
		
}
