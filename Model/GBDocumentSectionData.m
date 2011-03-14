//
//  GBDocumentSectionData.m
//  appledoc
//
//  Created by Amy Worrall on 14/03/2011.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBDocumentSectionData.h"
#import "GBComment.h"

@implementation GBDocumentSectionData

@synthesize nameOfDocumentSection, humanReadableNameOfDocumentSection, subsections;

- (void)logContents
{
	NSLog(@"Section %@ contents: %@", self.nameOfDocumentSection, self.comment.stringValue);
	for (GBDocumentSectionData *d in self.subsections)
	{
		[d logContents];
	}
}


@end
