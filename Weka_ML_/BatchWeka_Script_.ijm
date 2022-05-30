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


run("Clear Results");
roiManager("reset");
run("Set Measurements...", "area mean standard min centroid center median display redirect=None decimal=3");

//This is the first level loop, if more than one file continue until all files are completed. 
for (a=0; a<list.length; a++) {
	if (endsWith(list[a],ext)){
  		open(path+list[a]);
		print("");

		//Gets filename and shortens extension from the file name	
		windowtitle = getTitle();
  		windowtitlenoext = replace(windowtitle, ext, "");
  		print("Opening File: "+(a+1)+" of "+list.length+"  Filename: "+windowtitle);
		run("Clear Results");

		run("Trainable Weka Segmentation");
		call("trainableSegmentation.Weka_Segmentation.loadClassifier", "/Users/n.condon/Desktop/classifier.model");
		call("trainableSegmentation.Weka_Segmentation.applyClassifier", path, list[a], "showResults=true", "storeResults=false", "probabilityMaps=false", "");
		rename("ML_Image_"+a+"_"+windowtitle);
		saveAs("Tiff", resultsDir+ windowtitlenoext + "ML_Mask.tif");

	}}
