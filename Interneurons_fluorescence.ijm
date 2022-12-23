/*
  	<The present macro identifies and measures positive neurons in the different
  	layers of the mouse cortex and measures the intensity of their signal, also
  	measuring the background of the staining>
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

//Type location at the end of the script to select the folder in which you want to save the files

//Choose the merged hyperstack to be opened
FilePath=File.openDialog("Select a File");
run("Bio-Formats Macro Extensions");
Ext.setId(FilePath);
Ext.getSeriesCount(seriesCount);
run("Bio-Formats Importer","open=&FilePath color_mode=Colorized view=Hyperstack stack_order=XYCZT series_"+seriesCount+"");

waitForUser("Is the image OK? (remember to set the background)");

roiManager("Show All");
roiManager("Show None");

//The game is on
run("Duplicate...", "duplicate");
title=getTitle();
run("Split Channels");
selectWindow("C3-"+title);
run("Close");
selectWindow("C2-"+title);
run("Brightness/Contrast...");
waitForUser("Adjust Brightness");
run("Duplicate...", "duplicate");
run("8-bit")
run("Grays");

//Pre-processing
run("Threshold...");
waitForUser("set the threshold AND NOTE THE VALUES");
run("Make Binary");
run("Gaussian Blur...", "sigma=2 scaled");
run("Convert to Mask");
run("Watershed");
rename("Processed");

//Eliminate space between layers
roiManager("Select",newArray(1,2,3,4,5,6,7));
roiManager("Combine");
run("Clear Outside");
roiManager("Select",0);
run("Clear Outside");

//Rename ROIs
function renLayers(layer,name) {
	roiManager("Select",layer);
	roiManager("Rename",name);
}

renLayers(0,"S1");
renLayers(1,"L1");
renLayers(2,"L2/3");
renLayers(3,"L4");
renLayers(4,"L5a");
renLayers(5,"L5b");
renLayers(6,"L6");
renLayers(7,"WM");

//Count INs/layer
function INs_layer(layer,b,c,name) {	
	selectWindow("Processed")
	roiManager("Show None");
	roiManager("Show All");
	run("Duplicate...","Processed");
	roiManager("Select",layer);
	run("Analyze Particles...","size=20-Infinity pixel show=Outlines display summarize add in_situ");

		//rename rois with the layer and number of IN
		bproi = roiManager("count");
		roiname=name+"-";
		for (i=c;i<bproi;i++){
     	   roiManager("select", i);
     	   roiManager("rename",roiname+i-14);
		}

		//Label the layer in the Summary table			
		selectWindow("Summary");
		for (i = b; i < b+1; i++) {
		Table.set("Total Area", i, name);
		}
}

INs_layer(1,0,15,"L1");
INs_layer(2,1,15+nResults,"L2/3");
INs_layer(3,2,15+nResults,"L4");
INs_layer(4,3,15+nResults,"L5a");
INs_layer(5,4,15+nResults,"L5b");
INs_layer(6,5,15+nResults,"L6");
INs_layer(7,6,15+nResults,"WM");

selectWindow("Results");
run("Close");

//Close all the "processed" images
while (nImages>3) { 
	selectImage(nImages); 
    close(); 
} 

//Change the title in the Summary table
selectWindow("Summary");
Table.renameColumn("Total Area", "Layer");

waitForUser("Check the ROIs and eliminate the inappropriate ones");
roiManager("deselect");

//Measure S1, layers, background and INs fluorescence in the non-binary image
selectWindow("C2-"+title);
roiManager("multi-measure append")

//Save the results with the name of the corresponding image
title=getTitle();
selectWindow("C2-"+title);
name=getTitle();
Index1=indexOf(name, "-");
dotIndex2=indexOf(name, ".");
NAME=substring(name, Index1, dotIndex2);

roiManager("Select all");
roiManager("save", "type_location/ROI"+NAME+".zip")
selectWindow("Results");
saveAs("Results", "type_location/Fluor"+NAME+".xls");

//Close all windows
waitForUser("When you finish, press OK to close all");
run("Close All");