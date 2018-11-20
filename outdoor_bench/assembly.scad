
// Design Parameters
overallWidth = 1270;
overallDepth = 600;
overallHeight = 800;

reclineAngle = 10;
benchHeight = 400;
groundGap = 100;

lidThickness = 25;
lidSlatWidth = 50;
lidSlatThickness = 10;
lidSlatTab = 15;
lidRunnerWidth = 50;

legX = 30;
legY = 50;

armHeight = 500;
armOverhang = 50;
armThickness = 30;

backRestTop = 75;
backRestBottom = 50;
backRestGap = 25;
backRestThickness = 20;

backRestSlateWidth = 30;
backRestSlatCount = 17;

grillRunnerDepth = 15;
grillRunnerWidth = 45;

grillAngle = 30;
grillTab = 5;
grillThickness = 5;


// Calculated Parameters
backHeight = (overallHeight - benchHeight);

backDepth = backHeight * tan(reclineAngle);
backLength = backHeight / cos(reclineAngle);
    
seatDepth = overallDepth-armOverhang - backDepth;

innerWidth = overallWidth - 2*legX;
slatGap = (innerWidth - (backRestSlatCount * backRestSlateWidth)) / (1 + backRestSlatCount);

shortRunnerLength = benchHeight - lidThickness - 2*grillRunnerWidth - groundGap;
grillSpacing = grillRunnerDepth / sin(grillAngle);
grills = floor(shortRunnerLength / grillSpacing)-1;

lidAngle = 15;
lidSections = 3;
lidWidth = innerWidth;
lidDepth = seatDepth-armOverhang;
lidSlats = floor((lidDepth-lidRunnerWidth) / lidSlatWidth)-1;
lidRunnerGap = (lidWidth - (lidSections + 1) * lidRunnerWidth) / lidSections;
lidBackEdge = lidDepth - (lidSlats+1)*lidSlatWidth - lidSlatWidth;

assembly();

module assembly() {
    
    // Storage Front
    translate([legX, armOverhang + (legY-grillRunnerDepth), groundGap])
    container(3, innerWidth, false);
    
    // Storage Back
    translate([legX + innerWidth, seatDepth + grillRunnerDepth, groundGap])
    rotate([0,0,180])
    container(3, innerWidth, false);
    
    // Storage Left
    translate([(legX - grillRunnerDepth), (seatDepth), groundGap])
    rotate([0,0,-90])
    container(1, seatDepth-armOverhang-legY);
    
    // Storage Right
    translate([overallWidth - (legX - grillRunnerDepth), armOverhang+legY, groundGap])
    rotate([0,0,90])
    container(1, seatDepth-armOverhang-legY);
    
    // Back Panel
    translate([legX, overallDepth - backDepth - (legY+backRestThickness)/2, benchHeight]) {
        rotate([-reclineAngle, 0, 0]) {
            translate([0,0,backRestGap]) {
                backPanel(legX, legY);
            }
        }
    }
    
    
    // Sides
    sideFrame(legX, legY, armThickness);
    
    translate([overallWidth - legX, 0, 0]) {
        sideFrame(legX, legY, armThickness);
    }
    
    
    // Lid
    translate([legX,armOverhang+grillRunnerDepth,benchHeight-lidThickness]) {
        rotate([0,0,0])
        movingLidAssembly();
    }
}

module movingLidAssembly() {
    
    lidOffset = seatDepth-armOverhang;
    
    //bounds
    translate([0, lidOffset, 0])
    rotate([-lidAngle,0,0])
    translate([0, -lidOffset, 0])
    lidAssembly();
    
}

module lidAssembly() {
    
    // End Runner
    translate([0, 0, 0]) {
        lidRunner(lidSlats, lidBackEdge, right = 1);
    }
    
    // End Runner
    translate([lidWidth-lidRunnerWidth, 0, 0]) {
        lidRunner(lidSlats, lidBackEdge, left = 1);
    }
    
    
    // Middle Runners
    for(x = [1: 1: lidSections-1]) {
        translate([x * (lidRunnerGap+lidRunnerWidth), 0, 0]) {
            
            lidRunner(lidBackEdge, left = 1, right = 1);
        }
    }
    
