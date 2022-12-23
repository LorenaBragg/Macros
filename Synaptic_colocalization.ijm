/*
  	<The present macro identifies and measures the colocalization of two signals in a plane>
    Copyright (C) <2022>  <Lorena Bragg Gonzalo> Contact: lorenabragggonzalo@gmail.com
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
*/

//For starters, you have to download the Log 3D plugin: http://bigwww.epfl.ch/sage/soft/LoG3D/
//Type location at the end of the script to select the folder in which you want to save the files

//Choose the merged hyperstack to be opened
run("Bio-Formats Importer");
waitForUser("Select the correct image");

title = getTitle();

//Duplicate the E2 channel and enlarge the puncta to cover nearby positions
run("Duplicate...", "duplicate channels=3");
run("Subtract Background...", "rolling=50 sliding");
run("LoG 3D", "sigmax=3 sigmay=3 sigmaz=1 displaykernel=0 volume=1");
title1 = getTitle();
selectWindow("LoG of "+title1);
rename("E2 processed");
setOption("BlackBackground", true);
run("Make Binary");
//run("Mask Of Nearby Points", "add=3.0000 ...=128");
run("Watershed");
run("Analyze Particles...", "display exclude include summarize add in_situ");
selectWindow("Results");
run("Close");

//Duplicate the Syt2 channel and process
selectWindow(title);
run("Duplicate...", "duplicate channels=2");
run("Subtract Background...", "rolling=50 sliding");
title3 = getTitle();
run("LoG 3D", "sigmax=3 sigmay=3 sigmaz=1 displaykernel=0 volume=1");
selectWindow("LoG of "+ title3);
rename("Syt2 processed");
setOption("BlackBackground", true);
run("Make Binary");

//title4 = getTitle();
//selectWindow(title4);
roiManager("Select all");
roiManager("Measure");

//Superimposed the results
selectWindow("E2 processed");
run("Green");
selectWindow("Syt2 processed");
run("Duplicate...", "Syt2 processed");
selectWindow("Syt2 processed");
run("Magenta");
run("Merge Channels...", "c1=[E2 processed] c2=[Syt2 processed] create");

//Save results
roiManager("Select all");
roiManager("Save", "type_location/E2+Syt2_"+title+".zip");
selectWindow("Results"); 
saveAs("Results", "type_location/E2+Syt2_Results"+title+".xls");
selectWindow("Summary");
saveAs("Results", "type_location/E2+Syt2_Summary"+title+".xls");

selectWindow("Composite");
run("RGB Color");
saveAs("Tiff", "type_location/E2+Syt2_Results"+title+".tif");