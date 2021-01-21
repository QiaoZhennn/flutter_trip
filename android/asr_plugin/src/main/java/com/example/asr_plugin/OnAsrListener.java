package com.example.asr_plugin;


public interface OnAsrListener {

    void onAsrReady();

    void onAsrBegin();

    void onAsrEnd();

    void onAsrPartialResult(String[] results, RecogResult recogResult);

    void onAsrOnlineNluResult(String nluResult);

    void onAsrFinalResult(String[] results, RecogResult recogResult);

    void onAsrFinish(RecogResult recogResult);

    void onAsrFinishError(int errorCode, int subErrorCode, String descMessage,
                          RecogResult recogResult);

    void onAsrLongFinish();

    void onAsrVolume(int volumePercent, int volume);

    void onAsrAudio(byte[] data, int offset, int length);

    void onAsrExit();

    void onOfflineLoaded();

    void onOfflineUnLoaded();
}
