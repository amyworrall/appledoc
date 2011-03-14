//
//  GBDocumentParser.h
//  appledoc
//
//  Created by Amy Worrall on 14/03/2011.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GBApplicationSettingsProvider;
@class GBStore;

@interface GBDocumentParser : NSObject {

}

@property (retain)GBApplicationSettingsProvider *settingsProvider;


+ (GBDocumentParser*)parserWithSettingsProvider:(GBApplicationSettingsProvider*)aSettingsProvider;
- (id)initWithSettingsProvider:(GBApplicationSettingsProvider*)aSettingsProvider;
- (void)parseDocumentFromString:(NSString*)contents path:(NSString*)path basePath:(NSString*)basePath toStore:(GBStore*)store;

@end
