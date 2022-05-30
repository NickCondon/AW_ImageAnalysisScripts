print("\\Clear");
//	MIT License
//	Copyright (c) 2020 Nicholas Condon n.condon@uq.edu.au
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
scripttitle= "Arosha-Script_Herovici";
version= "0.1";
date= "21-08-2020";
description= "Takes Herovici stained images and measures the Blue/Pink/White areas.";
showMessage("Institute for Molecular Biosciences ImageJ Script", "<html>
    +"<h1><font size=6 color=Teal>ACRF: Cancer Biology Imaging Facility</h1>
    +"<h1><font size=5 color=Purple><i>The University of Queensland</i></h1>
    +"<h4><a href=http://imb.uq.edu.au/Microscopy/>ACRF: Cancer Biology Imaging Facility</a><h4>
    +"<h1><font color=black>ImageJ Script Macro: "+scripttitle+"</h1> 
    +"<p1>Version: "+version+" ("+date+")</p1>"
    +"<H2><font size=3>Created by Nicholas Condon</H2>"
    +"<p1><font size=2> contact n.condon@uq.edu.au \n </p1>" 
    +"<P4><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a><h4> </P4>"
    +"<h3>   <h3>"    
    +"<p1><font size=3  i>"+description+"</p1>
    +"<h1><font size=2> </h1>"  
	   +"<h0><font size=5> </h0>"
    +"");
print("");
print("FIJI Macro: "+scripttitle);
print("Version: "+version+" Version Date: "+date);
print("ACRF: Cancer Biology Imaging Facility");
print("By Nicholas Condon (2020) n.condon@uq.edu.au")
print("");
getDateAndTime(year, month, week, day, hour, min, sec, msec);
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print("");

//Directory Warning and Instruction panel     
Dialog.create("Choosing your working directory.");
 	Dialog.addMessage("Use the next window to navigate to the directory of your images.");
  	Dialog.addMessage("(Note a sub-directory will be made within this folder for output files) ");
  	Dialog.addMessage("Take note of your file extension (eg .tif, .czi)");
Dialog.show(); 

//Directory Location
path = getDirectory("Choose Source Directory ");
list = getFileList(path);
getDateAndTime(year, month, week, day, hour, min, sec, msec);

ext = ".tif";
Dialog.create("Settings");
Dialog.addString("File Extension: ", ext);
Dialog.addMessage("(For example .czi  .lsm  .nd2  .lif  .ims)");
Dialog.show();
ext = Dialog.getString();

start = getTime();

//Creates Directory for output images/logs/results table
resultsDir = path+"_Results_"+"_"+year+"-"+(month+1)+"-"+day+"_at_"+hour+"."+min+"/"; 
File.makeDirectory(resultsDir);
print("Working Directory Location: "+path);
summaryFile = File.open(resultsDir+"Results_"+"_"+year+"-"+(month+1)+"-"+day+"_at_"+hour+"."+min+".xls");
print(summaryFile,"Image Name \t Image Number \t Number of Holes Found \t Total Hole Area \t %Hole Area \t Total Blue Area \t %Blue Area \t Total Pink Area \t %Pink Area");


for (z=0; z<list.length; z++) {
if (endsWith(list[z],ext)){

		open(path+list[z]);
		run("Clear Results");
		roiManager("reset");
		windowtitle = getTitle();
		windowtitlenoext = replace(windowtitle, ext, "");
		print("Opening File: "+(z+1)+" of "+list.length+"  Filename: "+windowtitle);



		getDimensions(width, height, channels, slices, frames);
		newImage("Pink", "8-bit white", width, height, 1);
		
		selectWindow(windowtitle);
		run("Duplicate...", "title=Comp");
		run("Make Composite");
		
		
		run("Duplicate...", "duplicate channels=2");
		run("Subtract Background...", "rolling=50");
		setAutoThreshold("Otsu dark");
		run("Convert to Mask");
		run("Watershed");
		run("Analyze Particles...", "size=1-Infinity show=Masks summarize add");
		rename("White");
		IJ.renameResults("Summary","Results");
		TotNumHoles = getResult("Count", 0);
		print("Total Number of Holes Detected = "+TotNumHoles);
		TotAreaHoles = getResult("Total Area",0);
		print("Total Area of Holes Detected = "+TotAreaHoles+" um^2");
		PcAreaHoles = getResult("%Area",0);
		print("Percentage Area of Holes Detected = "+PcAreaHoles+"%");
		run("Clear Results");
		print("");
		roiManager("Save", resultsDir+ windowtitle + "_white_RoiSet.zip");		
		roiManager("reset");
		selectWindow("White");
		run("Invert LUT");
		
		selectWindow("Comp");
		run("Duplicate...", "duplicate channels=3");
		rename("blue1");
		imageCalculator("Subtract create", "blue1","White");
		setAutoThreshold("RenyiEntropy dark");
		run("Convert to Mask");
		rename("Blue2");
		run("Analyze Particles...", "size=0.25-Infinity show=Masks summarize add");
		run("Invert LUT");
		rename("Blue");
		run("Blue");
		

		
		IJ.renameResults("Summary","Results");
		TotBlueArea = getResult("Total Area",0);
		print("Total Area of Blue Detected = "+TotBlueArea+" um^2");
		PcBlueArea = getResult("%Area",0);
		print("Percentage Area of Blue Detected = "+PcBlueArea+"%");
		run("Clear Results");
		print("");
		roiManager("Save", resultsDir+ windowtitle + "_blue_RoiSet.zip");		
		roiManager("reset");
		
		imageCalculator("Subtract", "Pink","White");
		imageCalculator("Subtract", "Pink","Blue");
		run("Magenta");
		run("Select All");
		run("Measure");
		TotPinkArea = (getResult("Mean",0)*getResult("Area", 0))/255;
		print("Total Pink Area = "+TotPinkArea+" um^2");
		PcPinkArea = 100 - (PcBlueArea + PcAreaHoles);
		print("Percentage Area of Pink = "+PcPinkArea+"%");
		print("");
		
	
		run("Merge Channels...", "c3=Blue c4=White c6=Pink create keep");
		rename("Output");
		saveAs("Tiff", resultsDir+ windowtitle + "_Merged.tif");

		while(nImages>0){close();}
	
		print(summaryFile,windowtitle+"\t"+(z+1)+"\t"+TotNumHoles+"\t"+TotAreaHoles+"\t"+PcAreaHoles+"\t"+TotBlueArea+"\t"+PcBlueArea+"\t"+TotPinkArea+"\t"+PcPinkArea);
		



		}}
		selectWindow("Log");
		saveAs("Text", resultsDir+"Log.txt");
//exit message to notify user that the script has finished.
title = "Batch Completed";
msg = "Put down that coffee! Your analysis is finished";
waitForUser(title, msg);
