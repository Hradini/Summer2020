/* Goal of the macro : Given a time series of nuclei, extracting parameters for futher analysis
 Saves RoiSets with the cell boundary for each time point
 Saves .csv file with measurements of parameters for each movie
 */

/*
 * Closes results and roi manager if open
 */
function closeROIandResults() { 
	if(isOpen("ROI Manager")){
		selectWindow("ROI Manager");
		run("Close");
	}
	if(isOpen("Results")) {
		selectWindow("Results");
		run("Close");
	}
}

 /*
  * Generates an image with only the dividing nucleus.
  * Uses plugin Find Connected Regions (effectively 3D flood fill) 
  * Needs a point selection in ROI Manager to be open before calling the function
  */
function fcr(input, output, filename) {
		open(input + filename);
		roiManager("Select", 0);
		newfilename = replace(filename, "Object Predictions", "OO");
		run("Find Connected Regions", "allow_diagonal display_image_for_each start_from_point regions_for_values_over=0 minimum_number_of_points=1 stop_after=1");
		saveAs("Tiff", output + newfilename);
		close();
		run("Close");
	}
/*
 * Uses Analyse particles select the nucleus in each slice
 * Saves the ROIs generated as .zip file
 * Saves the measurements for all the ROIs as .csv file
 */
function ap(input, output, output2, filename ) { 
		open(input + filename);
		run("Invert", "stack");
		run("Analyze Particles...", "display add stack");
		name = replace(filename, "\\.tif", "\\.csv");
		saveAs("Results", output + name);
		roiname = replace(filename, "\\.tif", "\\.zip");
		roiManager("Save", output2 + roiname);
		selectWindow("Results");
		run("Close");
		roiManager("reset"); // Using reset instead of closing because ROI manager window is hidden in batch mode
		close();		
	}



//input and output folders
input = "E:/Summer 2020/Nuclear Shape/wt_40s_obj_pred/";
only_object = "E:/Summer 2020/Nuclear Shape/Only_obj/"; //source for images with only dividing nucleus
measuredp = "E:/Summer 2020/Nuclear Shape/Measurements/"; 
roi_list = "E:/Summer 2020/Nuclear Shape/RoiSets/";

// Main Code

open("E:/Summer 2020/Nuclear Shape/Centre of crop.roi"); // Point selection for user defined fcr function
roiManager("Add");
close();
run("Set Measurements...", "mean redirect=None decimal=3");
setBatchMode(true);
/*
// Runs user defined function fcr for all movies in given directory
list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		open(input + list[i]);
//		print(i);
		roiManager("Select", 0);
		roiManager("Measure");
//		print("measured");
		mgv = getResult("Mean", 0);
		if(mgv < 2){
			print("image does not satisfy criteria");
			close("*");
			run("Clear Results");
		}
		if(mgv >= 2){
			fcr(input, only_object, list[i]);
//			print(mgv);
			close("*");
		}
	}
*/
closeROIandResults();



//Runs user defined function ap for all movies in given directory
run("Set Measurements...", "area fit shape stack display redirect=None decimal=3");
list = getFileList(only_object);
	for (i = 0; i < list.length; i++) {
		ap(only_object, measuredp, roi_list, list[i]);
//		closeROIandResults();
	}

