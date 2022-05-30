print("\\Clear")
//	MIT License

//	Copyright (c) 2018 Nicholas Condon n.condon@uq.edu.au

//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:

//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.

//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

scripttitle="EM Tooth Analysis";
version="0.5";
date="16/03/2019";
description="Measures image details of EM tooth micrographs. <br> Counts the number of Halos & Black dots, total and % area of Halos and black dots as well as mean grey (everywhere else) intensity"
    showMessage("Institute for Molecular Biosciences ImageJ Script", "<html>" 
    +"<h1><font size=6 color=Teal>ACRF: Cancer Biology Imaging Facility</h1>
    +"<h1><font size=5 color=Purple><i>The University of Queensland</i></h1>
    +"<h4><a href=http://imb.uq.edu.au/Microscopy/>ACRF: Cancer Biology Imaging Facility</a><\h4>"
    +"<h1><font color=black>ImageJ Script Macro: "+scripttitle+"</h1> "
    +"<p1>Version: "+version+" ("+date+")</p1>"
    +"<H2><font size=3>Created by Nicholas Condon</H2>"	
    +"<p1><font size=2> contact n.condon@uq.edu.au \n </p1>" 
    +"<P4><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a><\h4> </P4>"
    +"<h3>   <\h3>"    
    +"<p1><font size=3 \b i>"+description+".</p1>"
   	+"<h1><font size=2> </h1>"  
	+"<h0><font size=5> </h0>"
    +"");


//Writes to log window script title and acknowledgement
print("");
print("FIJI Macro: "+scripttitle);
print("Version: "+version+" Version Date: "+date);
print("ACRF: Cancer Biology Imaging Facility");
print("By Nicholas Condon (2018) n.condon@uq.edu.au")
print("");
getDateAndTime(year, month, week, day, hour, min, sec, msec);
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print("");



//Directory Location
path = getDirectory("Choose Source Directory ");
list = getFileList(path);
getDateAndTime(year, month, week, day, hour, min, sec, msec);
start = getTime();
ext = ".tif";

//Creates Directory for output images/logs/results table
resultsDir = path+"_Results_"+"_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+"/";
File.makeDirectory(resultsDir);
print("Working Directory Location: "+path);

//This generates csv file and creates the titles for each column
summaryFile = File.open(resultsDir+"Results_"+"_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+".xls");
print(summaryFile,"Image\t Image Number \t FOV Area \t Number of Halos \t Total Halo Area \t %Halo Area \t Mean Halo Intensity \t Number of black objects \t Total black area \t %Black area \t Grey Mean intensity");

run("Clear Results");
roiManager("reset");
run("Set Measurements...", "area mean standard min centroid center median display redirect=None decimal=3");

//This is the first level loop, if more than one file continue until all files are completed. 
for (i=0; i<list.length; i++) {
	if (endsWith(list[i],ext)){
  		open(path+list[i]);
		print("");


	//Gets filename and shortens extension from the file name	
	windowtitle = getTitle();
  	windowtitlenoext = replace(windowtitle, ext, "");
  	print("Opening File: "+(i+1)+" of "+list.length+"  Filename: "+windowtitle);
run("Clear Results");

run("Set Scale...", "distance=184 known=5 pixel=1 unit=micron");
getDimensions(width, height, channels, slices, frames);
makeRectangle(0, 0, width, (width/1.53));		
run("Measure");
FOVarea = getResult("Area", 0);
print("FOV Area = "+FOVarea);
run("8-bit");
run("Duplicate...", "title=Greymean");
run("Duplicate...", "title=Cropped");
run("Median...", "radius=2");
run("Duplicate...", "title=Blacks");


selectWindow("Cropped");
setAutoThreshold("Shanbhag");
//setThreshold(0, 197);
run("Convert to Mask");



//run("Make Binary");
run("Grays");

run("Analyze Particles...", "size=0.125-Infinity show=Masks display exclude clear summarize add");
rename("halomask");

selectWindow("Summary");
IJ.renameResults("Summary","Results");
halocount = getResult("Count",0);
halototalarea = getResult("Total Area",0);
halopcarea = getResult("%Area",0);
print("Halo Count = "+halocount);
print("Halo total area ="+halototalarea);
print("Halo % Area = "+halopcarea);

selectWindow("Greymean");
roiManager("Measure");
run("Summarize");
meanIns = getResult("Mean", (nResults -4));
print("Mean Intensity Halo = "+meanIns);

roiManager("Save", resultsDir+ windowtitlenoext + "_Halo_RoiSet.zip");
roiManager("Reset");
run("Clear Results");


selectWindow("Blacks");
run("Subtract Background...", "rolling=100 light");
setAutoThreshold("Minimum");
//setThreshold(0, 38);
run("Convert to Mask");
run("Fill Holes");
run("Analyze Particles...", "size=0.05-Infinity show=Masks display exclude clear summarize add");
rename("Blacks-mask");


selectWindow("Summary");
IJ.renameResults("Summary","Results");
blackcount = getResult("Count",0);
blacktotalarea = getResult("Total Area",0);
blackpcarea = getResult("%Area",0);
print("Black Count = "+blackcount);
print("Black total area ="+blacktotalarea);
print("Black % Area = "+blackpcarea);

roiManager("Save", resultsDir+ windowtitlenoext + "_black_RoiSet.zip");
roiManager("Reset");
run("Clear Results");


imageCalculator("Add create", "halomask","Blacks-mask");
setOption("BlackBackground", false);
run("Dilate");
run("Close-");
run("Fill Holes");
rename("grey-mask");

run("Create Selection");
run("Make Inverse");
roiManager("Add");
selectWindow("Greymean");

run("Measure");
greymean = getResult("Mean", 0);
roiManager("Save", resultsDir+ windowtitlenoext + "_greyarea_RoiSet.zip");
roiManager("Reset");
for (j=0 ; j<nResults ; j++) {  
    		
    		
    		print(summaryFile,windowtitlenoext+"\t"+(i+1)+"\t"+FOVarea+"\t"+halocount+"\t"+halototalarea+"\t"+halopcarea+"\t"+meanIns+"\t"+blackcount+"\t"+blacktotalarea+"\t"+blackpcarea+"\t"+greymean);
  	   		} 
selectWindow("grey-mask");
saveAs("Tiff", resultsDir+ windowtitlenoext + "Mask-grey.tif");
selectWindow("halomask");
saveAs("Tiff", resultsDir+ windowtitlenoext + "Mask-halos.tif");
selectWindow("Blacks-mask");
saveAs("Tiff", resultsDir+ windowtitlenoext + "Mask-blacks.tif");

	while (nImages>0) { 
		selectImage(nImages); 
        close(); 
      	} 

	}}


print("");
print("Batch Completed");
print("Total Runtime was:");
print((getTime()-start)/1000); 
	
selectWindow("Log");
saveAs("Text", resultsDir+"Log.txt");

//exit message to notify user that the script has finished.
title = "Batch Completed";
msg = "Put down that coffee! Your analysis is finished";
waitForUser(title, msg);  
