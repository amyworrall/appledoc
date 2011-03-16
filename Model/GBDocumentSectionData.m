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

@synthesize nameOfDocumentSection, humanReadableNameOfDocumentSection, subsections, document;
@synthesize adoptedProtocols = _adoptedProtocols;
@synthesize methods = _methods;

- (BOOL)isStaticDocument
{
	return YES;
}

- (BOOL)isDocumentSection
{
	return YES;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		self.subsections = [NSMutableArray array];
	}
	return self;
}

- (NSNumber*)hasSubsections
{
	if ([self.subsections count]>0)
	{
		return [NSNumber numberWithBool:YES];
	}
	return [NSNumber numberWithBool:NO];
}

@end
