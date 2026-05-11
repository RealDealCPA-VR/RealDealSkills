# Stitching

Combine per-shot mp4s into a final cut with ffmpeg.

## Concat (no transitions)

```
ffmpeg -f concat -safe 0 -i concat-list.txt -c copy out.mp4
```

`concat-list.txt`:

```
file 'shots/shot_01.mp4'
file 'shots/shot_02.mp4'
file 'shots/shot_03.mp4'
```

`-c copy` works only if all clips share the same codec, fps, resolution, and pixel format. The pipeline ensures this. If it ever doesn't, re-encode:

```
ffmpeg -f concat -safe 0 -i concat-list.txt -c:v libx264 -crf 18 -preset slow -c:a aac out.mp4
```

## Crossfade between shots

For each consecutive pair:

```
ffmpeg -i a.mp4 -i b.mp4 -filter_complex \
  "[0:v][1:v]xfade=transition=fade:duration=0.5:offset=4.5,format=yuv420p" \
  -c:v libx264 -crf 18 a_to_b.mp4
```

Where `offset` = duration of `a.mp4` minus the transition length.

## Color match

Different image-to-video models drift in color grade. Force a uniform LUT or curves filter at the concat step:

```
ffmpeg -f concat -safe 0 -i concat-list.txt -vf "curves=preset=increase_contrast,eq=saturation=1.05" -c:v libx264 -crf 18 out.mp4
```

## Titles and end card

Generate as still images (text-to-image, or just text on solid via ffmpeg `drawtext`) and hold for 2–4 seconds at start/end. Concat as normal mp4s.
