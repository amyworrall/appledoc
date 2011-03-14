//
//  GBDocumentData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 10.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBDocumentData.h"
#import "GBDocumentSectionData.h"

@implementation GBDocumentData

#pragma mark Initialization & disposal

+ (id)documentDataWithContents:(NSString *)contents path:(NSString *)path {
	return [[[self alloc] initWithContents:contents path:path] autorelease];
}

+ (id)documentDataWithContents:(NSString *)contents path:(NSString *)path basePath:(NSString *)basePath {
	id result = [self documentDataWithContents:contents path:path];
	[result setBasePathOfDocument:basePath];
	return result;
}

- (id)initWithContents:(NSString *)contents path:(NSString *)path {
	NSParameterAssert(contents != nil);
	GBLogDebug(@"Initializing document with contents %@...", [contents normalizedDescription]);
	self = [super init];
	if (self) {
		GBSourceInfo *info = [GBSourceInfo infoWithFilename:[path lastPathComponent] lineNumber:1];
		[self registerSourceInfo:info];
		self.nameOfDocument = [path lastPathComponent];
		self.pathOfDocument = path;
		self.basePathOfDocument = @"";
		self.comment = [GBComment commentWithStringValue:contents];
		self.comment.sourceInfo = info;
		_adoptedProtocols = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
		_methods = [[GBMethodsProvider alloc] initWithParentObject:self];
		
		self.sections = [NSMutableArray array];
	}
	return self;
}


// For initing with new document parser, which needs to create object before knowing contents.
// ... or should I just allow contents to be nil in the other initialiser?
- (id)initWithPath:(NSString*)path
{
	self = [super init];
	if (self) {
		GBSourceInfo *info = [GBSourceInfo infoWithFilename:[path lastPathComponent] lineNumber:1];
		[self registerSourceInfo:info];
		self.nameOfDocument = [path lastPathComponent];
		self.pathOfDocument = path;
		self.basePathOfDocument = @"";
		self.comment = [[[GBComment alloc] init] autorelease];
		self.comment.sourceInfo = info;
		_adoptedProtocols = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
		_methods = [[GBMethodsProvider alloc] initWithParentObject:self];
		
		self.sections = [NSMutableArray array];
	}
	return self;
}

#pragma mark Overriden methods

- (NSString *)description {
	return self.nameOfDocument;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"document %@", self.nameOfDocument];
}

- (BOOL)isStaticDocument {
	return YES;
}

#pragma mark Properties

- (NSString *)subpathOfDocument {
	NSString *result = [self.pathOfDocument stringByReplacingOccurrencesOfString:self.basePathOfDocument withString:@""];
	if ([result hasPrefix:@"/"]) result = [result substringFromIndex:1];
	return result;
}

@synthesize isCustomDocument;
@synthesize nameOfDocument;
@synthesize pathOfDocument;
@synthesize basePathOfDocument;
@synthesize adoptedProtocols = _adoptedProtocols;
@synthesize methods = _methods;
@synthesize sections;
@synthesize humanReadableNameOfDocument;


@end
