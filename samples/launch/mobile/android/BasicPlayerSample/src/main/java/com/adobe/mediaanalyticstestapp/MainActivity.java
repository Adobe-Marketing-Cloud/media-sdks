/*************************************************************************
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 * Copyright 2021 Adobe
 * All Rights Reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Adobe and its suppliers, if any. The intellectual
 * and technical concepts contained herein are proprietary to Adobe
 * and its suppliers and are protected by all applicable intellectual
 * property laws, including trade secret and copyright laws.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe.
 **************************************************************************/
package com.adobe.mediaanalyticstestapp;

import android.support.v7.app.AppCompatActivity;
import com.adobe.marketing.mobile.Assurance;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

public class MainActivity extends AppCompatActivity {
    Button startPlayerBtn;
    EditText assuranceURL;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        startPlayerBtn = findViewById(R.id.startVideoPlayer);
        startPlayerBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startVideoPlayer();
            }
        });
    }

    //Add button for Assurance
    public void setAssurance(View view) {
        //include Assurance url here
         assuranceURL = findViewById(R.id.assuranceUrl);
         String url = assuranceURL.getText().toString();
         Assurance.startSession(url);
    }

    public void startVideoPlayer(){
        Intent intent = new Intent(this, MediaActivity.class);
        startActivity(intent);
    }
}