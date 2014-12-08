package com.example.whysosad;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.RadioButton;
import android.widget.TextView;

/**
 * 
 * @author Petroula
 * 
 */

public class BetActivity extends Activity implements OnClickListener {
	
	String betCountry;
	String betKey;
	String predictLevel;
	String timeFrame;
	Button done;
	Button back;
	TextView textView1;
	CheckBox day;
	CheckBox night;
	RadioButton increase;
	RadioButton decrease;
	
	protected void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
    	setContentView(R.layout.bet_layout);
    	
    	done = (Button)findViewById(R.id.done);
    	done.setOnClickListener(this);
    	back = (Button)findViewById(R.id.back);
    	back.setOnClickListener(this);
    	textView1 = (TextView)findViewById(R.id.textView1);
    	day = (CheckBox)findViewById(R.id.day);
    	day.setOnClickListener(this);
    	night = (CheckBox)findViewById(R.id.night);
    	night.setOnClickListener(this);
    	increase = (RadioButton)findViewById(R.id.increase);
    	increase.setOnClickListener(this);
    	decrease = (RadioButton)findViewById(R.id.decrease);
    	decrease.setOnClickListener(this);
	
    	Intent changeView = getIntent();
    	betCountry = changeView.getStringExtra("country");
    	betKey = changeView.getStringExtra("key");
    	
    	textView1.setText("You chose to place your bet on " + betCountry + ". " + betCountry + "'s " + "current state equals " +
    	betKey + ". " + "You can bet on whether the current level is going to increase or decrease at one of the time frames provided below:");
	
	}

	@Override
	public void onClick(View v) {
		
		if(v.getId()==R.id.done) {
			//to do
			//send the relevant info (betCountry, betKey, predictLevel, timeFrame) to the server
			
		} else if(v.getId()==R.id.back) {			
			Intent changeView = new Intent(getApplicationContext(), ResultsActivity.class);
			startActivity(changeView);
			overridePendingTransition(R.anim.slide_left, R.anim.slide_right);
	    } else if(v.getId()==R.id.day) {
			night.setChecked(false);
			timeFrame = "day";
		} else if(v.getId()==R.id.night) {
			day.setChecked(false);
			timeFrame = "night";
		} else if(v.getId()==R.id.increase) {
			decrease.setChecked(false);
			predictLevel = "increase";
		} else if(v.getId()==R.id.decrease) {
			increase.setChecked(false);
			predictLevel = "decrease";
		} 
		
	}
}