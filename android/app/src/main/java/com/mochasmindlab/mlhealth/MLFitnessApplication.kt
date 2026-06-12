package com.mochasmindlab.mlhealth

import android.app.Application
import com.mochasmindlab.mlhealth.services.BillingManager
import com.mochasmindlab.mlhealth.services.NotificationService
import dagger.hilt.android.HiltAndroidApp
import javax.inject.Inject

@HiltAndroidApp
class MLFitnessApplication : Application() {

    @Inject lateinit var notificationService: NotificationService
    @Inject lateinit var billingManager: BillingManager

    override fun onCreate() {
        super.onCreate()
        notificationService.createChannel()
        billingManager.connect()
    }
}