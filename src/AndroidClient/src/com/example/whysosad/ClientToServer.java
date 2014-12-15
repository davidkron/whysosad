package com.example.whysosad;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import org.apache.http.NameValuePair;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;
import android.os.AsyncTask;

/**
 * 
 * @author Petroula
 * 
 */

public class ClientToServer {
	
	String url = "http://129.16.155.25:10111/esi/esi_facade:register_user";
	InputStream input;
	JSONObject jsonObj;
	String response = "";
	List<NameValuePair> parameters;
	
	BetActivity bet = new BetActivity();
	
	public String placeBet() {
		
		
        parameters = new ArrayList<NameValuePair>();
	    parameters.add(new BasicNameValuePair("user", "petra"));
	    parameters.add(new BasicNameValuePair("password", "davidishappy"));
	    parameters.add(new BasicNameValuePair("country", bet.betCountry));
	    parameters.add(new BasicNameValuePair("hour", bet.hour));
	    parameters.add(new BasicNameValuePair("minute", bet.minutes));
	    parameters.add(new BasicNameValuePair("targetstatus", bet.predictLevel));
	    parameters.add(new BasicNameValuePair("credits", "10"));
		
		new HttpAsyncTask().execute();
		while(response == ""){}
		return response;
	}

	
    public String registerUser() {
		
        parameters = new ArrayList<NameValuePair>();
	    parameters.add(new BasicNameValuePair("user", "pikachu"));
	    parameters.add(new BasicNameValuePair("password", "Pegasus!1291615525"));
	    
		new HttpAsyncTask().execute(url);
		while(response == ""){}
		return response;
	}
	
	
	
	private class HttpAsyncTask extends AsyncTask<String, Void, String> {
    	
    	
        @Override
        protected String doInBackground(String... urls) {
 
        	try {
        	  
		
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(url);
		    
            httpPost.setEntity(new UrlEncodedFormEntity(parameters));
 
            HttpResponse httpResponse = httpClient.execute(httpPost);           
            
            input = httpResponse.getEntity().getContent();
            
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(input));
	        String line = "";
	        String result = "";
	       
	        while((line = bufferedReader.readLine()) != null)
	            result += line;
	 
	        input.close();
	        
	        response = result;
		    
        	} catch (Exception e) {}
		    
		    return response;
	}
        @Override
        protected void onPostExecute(String response) {
        }
        
  }
}