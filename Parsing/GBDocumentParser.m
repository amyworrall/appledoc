//
//  GBDocumentParser.m
//  appledoc
//
//  Created by Amy Worrall on 14/03/2011.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBDocumentParser.h"

#import "GBApplicationSettingsProvider.h"
#import "GBStore.h"
#import "GBDocumentData.h"
#import "GBDocumentSectionData.h"
#import "GBComment.h"


@interface GBDocumentParser ()

@property (retain) NSMutableArray *sectionStack;
@property (retain) NSMutableString *contentBuffer;

- (NSInteger)levelForSectionCommand:(NSString*)command;

@end


@implementation GBDocumentParser

@synthesize settingsProvider;
@synthesize sectionStack, contentBuffer;


+ (GBDocumentParser*)parserWithSettingsProvider:(GBApplicationSettingsProvider*)aSettingsProvider
{
	return [[[GBDocumentParser alloc] initWithSettingsProvider:aSettingsProvider] autorelease];
}


- (id)initWithSettingsProvider:(GBApplicationSettingsProvider*)aSettingsProvider
{
	self = [super init];
	if (self)
	{
		self.settingsProvider = aSettingsProvider;
	}
	return self;
}


- (void)parseDocumentFromString:(NSString*)contents path:(NSString*)path basePath:(NSString*)basePath toStore:(GBStore*)store
{
	
	// read line by line. If section command, manipulate stack, otherwise add to buffer. If end of file or section command, tack buffer onto last section on stack.
	
	//GBDocumentData *document = [GBDocumentData documentDataWithContents:contents path:path];
	//document.basePathOfDocument = basePath;
	//[store registerDocument:document];
	
	self.sectionStack = [NSMutableArray array];
	self.contentBuffer = [NSMutableString string];
	
	GBDocumentData *document = [[GBDocumentData alloc] initWithPath:path];	
	document.basePathOfDocument = basePath;
	
	NSArray *lines = [contents arrayOfLines];
	
	BOOL ignoreLine;
	
	for (NSString *line in lines)
	{
		NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		ignoreLine = NO;
		if ([trimmedLine length]>0 && [[trimmedLine substringToIndex:1] isEqualToString:@"@"])
		{
			NSScanner *scanner = [NSScanner scannerWithString:trimmedLine];
			
			NSString *command = nil;
			NSString *shortName = nil;
			NSString *longName = nil;
			NSString *fullParameters = nil;
			
			[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&command];
			command = [command stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
			fullParameters = [[trimmedLine substringFromIndex:[scanner scanLocation]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			
			[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&shortName];
			longName = [[trimmedLine substringFromIndex:[scanner scanLocation]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			
			// Section commands
			NSInteger level = [self levelForSectionCommand:command];
			if (level != NSNotFound)
			{
				ignoreLine = YES;
				
				// if no sections, put it in the document
				if ([self.sectionStack count] == 0)
				{
					document.comment.stringValue = self.contentBuffer;
					[self.contentBuffer setString:@""];
				}
				else 
				{
					GBComment *comment = [GBComment commentWithStringValue:self.contentBuffer];
					((GBDocumentSectionData*)[self.sectionStack lastObject]).comment = comment;
					[self.contentBuffer setString:@""];
				}
				
				// now to make new section
				
				if (level > [self.sectionStack count]+1)
				{
					NSLog(@"ERROR: malformed template file, tries to make subsection without section (or something)");
				}
				
				NSInteger popDelta = ([self.sectionStack count] - level) + 1; // always need a pop unless increasing level
				
				for (int i=0; i<popDelta; i++)
				{
					// pop section
					[store registerDocumentSection:[self.sectionStack lastObject]];
					[self.sectionStack removeLastObject];
				}
				
				GBDocumentSectionData *section = [[[GBDocumentSectionData alloc] init] autorelease];
				section.nameOfDocumentSection = shortName;
				section.humanReadableNameOfDocumentSection = longName;
				section.document = document;
				if ([self.sectionStack count] == 0)
				{
					[document.sections addObject:section];
				}
				else 
				{
					[[[self.sectionStack lastObject] subsections] addObject:section];
				}
				[self.sectionStack addObject:section];
			}
			else if ([command isEqualToString:@"title"])
			{
				ignoreLine = YES;
				document.humanReadableNameOfDocument = fullParameters;
			}
			
		}
		
		if (ignoreLine == NO)
		{
			// Not a command. Append to buffer.
			[self.contentBuffer appendFormat:@"%@\n", line];
		}
		
	}
	
	if ([self.sectionStack count] == 0)
	{
		document.comment.stringValue = self.contentBuffer;
		[self.contentBuffer setString:@""];
	}
	else 
	{
		GBComment *comment = [GBComment commentWithStringValue:self.contentBuffer];
		((GBDocumentSectionData*)[self.sectionStack lastObject]).comment = comment;
		[self.contentBuffer setString:@""];

		for (GBDocumentSectionData *section in [self.sectionStack copy])
		{
			[store registerDocumentSection:[self.sectionStack lastObject]];
			[self.sectionStack removeLastObject];
		}
	}
	
	[store registerDocument:document];
	
	[document release];
}


#pragma mark -
#pragma mark Helper methods

- (NSInteger)levelForSectionCommand:(NSString*)command
{
	// top level (0) is no section at all
	if ([command isEqualToString:@"section"])
	{
		return 1;
	}
	if ([command isEqualToString:@"subsection"])
	{
		return 2;
	}
	return NSNotFound;
}


@end
