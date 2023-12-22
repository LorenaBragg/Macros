/* Semi-automated macro to quantify the number of GFP+ neurons in coronal sections of mouse cerebral cortex
    Copyright (C) <2022>  <Lorena Bragg-Gonzalo> Contact: lorenabragggonzalo@gmail.com
 
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.
 
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
 
//Choose the merged hyperstack to be opened
FilePath=File.openDialog("Select a File");
run("Bio-Formats Macro Extensions");
Ext.setId(FilePath);
Ext.getSeriesCount(seriesCount);
run("Bio-Formats Importer","open=&FilePath color_mode=Colorized view=Hyperstack stack_order=XYCZT series_"+seriesCount+"");
 
run("Brightness/Contrast...");
waitForUser("Set the image and label the whole IUE. Then outline L1, L2/3 and L4 within it");
 
roiManager("Show All");
roiManager("Show None");
 
//The game is on
run("Duplicate...", "duplicate");
title=getTitle();
run("Split Channels");
selectWindow("C2-"+title);
run("Close");
selectWindow("C1-"+title);
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
roiManager("Select",newArray(1,2,3));
roiManager("Combine");
run("Clear Outside");
roiManager("Select",0);
run("Clear Outside");
 
//Rename ROIs
function renLayers(layer,name) {
	roiManager("Select",layer);
	roiManager("Rename",name);
}
 
renLayers(0,"IUE");
renLayers(1,"L1");
renLayers(2,"L2/3");
renLayers(3,"L4");
 
//Count INs/layer
function INs_layer(layer,b,c,name) {	
	selectWindow("Processed")
	roiManager("Show None");
	roiManager("Show All");
	run("Duplicate...","Processed");
	roiManager("Select",layer);
	run("Analyze Particles...","size=70-800 circularity=0.2-1 show=Outlines display summarize add in_situ");
 
		//rename rois with the layer and number of IN
		bproi = roiManager("count");
		roiname=name+"-";
		for (i=c;i<bproi;i++){
     	   roiManager("select", i);
     	   roiManager("rename",roiname+i-7);
		}
 
		//Label the layer in the Summary table			
		selectWindow("Summary");
		for (i = b; i < b+1; i++) {
		Table.set("Total Area", i, name);
		}
}
 
INs_layer(1,0,4,"L1");
INs_layer(2,1,4+nResults,"L2/3");
INs_layer(3,2,4+nResults,"L4");
 
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
 
//Re-count after adjustment
function findRoisWithName(roiName) { 
	nR = roiManager("Count"); 
	roiIdx = newArray(nR); 
	k=0; 
	clippedIdx = newArray(0); 
	 
	for (i=0; i<nR; i++) { 
		roiManager("Select", i); 
		rName = Roi.getName(); 
		if (matches(rName, roiName) ) { 
			roiIdx[k] = i; 
			k++; 
		} 
	} 
	if (k>0) { 
		clippedIdx = Array.trim(roiIdx,k);
		Positions=Array.print(clippedIdx); 
	}
	print(k);
//	return Positions;
} 
 
//To obtain ROI names CONTAINING your search use ".*name.*"
findRoisWithName(".*L1-.*");
findRoisWithName(".*L2/3-.*");
findRoisWithName(".*L4-.*");
 
 
//Close all windows
waitForUser("When you finish, press OK to close all");
run("Close All");