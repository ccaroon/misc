package org.caroon.android.basic;

import android.app.Activity;
import android.os.Bundle;
import android.widget.*;

public class SwitchDemo
    extends Activity
    implements CompoundButton.OnCheckedChangeListener
{
    Switch sw;
    
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        sw = (Switch)findViewById(R.id.switchdemo);
        sw.setOnCheckedChangeListener(this);
    }
    
    public void onCheckedChanged(CompoundButton cb, boolean isChecked)
    {
        Switch s = (Switch)cb;
        if (isChecked)
        {
            s.setTextOn("This Switch is: -ON-");
        }
        else
        {
            s.setTextOff("This Switch is: -OFF-");
        }
    }
}
