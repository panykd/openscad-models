$openScad = "C:\Program Files\OpenSCAD\openscad.exe"

$scadFile = "cde_v1.scad";

& $openScad -Dselector=0 -o "assembly.stl" $scadFile;

& $openScad -Dselector=1 -o "outlet.stl" $scadFile;
& $openScad -Dselector=2 -o "inlet.stl" $scadFile;
& $openScad -Dselector=3 -o "funnel.stl" $scadFile;