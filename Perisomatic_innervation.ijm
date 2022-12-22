/*
  	<The present macro identifies the neuronal soma (immunostained with NeuN) and quantifies the number an area of 
  	perisomatic clusters>
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


//Download adjustable watershed plugin from: https://imagejdocu.tudor.lu/_media/plugin/segmentation/adjustable_watershed/adjustable_watershed.java
//Channels: 1= NeuN, 2= Syt2, 3= AAV-E2, 4= DAPI
//Analyze -> Set Measurements -> Perimeter, Area, Display label

//Hyperstack

//run("Bio-Formats Importer");
//waitForUser("Select the correct image");

title=getTitle();

//Obtain NeuN ROIs (with considerable size & circularity) and name the cells

run("Duplicate...", "duplicate channels=1");
run("Threshold...");
setOption("BlackBackground", true);
waitForUser("Set the threshold","(1) Make sure the Huang threshold is selected\n"+"(2) Dark background checked\n"+"(3) NOTE THE VALUES");
run("Gaussian Blur...", "sigma=1 scaled");
run("Convert to Mask");
run("Make Binary");
rename("Processed");
run("Duplicate...", "duplicate");
run("adjustable watershed", "tolerance=10");
run("Analyze Particles...", "size=2000-Infinity pixel circularity=0.5-1.00 show=Outlines display exclude summarize add in_situ");

	//Rename NeuN ROIS
	
		bproi = roiManager("count");
		for (i=0;i<bproi;i++){
     		  roiManager("select", i);
     		  roiManager("rename","Cell-"+i+1);
		}

selectWindow("Processed");
run("Close");
selectWindow("Processed-1");
run("Close");

waitForUser("Check the NeuN overlays","Eliminate any ROI that do not fit a cell soma");

roiManager("Deselect");
roiManager("Show All");
roiManager("Show None");

	//Rename NeuN ROIS
	
		bproi = roiManager("count");
		for (i=0;i<bproi;i++){
     		  roiManager("select", i);
     		  roiManager("rename","Cell-"+i+1);
		}


//Select all E2 puncta in the image and add them as a ROI

title=getTitle();
selectWindow(title);
run("Duplicate...", "duplicate channels=3");
run("Subtract Background...", "rolling=50");
run("Despeckle");
run("Gaussian Blur...", "sigma=0.5");
run("Smooth");
run("Enhance Contrast...", "saturated=0.5");
run("RGB Color");
run("HSB Stack");
run("Convert Stack to Images");
selectWindow("Hue");
run("Close");
selectWindow("Saturation");
run("Close");
selectWindow("Brightness");
percentage = 0.10;
target = (1-percentage)*getWidth()*getHeight();
nBins = 256;
getHistogram(values,counts,nBins);
sum = 0; threshold = -1;
for(i=0; i<nBins; i++){
  sum += counts[i];
  if( (sum >= target) & (threshold < 0) ){ threshold = i; }
  }
setThreshold(threshold, 255);
run("Threshold...");
waitForUser("Adjust threshold and click 'OK'");
run("Convert to Mask");
rename("E2 puncta");

run("Analyze Particles...", "size=0.05-Infinity circularity=0.00-1.00 show=Masks");
run("Invert");
run("adjustable watershed", "tolerance=0.3");
run("Invert");

	//Add E2 puncta as a ROI
	
	run("Create Selection");
	roiManager("Add");
		bproi = roiManager("count");
		roiManager("select", bproi-1);
   		roiManager("rename","E2Total");
   		roiManager("deselect");

//Final step: E2puncta/cell

bproi = roiManager("count");
for (i=0;i<bproi-1;i++){
    selectWindow("Mask of E2 puncta");
    run("Duplicate...", "duplicate");
    roiManager("select", i);
    run("Enlarge...", "enlarge=-0.1");
	run("Make Band...", "band=0.4");
	run("Clear Outside");
	run("Invert");
	run("Analyze Particles...", "size=0.04-Infinity show=Masks display summarize");
	run("Create Selection");

	roiType = selectionType();
	if (roiType==-1){
		run("Close");
	}
	
	roiManager("Add");
	bproi1 = roiManager("count");
	roiManager("select", bproi1-1);
	roiManager("Rename", "E2PunctaCell-"+i+1);
}

selectWindow(title);
close("\\Others");


Index1=indexOf(title, "_");
dotIndex2=indexOf(title, ".");
NAME=substring(title, Index1, dotIndex2);

selectWindow("Summary");
saveAs("Results","type_location/Summary"+NAME+".xls");
selectWindow("Results");
saveAs("Results","type_location/Results"+NAME+".xls");
roiManager("select all");
saveAs("Results","type_location/ROIs"+NAME+"_2.zip");