    // Front Edge
    lidEdge();
    
    // Rear Edge
    translate([0, (lidSlats+2)*lidSlatWidth, 0])
        lidEdge(depth = lidBackEdge);
    
    // Slats
    for(x = [0: lidSections-1]) {
        
        for(y = [0 : lidSlats]) {
            xOffset = lidRunnerWidth-lidSlatTab + x * (lidRunnerWidth+lidRunnerGap);
            yOffset = lidRunnerWidth + y * lidSlatWidth;
            translate([xOffset, yOffset, (lidThickness)]) {
                
                lidSlat();
            }
        }
    }
}

module lidEdge(depth = lidRunnerWidth) {
    
    echo("LidEdge",lidWidth,depth,lidThickness);
    
    difference() {
        
        cube([lidWidth, depth, lidThickness]);
    
        translate([-1, -1, -1]) {
            cube([lidRunnerWidth+1, lidRunnerWidth+1, lidThickness - lidSlatThickness  +1]);
        }
        
        for(x = [1: 1: lidSections-1]) {
            
            translate([x * (lidRunnerGap+lidRunnerWidth), -1, -1]) {
                cube([lidRunnerWidth, lidRunnerWidth+2, lidThickness - lidSlatThickness  +1]);
            }
        }
        
        translate([lidSections * (lidRunnerGap+lidRunnerWidth), -1, -1]) {
                %cube([lidRunnerWidth+1, lidRunnerWidth+2, lidThickness - lidSlatThickness  +1]);
            }
    }
}
module lidRunner(left = 0, right = 0) {
    
    echo("LidRunner",lidDepth,lidRunnerWidth,lidThickness);
    difference() {
        cube([lidRunnerWidth, lidDepth, lidThickness]);
        
        // Front Edge notch
        translate([0, -1, lidThickness - lidSlatThickness])
            cube([lidRunnerWidth, lidRunnerWidth+1, lidSlatThickness+1]);
        
        // Back Edge Notch
        
        translate([0, (lidSlats+2)*lidSlatWidth, lidThickness - lidSlatThickness])
            cube([lidRunnerWidth, lidBackEdge+1, lidSlatThickness+1]);
        
        if(left == 1) {
            translate([-1, lidRunnerWidth, lidThickness - lidSlatThickness])
            cube([lidSlatTab+1, (lidSlats+1)*lidSlatWidth, 10+1]);
        }
        
        if(right == 1) {
            translate([lidRunnerWidth-lidSlatTab, lidRunnerWidth, lidThickness - lidSlatThickness])
            cube([lidSlatTab+1, (lidSlats+1)*lidSlatWidth, 10+1]);
        }
    }
}
module lidSlat() {
    
    echo("LidSlat",lidRunnerGap,lidSlatWidth,lidSlatThickness);
    
    gap = 1;
    
    translate([gap, gap, 0])
    rotate([0,90,0])
    linear_extrude(height=lidRunnerGap + 2*lidSlatTab - 2*gap)
    square([lidSlatThickness, lidSlatWidth-2*gap]);
}

module container(sections, width, includeLip = true) {
    
        
    grillLength = (width - (sections + 1) * grillRunnerWidth) / sections;
    
    //Bottom Runner
    echo("StorageRunner",width,grillRunnerWidth,grillRunnerDepth);
    cube([width, grillRunnerDepth, grillRunnerWidth]);
    
    // Top Runner
    
    translate([0,0,grillRunnerWidth+shortRunnerLength])
    {
        if(includeLip == true){
            echo("StorageHorizontalRunner",width,grillRunnerWidth + lidThickness,grillRunnerDepth);
            cube([width, grillRunnerDepth , grillRunnerWidth + lidThickness]);
        }
        else
        {
            echo("StorageHorizontalRunner",width,grillRunnerWidth,grillRunnerDepth);
            cube([width, grillRunnerDepth , grillRunnerWidth]);
        }
    }
    
    
    
    // Short runners
    for(x = [0: 1: sections]) {
        translate([x * (grillRunnerWidth+grillLength), 0, grillRunnerWidth]) {
            echo("StorageUprightRunner",shortRunnerLength,grillRunnerWidth,grillRunnerDepth);
            cube([grillRunnerWidth, grillRunnerDepth, shortRunnerLength]);
        }
    }
    
