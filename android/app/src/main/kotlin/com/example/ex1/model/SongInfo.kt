package com.example.ex1.model

import android.os.Parcel
import android.os.Parcelable

class SongInfo(
    val id: String,
    val title: String,
    val artist: String,
    val album: String,
    val coverUrl: String,
    val audioUrl: String,
    val duration: Long
) : Parcelable {
    constructor(parcel: Parcel) : this(
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        parcel.readLong()
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(id)
        parcel.writeString(title)
        parcel.writeString(artist)
        parcel.writeString(album)
        parcel.writeString(coverUrl)
        parcel.writeString(audioUrl)
        parcel.writeLong(duration)
    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<SongInfo> {
        override fun createFromParcel(parcel: Parcel): SongInfo {
            return SongInfo(parcel)
        }

        override fun newArray(size: Int): Array<SongInfo?> {
            return arrayOfNulls(size)
        }
    }
}
