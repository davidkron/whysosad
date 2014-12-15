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
import android.widget.TimePicker;

/**
 * 
 * @author Petroula
 * 
 */

public class BetActivity extends Activity implements OnClickListener {
	
	String betCountry;
	String betKey;
	String predictLevel;
	String hour;
	String minutes;
	Button done;
	Button back;
	TextView textView1;
	CheckBox day;
	CheckBox night;
	RadioButton increase;
	RadioButton decrease;
	TimePicker timePicker1;
	TextView textView2;
	TextView textView3;
	
	
	protected void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
    	setContentView(R.layout.bet_layout);
    	
    	textView2 = (TextView)findViewById(R.id.textView2);
    	textView3 = (TextView)findViewById(R.id.textView3);
    	
    	done = (Button)findViewById(R.id.done);
    	done.setOnClickListener(this);
    	back = (Button)findViewById(R.id.back);
    	back.setOnClickListener(this);
    	textView1 = (TextView)findViewById(R.id.textView1);
    	increase = (RadioButton)findViewById(R.id.increase);
    	increase.setOnClickListener(this);
    	decrease = (RadioButton)findViewById(R.id.decrease);
    	decrease.setOnClickListener(this);
    	
    	timePicker1 = (TimePicker)findViewById(R.id.timePicker1);
	
    	Intent changeView = getIntent();
    	betCountry = changeView.getStringExtra("country");
    	betKey = changeView.getStringExtra("key");
    	
    	textView1.setText("You chose to place your bet on " + betCountry + ". " + betCountry + "'s " + "current state equals " +
    	betKey + ". " + "You can bet on whether the current level is going to increase or decrease at one of the time frames provided below:");
	
	}

	
		
	@Override
	public void onClick(View v) {
		
		if(v.getId()==R.id.done) {
			hour = timePicker1.getCurrentHour() + "";
			minutes =  timePicker1.getCurrentMinute() + "";
			
			String s = new ClientToServer().registerUser();
			
			textView2.setText(s);
//			textView3.setText(minutes);
		} else if(v.getId()==R.id.back) {			
			Intent changeView = new Intent(getApplicationContext(), ResultsActivity.class);
			startActivity(changeView);
			overridePendingTransition(R.anim.slide_left, R.anim.slide_right); 
		} else if(v.getId()==R.id.increase) {
			decrease.setChecked(false);
			predictLevel = "increase";
		} else if(v.getId()==R.id.decrease) {
			increase.setChecked(false);
			predictLevel = "decrease";
		} 
		
	}
}