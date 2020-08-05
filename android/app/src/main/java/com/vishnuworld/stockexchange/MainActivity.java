package com.vishnuworld.stockexchange;

import io.flutter.embedding.android.FlutterActivity;

package org.devio.flutter.splashscreen.example;
import android.os.Bundle;

+ import org.devio.flutter.splashscreen.flutter_splash_screen.SplashScreen;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        +       SplashScreen.show(this, true);// here
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
    }
}