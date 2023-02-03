package com.bankaletihad.sdk

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import com.bankaletihad.kycsdk.NativeViewFactory
import com.bankaletihad.kycsdk.Views
import com.baseflow.permissionhandler.PermissionHandlerPlugin
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry
import kyc.BaeError
import kyc.FilePicker
import kyc.Uploader
import kyc.UploaderFile
import kyc.UploaderFile.UploaderCallback
import kyc.ob.Api
import kyc.ob.BaeInitializer
import kyc.ob.responses.GetCustomerResponse
import kyc.ob.responses.ImageCrop


private const val RESULT_METHOD_CHANNEL = "kyc.sdk/resultMethodChannel"
private const val UPLOAD_METHOD_CHANNEL = "kyc.sdk/uploaderMethodChannel"
private const val UPLOAD_EVENT_CHANNEL = "kyc.sdk/uploaderEventChannel"
private const val UPLOADER_URL =
    "https://bl4-dev-02.baelab.net/api/BAF3E974-52AA-7598-FF04-56945EF93500/48EE4790-8AEF-FEA5-FFB6-202374C61700"

class MainActivity : FlutterFragmentActivity() {
    private var EVENT_SINK: EventSink? = null
    private val uiThreadHandler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val di = BaeInitializer(this, R.raw.iengine, UPLOADER_URL)
        di.initialize(object : BaeInitializer.BaeInitializerListener {
            override fun onSuccess() {}
            override fun onFail() {}
        })
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(PermissionHandlerPlugin())
        val fm = this.supportFragmentManager
        val registry: PlatformViewRegistry = flutterEngine
            .platformViewsController
            .registry
        registry.registerViewFactory(
            Views.front.toString(),
            NativeViewFactory(fm, flutterEngine, Views.front)
        )
        registry.registerViewFactory(
            Views.back.toString(),
            NativeViewFactory(fm, flutterEngine, Views.back)
        )
        registry.registerViewFactory(
            Views.selfie.toString(),
            NativeViewFactory(fm, flutterEngine, Views.selfie)
        )
        registry.registerViewFactory(
            Views.recorder.toString(),
            NativeViewFactory(fm, flutterEngine, Views.recorder)
        )
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RESULT_METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            run {
                val api = Api(this, null)
                val gson = Gson()
                when (call.method) {
                    "getDocumentBack" -> {
                        api.getDocumentPageBack(object : Api.GetDocumentPortrait {
                            override fun onSuccess(resp: ImageCrop) {
                                result.success(resp.data)
                            }

                            override fun onFail(error: BaeError) {
                                result.error(error.code.toString(), error.message, null)
                            }
                        })
                    }
                    "getDocumentFront" -> {
                        api.getDocumentPageFront(object : Api.GetDocumentPortrait {
                            override fun onSuccess(resp: ImageCrop) {
                                result.success(resp.data)
                            }

                            override fun onFail(error: BaeError) {
                                result.error(error.code.toString(), error.message, null)
                            }
                        })
                    }
                    "getDocumentPortrait" -> {
                        api.getDocumentPortrait(object : Api.GetDocumentPortrait {
                            override fun onSuccess(resp: ImageCrop) {
                                result.success(resp.data)
                            }

                            override fun onFail(error: BaeError) {
                                result.error(error.code.toString(), error.message, null)
                            }
                        })
                    }
                    "getSelfie" -> {
                        api.getFaceCrop(object : Api.GetDocumentPortrait {
                            override fun onSuccess(resp: ImageCrop) {
                                result.success(resp.data)
                            }

                            override fun onFail(error: BaeError) {
                                result.error(error.code.toString(), error.message, null)
                            }
                        })
                    }
                    "getScannerResult" -> {
                        api.getDocumentFields(object : Api.GetDocumentFields {
                            override fun onSuccess(resp: GetCustomerResponse) {
                                val jsonString = gson.toJson(resp)
                                result.success(jsonString)
                            }

                            override fun onFail(error: BaeError) {
                                result.error(error.code.toString(), error.message, null)
                            }
                        })
                    }
                    "getSimilarity" -> {
                        api.similarity(object : Api.Similarity {
                            override fun onSuccess(response: Double) {
                                result.success(response)
                            }

                            override fun onFail(error: BaeError) {
                                result.error(error.code.toString(), error.message, null)
                            }
                        })
                    }
                    "getDocumentsUrls" -> {
                        val jsonString = gson.toJson(Uploader.urls)
                        result.success(jsonString)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        EventChannel(flutterEngine.dartExecutor, UPLOAD_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any, events: EventSink) {
                    EVENT_SINK = events
                }
                override fun onCancel(arguments: Any) {
                    EVENT_SINK = null
                }
            }
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UPLOAD_METHOD_CHANNEL
        ).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            run {
                if (call.method == "initUploader") {
                    initializeUploader()
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    private fun initializeUploader() {
        val filePickerIntent = Intent(this, FilePicker::class.java)
        val mimeTypes = arrayOf("image/gif", "application/pdf")
        filePickerIntent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes)
        startActivityForResult(filePickerIntent, 0)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 0) {
            val isLoading:HashMap<String?,String?> = HashMap()
            isLoading["type"] = "upload_started"
            isLoading["data"] = ""

            uiThreadHandler.post {
                EVENT_SINK?.success(isLoading)
            }

            val fileUploader = Uploader(this, UPLOADER_URL)
            fileUploader.addDocument(data?.data)
            fileUploader.uploadDocuments(object : UploaderCallback {
                override fun onSuccess(uploaderFile: UploaderFile) {
                    val successResult:HashMap<String?,String?> = HashMap()
                    successResult["type"] = "upload_success"
                    successResult["data"] = uploaderFile.fileUrl
                    uiThreadHandler.post {
                        EVENT_SINK?.success(successResult)
                    }
                }

                override fun onFailed(baeError: BaeError) {
                    val errorResult:HashMap<String?,String?> = HashMap()
                    errorResult["type"] = "upload_failed"
                    errorResult["data"] = baeError.message
                    println(errorResult)
                    uiThreadHandler.post {
                        EVENT_SINK?.success(errorResult)
                    }
                }
            })
        }
    }
}

