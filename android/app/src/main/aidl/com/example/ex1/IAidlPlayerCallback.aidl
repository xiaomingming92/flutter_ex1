// IAidlPlayerCallback.aidl
package com.example.ex1;

import com.example.ex1.SongInfo;

interface IAidlPlayerCallback {
    void onPositionUpdate(int position);
    void onStateChange(String state);
    void onSongComplete();
    void onSongChange(in SongInfo song);
    void onError(String error);
}
