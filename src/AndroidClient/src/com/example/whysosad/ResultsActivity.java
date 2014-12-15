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
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.Gravity;
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
    String url = "http://129.16.155.25:10111/esi/esi_facade:current_happiness?apikey=23jk4n823nasdf23rgdf";
	String printCountry = "";
	String printKey;
	JSONObject jsonObj;
	Button refresh;	
	HashMap<String, String> countries = new HashMap();
	ArrayList<String> listCountry = new ArrayList<String>();
	ArrayList<String> listKey = new ArrayList<String>();
	TableLayout table;
	TableRow tableRow1;
	String selectedCountry;
	String selectedKey;
	
	protected void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
    	setContentView(R.layout.results);
    	createHashMap();
    	
    	table = (TableLayout)findViewById(R.id.mytable);
    	tableRow1 = (TableRow)findViewById(R.id.tableRow1);
    	refresh = (Button)findViewById(R.id.refresh);
    	refresh.setOnClickListener(this);
   	
    	new HttpAsyncTask().execute(url);
	}
	
	
	/** Asynchronous task to handle the http request to the server. 
	 *  Returns a Json object (countries and values)
	 *  and further puts them in array lists in order to appear properly
	 *  inside the table layout. */
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
		        printKey=null;
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
		            	printKey = "" + jsonObj.get(key);
		            	listCountry.add(printCountry);
		            	listKey.add(printKey);
		            }		            
		        }	
        
		        
		        /** Dynamically create table rows for displaying the results received from the server */		
		        for(int i=0; i<listCountry.size(); i++) {
					final TableRow row=new TableRow(ResultsActivity.this);
					TextView country=new TextView(ResultsActivity.this);
					country.setText(listCountry.get(i));
					country.setTextColor(Color.BLUE);
					country.setTextSize(30);
					country.setGravity(Gravity.CENTER);
					TextView key=new TextView(ResultsActivity.this);
					key.setText(listKey.get(i));
					key.setTextSize(30);
					key.setGravity(Gravity.CENTER);
					
					row.setClickable(true);
					row.setOnClickListener(new OnClickListener() {
						
						
						/** Displays a dialog box after clicking on any of the table rows */
						@SuppressWarnings("deprecation")
						public void onClick(final View v) {
							row.setBackgroundColor(Color.GRAY);
		                	final AlertDialog alert = new AlertDialog.Builder(ResultsActivity.this).create();
		            		alert.setTitle("*Bet*"); 
		            		alert.setMessage("Do you want to place a bet?");
//		            		alert.setIcon(R.drawable.reset_pic); 
		            		alert.setButton("No", new DialogInterface.OnClickListener() {
		            			public void onClick(final DialogInterface dialog, final int which) {
		            				alert.dismiss();
		            				row.setBackgroundColor(Color.BLACK);
		            			}
		            			});
		            		alert.setCanceledOnTouchOutside(false);	
		            		alert.setButton2("Yes", new DialogInterface.OnClickListener() {
		            			public void onClick(DialogInterface dialog, int which) {
		            				
		            				/** Get the info from the selected row and pass it to the other activity */
		            				TableRow tr = (TableRow) v;
		            				TextView selectedC = (TextView) tr.getChildAt(0);
		            				TextView selectedK = (TextView) tr.getChildAt(1);		            				
		            				selectedCountry = selectedC.getText().toString();
		            				selectedKey = selectedK.getText().toString();		            				
		            				Intent changeView = new Intent(getApplicationContext(), BetActivity.class);		            						            				
		            				changeView.putExtra("country", selectedCountry);
		            				changeView.putExtra("key", selectedKey);
		            				
		            				startActivity(changeView);	            				
		            				
		            				overridePendingTransition(R.anim.slide_right, R.anim.slide_left);
		            			}
		            			});
		            		alert.setCanceledOnTouchOutside(false);
		            		alert.show();
		            	}
		                });									
					
					if(Integer.parseInt(listKey.get(i))<0) {
						key.setTextColor(Color.RED);
					} else if(Integer.parseInt(listKey.get(i))==0) {
						key.setTextColor(Color.YELLOW);
					} else {
						key.setTextColor(Color.GREEN);
					}
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

    
    /** Refreshes the results from the server */
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