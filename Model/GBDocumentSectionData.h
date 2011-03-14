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


@interface GBDocumentSectionData : GBModelBase <GBObjectDataProviding> {

}

@property(retain) NSString *nameOfDocumentSection;
@property(retain) NSString *humanReadableNameOfDocumentSection;

@property(retain) NSMutableArray *subsections;

@end
