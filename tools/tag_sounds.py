#!/usr/bin/env python3
"""Tag the game's audio files with title/artist/album/source metadata.

- MP3: prepends an ID3v2.3 header (TIT2/TPE1/TALB/COMM).
- WAV: appends a RIFF LIST/INFO chunk (INAM/IART/IPRD/ICMT) and fixes the
  RIFF size field.

All files are Freesound downloads whose filename encodes user + sound id
(e.g. 201159__kiddpark__cash-register.mp3). Audacity reads both formats
(File > Edit Metadata Tags) and can be used for further manual edits.
Run: python3 tools/tag_sounds.py
"""

import os
import struct

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

TRACKS = [
    {
        "path": "sounds/566952__code_box__funky-groove.wav",
        "title": "Funky Groove",
        "artist": "code_box",
        "album": "Freesound",
        "comment": "Dye my Roots HEX - Main scene BGM - https://freesound.org/people/code_box/sounds/566952/",
    },
    {
        "path": "sounds/201159__kiddpark__cash-register.mp3",
        "title": "Cash Register",
        "artist": "kiddpark",
        "album": "Freesound",
        "comment": "Dye my Roots HEX - round won (cash) - https://freesound.org/people/kiddpark/sounds/201159/",
    },
    {
        "path": "sounds/91920__filipe-chagas__cashierreceiptservo.wav",
        "title": "Cashier Receipt Servo",
        "artist": "filipe-chagas",
        "album": "Freesound",
        "comment": "Dye my Roots HEX - round won (money) - https://freesound.org/people/filipe-chagas/sounds/91920/",
    },
    {
        "path": "sounds/483598__raclure__wrong.mp3",
        "title": "Wrong",
        "artist": "raclure",
        "album": "Freesound",
        "comment": "Dye my Roots HEX - unused (replaced by procedural 'denied') - https://freesound.org/people/raclure/sounds/483598/",
    },
    {
        "path": "sounds/Timeout.wav",
        "title": "Timeout",
        "artist": "Unknown",
        "album": "",
        "comment": "Dye my Roots HEX - unused (replaced by procedural 'fail')",
    },
]


def syncsafe(value):
    return bytes([(value >> 21) & 0x7F, (value >> 14) & 0x7F, (value >> 7) & 0x7F, value & 0x7F])


def id3_text_frame(frame_id, text):
    data = b"\x00" + text.encode("latin-1", "replace")
    return frame_id.encode() + struct.pack(">I", len(data)) + b"\x00\x00" + data


def id3_comm_frame(text):
    data = b"\x00eng\x00" + text.encode("latin-1", "replace")
    return b"COMM" + struct.pack(">I", len(data)) + b"\x00\x00" + data


def tag_mp3(path, meta):
    frames = b"".join([
        id3_text_frame("TIT2", meta["title"]),
        id3_text_frame("TPE1", meta["artist"]),
        id3_text_frame("TALB", meta["album"]),
        id3_comm_frame(meta["comment"]),
    ])
    header = b"ID3" + bytes([3, 0, 0]) + syncsafe(len(frames))
    data = open(path, "rb").read()
    if data[:3] == b"ID3":
        # replace existing ID3v2 block
        size = ((data[6] & 0x7F) << 21) | ((data[7] & 0x7F) << 14) | ((data[8] & 0x7F) << 7) | (data[9] & 0x7F)
        data = data[10 + size:]
    open(path, "wb").write(header + frames + data)


def wav_info_chunk(meta):
    tags = [
        (b"INAM", meta["title"]),
        (b"IART", meta["artist"]),
        (b"IPRD", meta["album"]),
        (b"ICMT", meta["comment"]),
    ]
    body = b"INFO"
    for tag_id, text in tags:
        if not text:
            continue
        payload = text.encode("latin-1", "replace")
        body += tag_id + struct.pack("<I", len(payload)) + payload
        if len(payload) & 1:
            body += b"\x00"
    return b"LIST" + struct.pack("<I", len(body)) + body


def tag_wav(path, meta):
    data = open(path, "rb").read()
    chunk = wav_info_chunk(meta)
    data = data[:4] + struct.pack("<I", len(data) - 8 + len(chunk) + (len(chunk) & 1)) + data[8:]
    if len(chunk) & 1:
        chunk += b"\x00"
    open(path, "wb").write(data + chunk)


def main():
    for track in TRACKS:
        path = os.path.join(ROOT, track["path"])
        if not os.path.exists(path):
            print("MISSING:", path)
            continue
        if path.lower().endswith(".mp3"):
            tag_mp3(path, track)
        else:
            tag_wav(path, track)
        print("tagged:", track["path"])


if __name__ == "__main__":
    main()
