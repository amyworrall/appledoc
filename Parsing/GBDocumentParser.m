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


@implementation GBDocumentParser

@synthesize settingsProvider;


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
	GBDocumentData *document = [GBDocumentData documentDataWithContents:contents path:path];
	document.basePathOfDocument = basePath;
	[store registerDocument:document];
}

@end
