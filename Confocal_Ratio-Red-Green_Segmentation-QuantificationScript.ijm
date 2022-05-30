print("\\Clear");

//	This script has been made with the help of Nicholas Condon's script Generator

//	MIT License
//	Copyright (c) 2022 Nicholas Condon , n.condon@uq.edu.au
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
scripttitle= "Red & Green Analysis";
version= "1.3";
date= "10-03-2021";
description= "This script takes dual colour confocal images (.lif/.oir) and processes them for measuring the red/green intensity ratio of regions around nerve tubes putting the results into a single spreadsheet.";
showMessage("ImageJ Script Information Box", "<html>
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
print("By Nicholas Condon (2022) n.condon@uq.edu.au")
print("");
getDateAndTime(year, month, week, day, hour, min, sec, msec);
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print("");

//Directory Warning and Instruction panel     
Dialog.create("Choosing your working directory.");
 	Dialog.addMessage("Use the next window to navigate to the directory of your images.");
  	Dialog.addMessage("(Note a sub-directory will be made called 'Results' within this folder) ");
  	Dialog.addMessage("Take note of your file extension (eg .tif, .czi)");
 	Dialog.show(); 
 

//User selection of directory location
run("Clear Results");
roiManager("Reset");
path = getDirectory("Choose Source Directory ");
list = getFileList(path);
print("Working location: "+path);


//file extension and batch mode selector
ext = ".oir";
  Dialog.create("Choosing your settings");
  	Dialog.addString("File Extension:", ext);
 	Dialog.addMessage("(For example .czi  .lsm  .nd2  .lif  .ims)");
  	Dialog.addCheckbox("Run in batch mode (Background)", true);
  	Dialog.show();
  	ext = Dialog.getString();
	batch=Dialog.getCheckbox();
	print("Chosen file extension: "+ext);
	start = getTime();


//batch mode conditional run
if (batch==1){
	setBatchMode(true);
	print("Running In batch mode.");
	}


//creating results directory + .xls file
print("");
getDateAndTime(year, month, week, day, hour, min, sec, msec);	//Getting date and time info
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
start = getTime();												//starts the script timer

imageNum = 0;

print("");
//resultsDir = path+"Results/";									//Defining the location and name of the results directory
resultsDir = path+"Results_"+year+"-"+(month+1)+"-"+day+"__"+hour+"."+min+"."+sec+"/";
File.makeDirectory(resultsDir);									//making an output folder at the defined location

summaryFile = File.open(resultsDir+"Results_"+year+"-"+(month+1)+"-"+day+"__"+hour+"."+min+"."+sec+".xls");
print(summaryFile,"Filename \t Image# \t Total Area of Holes \t % Area of Holes \t Background Ratio \t Hole # \t Hole Area \t green Intensity \t red Intensity \t Calculated ratio");



//Main Loop, opens each file individually in the list.
for (z=0; z<list.length; z++) {
//confirms only files being opened contain the chosen extension (ext) (change to any other format if required)
if (endsWith(list[z],ext)){
 	print("Opening File "+(z+1)+" of "+list.length+" total files");
 	open(path+list[z]);

roiManager("Reset");
run("Clear Results");
	imageNum = imageNum + 1;

windowtitle = getTitle();
windowtitlenoext = replace(windowtitle, ext, "");
print("Filename = "+windowtitle);

getDimensions(width, height, channels, slices, frames);
imageA = width*height;

run("Duplicate...", "duplicate channels=1");
rename("green");

selectWindow(windowtitle);
run("Duplicate...", "duplicate channels=2");
rename("red");

selectWindow(windowtitle);
run("Duplicate...", "duplicate channels=2");
rename("redThresh");
setAutoThreshold("Minimum dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Invert");

run("Analyze Particles...", "size=2-Infinity show=Masks summarize add");

IJ.renameResults("Summary","Results");
TotNumHoles = getResult("Count", 0);
print("Total Number of Holes Detected = "+TotNumHoles);
TotAreaHoles = getResult("Total Area",0);
print("Total Area of Holes Detected = "+TotAreaHoles+" um^2");
PcAreaHoles = getResult("%Area",0);
print("Percentage Area of Holes Detected = "+PcAreaHoles+"%");
run("Clear Results");
roiManager("Save", resultsDir+ windowtitlenoext + "_holes.zip");			//Saving ROI outputs from holes selection
print("Saving Holes ROI list");
n = roiManager("count");
holeA = newArray(n);
		
	for (rep = 0; rep<TotNumHoles; rep++){
		roiManager("Select", rep);
		run("Measure");
		holeA[rep] = getResult("Area",rep);
		run("Make Band...", "band=0.5");
		roiManager("update");
		}
		
roiManager("Save", resultsDir+ windowtitlenoext + "_bands.zip");			//Saving ROI outputs from bands selection
print("Saving Bands ROI list");

run("Clear Results");
selectWindow("green");
greenA = newArray(n);
		
	for (f=0; f<n; f++) {
    	roiManager("select", f);
		run("Measure");
		greenA[f] = getResult("Mean",f);
        }

selectWindow("red");
run("Clear Results");
redA = newArray(n);
		
	for (f=0; f<n; f++) {
    	roiManager("select", f);
		run("Measure");
		redA[f] = getResult("Mean",f);
        }  


selectWindow("Mask of redThresh");
run("Invert");
roiManager("Show None");
run("Subtract...", "value=254");
imageCalculator("Multiply create stack", windowtitle,"Mask of redThresh");
rename("masked");
run("Split Channels");
imageCalculator("Divide create 32-bit", "C2-masked","C1-masked");
run("Fire");
setMinAndMax(0, 10);
rename("ratioImage");
run("Clear Results");
run("Select All");
run("Measure");
ratio = getResult("Mean", 0);

	for (j=0 ; j<n ; j++) {  
    	holecount = j;
    	holeArea = holeA[j];
    	greenInt = greenA[j];
    	redInt = redA[j];
    	calcR = redInt/greenInt; 		
    	print(summaryFile,windowtitle+"\t"+imageNum+"\t"+TotAreaHoles+"\t"+PcAreaHoles+"\t"+ratio+"\t"+holecount+"\t"+holeArea+"\t"+greenInt+"\t"+redInt+"\t"+calcR);
  		}

selectWindow("ratioImage");
saveAs("tiff", resultsDir+windowtitlenoext+"_ratioImage.tif");
close();
selectWindow("redThresh");
saveAs("tiff", resultsDir+windowtitlenoext+"_Mask.tif");
close();
while (nImages>0){close();}
print("All outputs saved and closed");
print("");
}}

print("Batch Completed");													//Log window stats
print("Total Runtime was:");
print((getTime()-start)/1000); 


selectWindow("Log");														//Saves the log window
saveAs("Text", resultsDir+"Log.txt");

title = "Batch Completed";													//Termination warning (batch ended)
msg = "Put down that coffee! Your job is finished";
waitForUser(title, msg);  

//end of script

