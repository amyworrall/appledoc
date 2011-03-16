//
//  GBDocumentSectionData.h
//  appledoc
//
//  Created by Amy Worrall on 14/03/2011.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GBModelBase.h"
#import "GBObjectDataProviding.h"

@class GBDocumentData;

@interface GBDocumentSectionData : GBModelBase <GBObjectDataProviding> {
@private
	GBAdoptedProtocolsProvider *_adoptedProtocols;
	GBMethodsProvider *_methods;
}

/// The short name of the section. At the moment only used to generate anchor links, but in the future will hopefully be used for crossreferencing.
@property(retain) NSString *nameOfDocumentSection;

/// The long name of the section. This is what is displayed in the output.
@property(retain) NSString *humanReadableNameOfDocumentSection;

/// An array of GBDocumentSectionData objects.
@property(retain) NSMutableArray *subsections;

/// Returns `[NSNumber numberWithBool:YES]` if there is at least one subsection.
- (NSNumber*)hasSubsections;

/// The document the section is linked to
@property(retain) GBDocumentData *document;

/// So that the cross ref thing knows it's a section
- (BOOL)isDocumentSection;

@end
