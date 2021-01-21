package com.example.asr_plugin;

import com.baidu.speech.EventListener;
import com.baidu.speech.EventManager;
import com.baidu.speech.EventManagerFactory;
import com.baidu.speech.asr.SpeechConstant;

import android.content.Context;
import android.util.Log;

import org.json.JSONObject;

import java.util.Map;

public class AsrManager {
    private static final String TAG = "AsrManager";
    private EventManager asr;

    private RecogEventAdapter eventListener;


    private static volatile boolean isInited = false;

    public AsrManager(Context context, OnAsrListener listener) {
        if (isInited) {
            Log.e(TAG, "havent called release(), don't create a new class");
            throw new RuntimeException("havent called release(), don't create a new class");
        }
        isInited = true;
        asr = EventManagerFactory.create(context, "asr");
        asr.registerListener(eventListener = new RecogEventAdapter(listener));
    }


    public void start(Map<String, Object> params) {
        if (!isInited) {
            throw new RuntimeException("release() was called");
        }
        String json = new JSONObject(params).toString();
        Log.i(TAG + ".Debug", "Getting param" + json);
        asr.send(SpeechConstant.ASR_START, json, null, 0, 0);
    }

    public void stop() {
        Log.i(TAG, "Stop recording");
        if (!isInited) {
            throw new RuntimeException("release() was called");
        }
        asr.send(SpeechConstant.ASR_STOP, "{}", null, 0, 0);
    }

    public void cancel() {
        Log.i(TAG, "Cancelled recognication");
        if (!isInited) {
            throw new RuntimeException("release() was called");
        }
        asr.send(SpeechConstant.ASR_CANCEL, "{}", null, 0, 0);
    }

    public void release() {
        if (asr == null) {
            return;
        }
        cancel();
        asr.unregisterListener(eventListener);
        asr = null;
        isInited = false;
    }
}
