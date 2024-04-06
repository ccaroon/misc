# How-to Convert an Image to an SVG

1. Take a photo of object on iPhone
2. Long-press object in photo to create a Sticker
3. Upload sticker image from phone to computer
4. Open sticker image in GIMP and clean up as necessary.
5. At this point the sticker image should only the object you want to model with NO 
   background, i.e. transparent background.
6. Launch Inkscape
7. File -> Import -> Select Image
   - Embed
   - DPI from file
   - Mode: Auto
   - OK
8. Path -> Trace Bitmap...
   - Multicolor
   - Detection mode: Colors
   - Scans: 2
   - Smooth
   - Remove Background
   - Apply
9. Traced Image will appear ON TOP OF imported image
10. Ctrl-X to Cut it to clipboard
11. Select Original Image -> Delete
12. Ctrl-V to paste Traced Image
13. Position Properly
14. Edit -> Resize Page to Selection
15. Save As...
    - Enter new file name
    - Save
16. SVG can now be imported into OpenSCAD and extruded to a 3D model. 
