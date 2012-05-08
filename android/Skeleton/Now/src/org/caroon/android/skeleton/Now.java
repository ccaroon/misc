package org.caroon.android.skeleton;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import java.util.Date;
import java.text.SimpleDateFormat;

public class Now
    extends Activity
    implements View.OnClickListener
{
    Button btn;
    SimpleDateFormat sdf = new SimpleDateFormat("MM-dd-yyyy hh:mm:ssa");
    
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        btn = (Button)findViewById(R.id.button);
        btn.setOnClickListener(this);
        updateTime();
    }
    
    public void onClick(View view)
    {
        updateTime();
    }
    
    private void updateTime()
    {
        btn.setText(sdf.format(new Date()));
    }
}
