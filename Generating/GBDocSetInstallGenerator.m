//
//  GBDocSetInstallGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 18.1.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBStore.h"
#import "GBTask.h"
#import "GBDocSetInstallGenerator.h"

@implementation GBDocSetInstallGenerator

#pragma Generation handling

- (BOOL)generateOutputWithStore:(id)store error:(NSError **)error {
	NSParameterAssert(self.previousGenerator != nil);
	GBLogInfo(@"Installing DocSet...");
	
	// Prepare for run.
	if (![super generateOutputWithStore:store error:error]) return NO;
	
	// Prepare source and destination paths and file names.
	NSString *sourceUserPath = self.inputUserPath;
	NSString *destUserPath = self.outputUserPath;
	NSString *sourcePath = [sourceUserPath stringByStandardizingPath];
	NSString *destPath = [destUserPath stringByStandardizingPath];\
	
	// Create destination directory and move files to it.
	GBLogVerbose(@"Moving DocSet files from '%@' to '%@'...", sourceUserPath, destUserPath);
	if (![self initializeDirectoryAtPath:destUserPath error:error]) {
		GBLogWarn(@"Failed initializing DocSet installation directory '%@'!", destUserPath);
		return NO;
	}
	if (![self copyOrMoveItemFromPath:sourcePath toPath:destPath error:error]) {
		GBLogWarn(@"Failed moving DocSet files from '%@' to '%@'!", sourceUserPath, destUserPath);
		return  NO;
	}
	
	// Prepare AppleScript for loading the documentation into the Xcode.
	GBLogVerbose(@"Installing DocSet to Xcode...");
	NSMutableString* installScript  = [NSMutableString string];
	[installScript appendString:@"tell application \"Xcode\"\n"];
	[installScript appendFormat:@"\tload documentation set with path \"%@\"\n", destPath];
	[installScript appendString:@"end tell"];
	
	// Run the AppleScript for loading the documentation into the Xcode.
	NSDictionary* errorDict = nil;
	NSAppleScript* script = [[NSAppleScript alloc] initWithSource:installScript];
	if (![script executeAndReturnError:&errorDict])
	{
		NSString *message = [errorDict objectForKey:NSAppleScriptErrorMessage];
		if (error) *error = [NSError errorWithCode:GBErrorDocSetXcodeReloadFailed description:@"Documentation set was installed, but couldn't reload documentation within Xcode." reason:message];
		return NO;
	}
	return YES;
}

#pragma mark Overriden methods

- (NSString *)outputUserPath {
	// Note that we use custom location, so can't rely on default implementation using outputSubpath!
	return [self.settings.docsetInstallPath stringByAppendingPathComponent:self.settings.docsetBundleFilename];
}

@end
