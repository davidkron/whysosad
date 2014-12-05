package com.example.whysosad;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;


/**
 * 
 * @author Petroula
 * 
 */


public class MainActivity extends Activity {
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		
		new CountDownTimer(3000, 1000) {
		
		public void onTick(long millisUntilFinished) {
		
		}
		public void onFinish() {
		
			Intent changeView = new Intent(getApplicationContext(), ResultsActivity.class);
			startActivity(changeView);
			
		}
		}.start();
		
	}

		 		
}