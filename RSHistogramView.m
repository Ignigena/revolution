//
//  RSHistogramView.m
//
//  Created by Albert Martin on 10/25/08.
//  Copyright 2008 Renovatio Software. All rights reserved.
//

#import "RSHistogramView.h"
#import <Accelerate/Accelerate.h>

@implementation RSHistogramView


+ (void)calculateHistogramFromImage:(NSImage *)image
{
	vImage_Buffer	buffer;
	
	vImagePixelCount *histograms[4];
	
	vImagePixelCount histogramA[256];
    vImagePixelCount histogramR[256];
    vImagePixelCount histogramG[256];
    vImagePixelCount histogramB[256];
	
    // Convert the NSImage to a vImage_Buffer
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData: [image TIFFRepresentation]];
		buffer.data = [imageRep bitmapData];
		buffer.width = [imageRep pixelsWide];
		buffer.height = [imageRep pixelsHigh];
		buffer.rowBytes = [imageRep bytesPerRow];
	
	// Set up the vImage histogram array
	histograms[0] = histogramA;
	histograms[1] = histogramR;
	histograms[2] = histogramG;
	histograms[3] = histogramB;
		
	// Call the vImage function to compute the histograms for the image data
	vImageHistogramCalculation_ARGB8888(&buffer, histograms, 0);
	
	unsigned i;
	unsigned count;
	
	// Reverse the histogram data
    histograms[0] = histogramR;
    histograms[1] = histogramG;
    histograms[2] = histogramB;
    histograms[3] = histogramA;
	
	for(i = 0; i < 256; i++) {
		NSLog(@"RED::%u  --  GREEN::%u  --  BLUE::%u", (unsigned long)(histogramR[i]), (unsigned long)(histogramG[i]), (unsigned long)(histogramB[i]));
		count = count + (unsigned long)(histogramR[i]) + (unsigned long)(histogramG[i]) + (unsigned long)(histogramB[i]);
	}
	
	NSLog(@"%u", count);
}

@end
