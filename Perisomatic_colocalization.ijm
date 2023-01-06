/*
  	<The present macro identifies and measures the colocalization of two perisomatic signals
  	around a neuron's soma>
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
//Analyze -> Set Measurements -> Perimeter, Area, Display label

//Hyperstack

//run("Bio-Formats Importer");
//waitForUser("Select the correct image");

//title=getTitle();

//Obtain NeuN ROIs (with considerable size & circularity) and name the cells

saveAs("Tiff", "C:\\Users\\Montecarlo\\Desktop\\Analisis\\Syt2+ E2+_Colocalization_P16\\image-1.tif");
selectWindow("image-1.tif");
run("Duplicate...", "title=image1-1.tif duplicate channels=1");
selectWindow("image1-1.tif");
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
	
		neunroi = roiManager("count");
		for (i=0;i<neunroi;i++){
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
	
		neunroi = roiManager("count");
		for (i=0;i<neunroi;i++){
     		  roiManager("select", i);
     		  roiManager("rename","Cell-"+i+1);
		}


roiManager("Deselect");
roiManager("Show All");
roiManager("Show None");

waitForUser("Combine NeuN ROIs");

//Rename Total NeuN ROI
neunroi = roiManager("count");
roiManager("select", neunroi-1);
roiManager("Rename", "NeuNTotal");
roiManager("Update");

roiManager("Deselect");
roiManager("Show All");
roiManager("Show None");	

waitForUser("Save ROI manager");

//Select all E2 puncta in the image and add them as a ROI

open("C:\\Users\\Montecarlo\\Desktop\\Analisis\\Syt2+ E2+_Colocalization_P16\\image-1.tif");
selectWindow("image-1.tif");
run("Duplicate...", "title=image1-1.tif duplicate channels=3");
selectWindow("image1-1.tif");
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
//run("Invert");
run("adjustable watershed", "tolerance=0.3");
run("Invert");

	//Add E2 puncta as a ROI
	
	run("Create Selection");
	roiManager("Add");
		E2roi = roiManager("count");
		roiManager("select", E2roi-1);
   		roiManager("rename","E2Total");
   		roiManager("deselect");

//Final step: E2puncta/cell

waitForUser("RUN AUTOMATIC COUNTING E2: click 'OK'");

E2roi = roiManager("count");
		for (i=0;i<E2roi-2;i++){
     		  selectWindow("Mask of E2 puncta");
     		  run("Duplicate...", "duplicate");
     		  roiManager("select", i);
     		  run("Enlarge...", "enlarge=-0.1");  
     		  run("Make Band...", "band=0.4");
     		  run("Clear Outside");
     		  run("Invert");
     		  run("Analyze Particles...", "size=0.04-Infinity show=Masks display summarize");
     		  saveAs("Tiff", "C:\\Users\\Montecarlo\\Desktop\\Analisis\\Syt2+ E2+_Colocalization_P16\\E2\\maskcount_E2_NeuN"+(i+1)+".tif");
     		  run("Create Selection");
     		  roiType = selectionType();
     		  if (roiType==-1){
     		  	run("Close");
     		  	}
     		  	roiManager("Add");
     		  	E2roi1 = roiManager("count");
     		  	roiManager("select", E2roi1-1);
     		  	roiManager("rename", "E2PunctaCell-"+i+1);
     		  	close("Tiff", "C:\\Users\\Montecarlo\\Desktop\\Analisis\\Syt2+ E2+_Colocalization_P16\\E2\\maskcount_E2_NeuN"+(i+1)+".tif");
     		  	}
     		  	
waitForUser("Save ROI manager and eliminate E2PunctaCell");
waitForUser("Save Tables");

//End of E2 puncta

//Select all Syt2 puncta in the image and add them as a ROI

open("C:\\Users\\Montecarlo\\Desktop\\Analisis\\Syt2+ E2+_Colocalization_P16\\image-1.tif");
selectWindow("image-1.tif");
run("Duplicate...", "title=image1-1.tif duplicate channels=2");
selectWindow("image1-1.tif");
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
rename("Syt2 puncta");
run("Analyze Particles...", "size=0.05-Infinity circularity=0.00-1.00 show=Masks");
//run("Invert");
run("adjustable watershed", "tolerance=0.3");
run("Invert");

	//Add Syt2 puncta as a ROI
	
	run("Create Selection");
	roiManager("Add");
		Syt2roi = roiManager("count");
		roiManager("select", Syt2roi-1);
   		roiManager("rename","Syt2Total");
   		roiManager("deselect");

//Final step: Syt2puncta/cell

waitForUser("RUN AUTOMATIC COUNTING Syt2: click 'OK'");

nR = roiManager("count");
for (i=0;i<nR-2;i++){
     		  selectWindow("Mask of Syt2 puncta");
     		  run("Duplicate...", "duplicate");
     		  roiManager("select", i);
     		  run("Enlarge...", "enlarge=-0.1");  
     		  run("Make Band...", "band=0.4");
     		  run("Clear Outside");
     		  run("Invert");
     		  run("Analyze Particles...", "size=0.04-Infinity show=Masks display summarize");
     		  saveAs("Tiff", "C:\\Users\\Montecarlo\\Desktop\\Analisis\\Syt2+ E2+_Colocalization_P16\\Syt2\\maskcount_Syt2_NeuN"+(i+1)+".tif");
     		  run("Create Selection");
     		  roiType = selectionType();
     		  if (roiType==-1){
     		  	run("Close");
     		  	}
     		  	roiManager("Add");
     		  	nR1 = roiManager("count");
     		  	roiManager("select", nR1-1);
     		  	roiManager("rename", "Syt2PunctaCell-"+i+1);
     		  	close("Tiff", "C:\\Users\\Montecarlo\\Desktop\\Analisis\\Syt2+ E2+_Colocalization_P16\\Syt2\\maskcount_Syt2_NeuN"+(i+1)+".tif");
     		  	}

waitForUser("Save ROI manager and eliminate Syt2PunctaCell");
waitForUser("Save Tables");

//End of Syt2 puncta

//////////E2+Syt2 Colocalization

File.openSequence("C:/Users/Montecarlo/Desktop/Analisis/Syt2+ E2+_Colocalization_P16/E2/");
saveAs("Tiff", "C:/Users/Montecarlo/Desktop/Analisis/Syt2+ E2+_Colocalization_P16/E2/E2.tif");
File.openSequence("C:/Users/Montecarlo/Desktop/Analisis/Syt2+ E2+_Colocalization_P16/Syt2/");
saveAs("Tiff", "C:/Users/Montecarlo/Desktop/Analisis/Syt2+ E2+_Colocalization_P16/Syt2/Syt2.tif");
run("Merge Channels...", "c3=E2.tif c2=Syt2.tif create");
selectWindow("Composite");
run("Stack to RGB");
run("8-bit");
run("Convert to Mask");
saveAs("Tiff", "C:/Users/Montecarlo/Desktop/Analisis/Syt2+ E2+_Colocalization_P16/E2+Syt2/Composite-1.tif");
number = nSlices();
for (n=1; n<=number; n++) {
	      open("C:/Users/Montecarlo/Desktop/Analisis/Syt2+ E2+_Colocalization_P16/E2+Syt2/Composite-1.tif");
	      selectWindow("Composite-1.tif");
	      Stack.setChannel(1);
	      Stack.setSlice(n);
          run("Analyze Particles...", "size=0.03-Infinity show=Masks display summarize");  
          saveAs("Tiff", "C:/Users/Montecarlo/Desktop/Analisis/Syt2+ E2+_Colocalization_P16/E2+Syt2/maskcount_E2+Syt2_NeuN"+n+".tif");
          run("Create Selection");
     		  roiType = selectionType();
     		  if (roiType==-1){
     		  	run("Close");
     		  	}
     		  	roiManager("Add");
     		  	n1 = roiManager("count");
     		  	roiManager("select", n1-1);
     		  	roiManager("rename", "E2+Syt2PunctaCell-"+i+1);
     		  	close("C:/Users/Montecarlo/Desktop/Analisis/Syt2+ E2+_Colocalization_P16/E2+Syt2/Composite-1.tif");
     		  	}

waitForUser("Save ROI manager");
waitForUser("Save Tables");

close("\\Others");
run("Close All");  		  	

///////////////////////////////////////////////////////END
     		  	