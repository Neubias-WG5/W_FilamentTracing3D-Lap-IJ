// Author: Sébastien Tosi (IRB Barcelona)
// Version: 1.0
// Date: 18/12/2019

// Path to input and output images
inputDir = "/dockershare/667/in/";
outputDir = "/dockershare/667/out/";

// Functional parameters
scale = 1;
thr = 5;

arg = getArgument();
parts = split(arg, ",");

setBatchMode(true);

for(i=0; i<parts.length; i++) {
	nameAndValue = split(parts[i], "=");
	if (indexOf(nameAndValue[0], "input")>-1) inputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "output")>-1) outputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "scale")>-1) scale=nameAndValue[1];
	if (indexOf(nameAndValue[0], "thr")>-1) thr=nameAndValue[1];
}

images = getFileList(inputDir);

for(i=0; i<images.length; i++) {
	image = images[i];
	if (endsWith(image, ".tif")) {
		// Workflow
		open(inputDir + "/" + image);
		run("Tubeness", "sigma="+d2s(scale,2));
		run("Maximum 3D...", "x=2 y=2 z=2");
		run("Minimum 3D...", "x=2 y=2 z=2");
		Stack.getStatistics(voxelCount, mean, min, max);
		setThreshold(thr, max);
		setOption("BlackBackground", false);
		run("Convert to Mask", "method=Default background=Light");
		run("Skeletonize (2D/3D)");
		run("Invert LUT");
		// Save output image
		save(outputDir + "/" + image);		
		// Cleanup
		run("Close All");
	}
}

run("Quit");
