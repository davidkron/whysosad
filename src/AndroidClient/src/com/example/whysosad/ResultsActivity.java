package com.example.whysosad;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

/**
 * 
 * @author Petroula
 * 
 */

public class ResultsActivity extends Activity implements OnClickListener{

	InputStream input = null;
    String response = "";
    String url = "http://129.16.155.25:10111/esi/esi_facade:current_happiness";
	String printCountry = "";
	String printKey = "";
	JSONObject jsonObj;
	Button refresh;	
	HashMap<String, String> countries = new HashMap();
	ArrayList<String> listCountry = new ArrayList<String>();
	ArrayList<String> listKey = new ArrayList<String>();
	TableLayout table;
	
//	String str = "{ \"Sweden\": 50,\"Denmark\": 80 }";
	Object[] example;
	
	protected void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
    	setContentView(R.layout.results);
    	createHashMap();
    	
    	table = (TableLayout)findViewById(R.id.mytable);
    	refresh = (Button)findViewById(R.id.refresh);
    	refresh.setOnClickListener(this);
   	
    	new HttpAsyncTask().execute(url);
	}
	
	private class HttpAsyncTask extends AsyncTask<String, Void, String> {
    	
    	
        @Override
        protected String doInBackground(String... urls) {
 
        	try {
        		
     	       
	            HttpClient httpClient = new DefaultHttpClient();
	 
	            HttpResponse httpResponse = httpClient.execute(new HttpGet(url));
	 
	            input = httpResponse.getEntity().getContent();
	            
	            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(input));
		        String line = "";
		        String result = "";
		        printCountry="";
		        printKey="";
		        while((line = bufferedReader.readLine()) != null)
		            result += line;
		 
		        input.close();
		        
		        response = result;
		        
	        } catch (Exception e) {}
	 
        	return response;
        	
        }

         
        @Override
        protected void onPostExecute(String response) {
        	        	
	
			try {
				
				jsonObj = new JSONObject(response.trim());
		        Iterator<?> keys = jsonObj.keys();

		        while(keys.hasNext()){
		            String key = (String)keys.next();		
		            if (countries.containsKey(key)){
		            	printCountry = countries.get(key);
		            	printKey = "" +jsonObj.get(key);
		            	listCountry.add(printCountry);
		            	listKey.add(printKey);
		            }		            
		        }	
        
		        for(int i=0; i<listCountry.size(); i++) {
					TableRow row=new TableRow(ResultsActivity.this);				
					TextView country=new TextView(ResultsActivity.this);
					country.setText(listCountry.get(i));
					TextView key=new TextView(ResultsActivity.this);
					key.setText(listKey.get(i));
					row.addView(country);
					row.addView(key);
					table.addView(row);
					
				}
        
		        
		        
			} catch (JSONException e) {				
				e.printStackTrace();
			} 
			
					
				
    	}
    }
	
	
	
    private void createHashMap(){
 	   countries.put("TR", "Turkey");
 	   countries.put("BR", "Brazil");
 	   countries.put("US", "USA");
 	   countries.put("ID", "Indonesia");
 	   countries.put("AR", "Argentina");
 	   countries.put("PH", "Philippines");
 	   countries.put("SE", "Sweden");
 	   countries.put("NO", "Norway");
 	   countries.put("MX", "Mexico");
 	   countries.put("VE", "Venezuela");
 	   countries.put("GT", "Guatemala");
 	   countries.put("RU", "Russia");
 	   countries.put("CO", "Colombia");
 	   countries.put("IN", "India");
 	   countries.put("GB", "Great Britain");
    }


	@Override
	public void onClick(View v) {
		if(v.getId()==R.id.refresh) {
			table.removeAllViews();
			listCountry.clear();
			listKey.clear();
			new HttpAsyncTask().execute(url);
		}
		
	}
}