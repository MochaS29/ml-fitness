package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.BuildConfig

object SecretsManager {
    val anthropicApiKey: String?
        get() = BuildConfig.ANTHROPIC_API_KEY.takeIf { it.isNotBlank() }
}
