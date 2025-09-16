package com.mochasmindlab.mlhealth

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class MLFitnessApplication : Application() {
    
    override fun onCreate() {
        super.onCreate()
        // Initialize any app-wide configurations here
    }
}