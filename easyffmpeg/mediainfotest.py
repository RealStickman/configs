#!/usr/bin/env python3

# Mediainfo wrapper
import pymediainfo

media_info = pymediainfo.MediaInfo.parse(
    "/mnt/storage/MediaLibrary/_output/[Drag] Durarara!! - 15 (BD 1080p x264 10-bit FLAC) [1E249118].mkv"
)
for track in media_info.tracks:
    if track.track_type == "Text":
        # NOTE get all data
        # print(track.to_data())
        print(
            "Subtitle Stream: {t.stream_identifier}, Size: {t.stream_size}".format(
                t=track
            )
        )

# all data
"""
{'track_type': 'Text', 'count': '304', 'count_of_stream_of_this_kind': '2', 'kind_of_stream': 'Text', 'other_kind_of_stream': ['Text'], 'stream_identifier': 0, 'other_stream_identifier': ['1'], 'streamorder': '3', 'track_id': 4, 'other_track_id': ['4'], 'unique_id': '13175609095553569913', 'format': 'ASS', 'other_format': ['ASS'], 'format_url': 'http://ffdshow.sourceforge.net/tikiwiki/tiki-index.php?page=Getting+ffdshow', 'commercial_name': 'ASS', 'codec_id': 'S_TEXT/ASS', 'codec_id_info': 'Advanced Sub Station Alpha', 'duration': '1462540.000000', 'other_duration': ['24 min 22 s', '24 min 22 s 540 ms', '24 min 22 s', '00:24:22.540', '00:24:22.540'], 'bit_rate': 199, 'other_bit_rate': ['199 b/s'], 'frame_rate': '0.346', 'other_frame_rate': ['0.346 FPS'], 'frame_count': '506', 'count_of_elements': '506', 'compression_mode': 'Lossless', 'other_compression_mode': ['Lossless'], 'stream_size': 36545, 'other_stream_size': ['35.7 KiB (0%)', '36 KiB', '36 KiB', '35.7 KiB', '35.69 KiB', '35.7 KiB (0%)'], 'proportion_of_this_stream': '0.00003', 'title': 'Signs & Songs [Coalgirls]', 'language': 'zxx', 'other_language': ['zxx', 'zxx', 'zxx'], 'default': 'Yes', 'other_default': ['Yes'], 'forced': 'No', 'other_forced': ['No']}
{'track_type': 'Text', 'count': '304', 'count_of_stream_of_this_kind': '2', 'kind_of_stream': 'Text', 'other_kind_of_stream': ['Text'], 'stream_identifier': 1, 'other_stream_identifier': ['2'], 'streamorder': '4', 'track_id': 5, 'other_track_id': ['5'], 'unique_id': '10941183927163099426', 'format': 'ASS', 'other_format': ['ASS'], 'format_url': 'http://ffdshow.sourceforge.net/tikiwiki/tiki-index.php?page=Getting+ffdshow', 'commercial_name': 'ASS', 'codec_id': 'S_TEXT/ASS', 'codec_id_info': 'Advanced Sub Station Alpha', 'duration': '1462540.000000', 'other_duration': ['24 min 22 s', '24 min 22 s 540 ms', '24 min 22 s', '00:24:22.540', '00:24:22.540'], 'bit_rate': 70, 'other_bit_rate': ['70 b/s'], 'frame_rate': '0.091', 'other_frame_rate': ['0.091 FPS'], 'frame_count': '133', 'count_of_elements': '133', 'compression_mode': 'Lossless', 'other_compression_mode': ['Lossless'], 'stream_size': 12980, 'other_stream_size': ['12.7 KiB (0%)', '13 KiB', '13 KiB', '12.7 KiB', '12.68 KiB', '12.7 KiB (0%)'], 'proportion_of_this_stream': '0.00001', 'title': 'Full Subtitles [Coalgirls]', 'language': 'en', 'other_language': ['English', 'English', 'en', 'eng', 'en'], 'default': 'No', 'other_default': ['No'], 'forced': 'No', 'other_forced': ['No']}
"""