    for(x = [0: sections-1]) {
        
        for(y = [0 : grills]) {
            xOffset = grillRunnerWidth-grillTab + x * (grillRunnerWidth+grillLength);
            zOffset = (grillRunnerWidth + shortRunnerLength - grillSpacing) - y * grillSpacing;
            translate([xOffset, 0, zOffset]) {
                grill(grillLength);
            }
        }
    }
    
    
}

module grill(grillLength) {
    
    echo("Grill",grillLength,grillSpacing,grillThickness);
    
    rotate([90-grillAngle,0,0])
    rotate([0,90,0])
    linear_extrude(height=grillLength + 2*grillTab)
    square([grillThickness, grillSpacing]);
}

module backPanel() {
    
    //top
    echo("BackRestTop",overallWidth - 2*legX,backRestTop,backRestThickness);
    translate([0, backRestThickness, backLength-backRestTop-backRestGap]) {
        rotate([90, 0, 0])
        linear_extrude(height=backRestThickness)
        square([overallWidth - 2*legX, backRestTop]);
    }
    
    // Slat
    backSlatLength = backLength - backRestTop - backRestBottom - 2*backRestGap;
    
    for(x = [slatGap:slatGap+backRestSlateWidth:innerWidth]) {
        translate([x, 0, backRestGap + backRestBottom]) {
        
            backSlat(backSlatLength);
        }
    }
    
    
    //bottom
    echo("BackRestBottom",overallWidth - 2*legX,backRestBottom,backRestThickness);
    translate([0, backRestThickness, backRestGap]) {
        rotate([90, 0, 0])
        linear_extrude(height=backRestThickness)
        square([overallWidth - 2*legX, backRestBottom]);
    }
}

module backSlat(backSlatLength) {
    echo("BackRestSlat",backSlatLength,backRestSlateWidth,backRestThickness);
    cube([backRestSlateWidth, backRestThickness, backSlatLength]);
}

module sideFrame(armThickness) {
    
    // Arm
    translate([0, 0, armHeight]) {
        arm(armThickness, legX, seatDepth + armOverhang - legY);
    }
    
    // Rear Leg
    translate([0, overallDepth, 0]) {
        rearLeg(legX, legY);
    }
    
    // Front Leg
    translate([0, legY + armOverhang, 0]) {
        frontLeg(legX, legY);
    }
}

module arm(depth, width, length) {    
    translate([width, 0, 0])
    rotate([0, -90, 0])
    linear_extrude(height = width)
    armProfile(depth, length, width);
}

module armProfile(depth, length, thickness) {
    
    offset = armHeight - benchHeight;
    bottomExt = offset*tan(reclineAngle);
    topExt = (offset+depth)*tan(reclineAngle);
 
    echo("ArmProfile",max(length+bottomExt, length+topExt),depth,thickness);
    
    union() {
        
        // Main Profile
        square([depth, length ]);
        
        // Extensions at the end to account for recline
        polygon(points=[
            [0,length],
            [0,length+bottomExt],
            [depth, length+topExt],
            [depth, 0]
        ]);
    }
}
module frontLeg(thickness, depth) {
    translate([thickness, 0, 0])
    rotate([90, 0, -90])
    linear_extrude(height=thickness) {
        frontLegProfile(depth, thickness);
    }
}
module frontLegProfile(depth, thickness) {
    echo("FrontLeg",armHeight,depth,thickness);
    square([depth, armHeight]);
}

module rearLeg(thickness, depth) {

    translate([thickness, 0, 0])
    rotate([90, 0, -90])
    linear_extrude(height=thickness) {
        rearLegProfile(depth, thickness);
    }
}

module rearLegProfile(depth, thickness) {
        
    echo("RearLeg",overallHeight,depth + backDepth,thickness);
    
    polygon(points = [
        [backDepth, 0],
        [backDepth, benchHeight],
        [0, overallHeight],
        [depth, overallHeight],
        [depth + backDepth, benchHeight],
        [depth + backDepth, 0]
    ]);
}