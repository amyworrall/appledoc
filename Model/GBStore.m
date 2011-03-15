//
//  GBStore.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBStore.h"

@implementation GBStore

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		_classes = [[NSMutableSet alloc] init];
		_classesByName = [[NSMutableDictionary alloc] init];
		_categories = [[NSMutableSet alloc] init];
		_categoriesByName = [[NSMutableDictionary alloc] init];
		_protocols = [[NSMutableSet alloc] init];
		_protocolsByName = [[NSMutableDictionary alloc] init];
		_documents = [[NSMutableSet alloc] init];
		_documentsByName = [[NSMutableDictionary alloc] init];
		_documentSections = [[NSMutableSet alloc] init];
		_documentSectionsByName = [[NSMutableDictionary alloc] init];
		_customDocuments = [[NSMutableSet alloc] init];
		_customDocumentsByKey = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Overriden methods

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"%@{ %u classes, %u categories, %u protocols }", [self className], [self.classes count], [self.categories count], [self.protocols count]];
}

#pragma mark Helper methods

- (NSArray *)classesSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"nameOfClass" ascending:YES]];
	return [[self.classes allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)categoriesSortedByName {
	NSSortDescriptor *classNameDescription = [NSSortDescriptor sortDescriptorWithKey:@"nameOfClass" ascending:YES];
	NSSortDescriptor *categoryNameDescription = [NSSortDescriptor sortDescriptorWithKey:@"categoryName" ascending:YES];
	NSArray *descriptors = [NSArray arrayWithObjects:classNameDescription, categoryNameDescription, nil];
	return [[self.categories allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSArray *)protocolsSortedByName {
	NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"protocolName" ascending:YES]];
	return [[self.protocols allObjects] sortedArrayUsingDescriptors:descriptors];
}

#pragma mark Registration handling

- (void)registerClass:(GBClassData *)class {
	NSParameterAssert(class != nil);
	GBLogDebug(@"%Registering class %@...", class);
	if ([_classes containsObject:class]) return;
	GBClassData *existingClass = [_classesByName objectForKey:class.nameOfClass];
	if (existingClass) {
		[existingClass mergeDataFromObject:class];
		return;
	}
	[_classes addObject:class];
	[_classesByName setObject:class forKey:class.nameOfClass];
}

- (void)registerCategory:(GBCategoryData *)category {
	NSParameterAssert(category != nil);
	GBLogDebug(@"Registering category %@...", category);
	if ([_categories containsObject:category]) return;
	NSString *categoryID = [NSString stringWithFormat:@"%@(%@)", category.nameOfClass, category.nameOfCategory ? category.nameOfCategory : @""];
	GBCategoryData *existingCategory = [_categoriesByName objectForKey:categoryID];
	if (existingCategory) {
		[existingCategory mergeDataFromObject:category];
		return;
	}
	[_categories addObject:category];
	[_categoriesByName setObject:category forKey:categoryID];
}

- (void)registerProtocol:(GBProtocolData *)protocol {
	NSParameterAssert(protocol != nil);
	GBLogDebug(@"Registering class %@...", protocol);
	if ([_protocols containsObject:protocol]) return;
	GBProtocolData *existingProtocol = [_protocolsByName objectForKey:protocol.nameOfProtocol];
	if (existingProtocol) {
		[existingProtocol mergeDataFromObject:protocol];
		return;
	}
	[_protocols addObject:protocol];
	[_protocolsByName setObject:protocol forKey:protocol.nameOfProtocol];
}

- (void)registerDocument:(GBDocumentData *)document {
	NSParameterAssert(document != nil);
	GBLogDebug(@"Registering document %@...", document);
	if ([_documents containsObject:document]) return;
	NSString *name = [document.nameOfDocument stringByDeletingPathExtension];
	GBDocumentData *existingDocument = [_documentsByName objectForKey:name];
	if (existingDocument) {
		[NSException raise:@"Document with name %@ is already registered!", name];
		return;
	}
	[_documents addObject:document];
	[_documentsByName setObject:document forKey:name];
	[_documentsByName setObject:document forKey:[name stringByReplacingOccurrencesOfString:@"-template" withString:@""]];
}


- (void)registerDocumentSection:(GBDocumentSectionData *)section;
{
	NSParameterAssert(section != nil);
	GBLogDebug(@"Registering document section %@...", section);
	if ([_documentSections containsObject:section]) return;
	NSString *name = section.nameOfDocumentSection;
	
	GBDocumentSectionData *existingSection = [_documentSectionsByName objectForKey:name];
	if (existingSection) {
		[NSException raise:@"Section with name %@ is already registered!", name];
		return;
	}
	[_documentSections addObject:section];
	[_documentSectionsByName setObject:section forKey:name];
	
}

- (void)registerCustomDocument:(GBDocumentData *)document withKey:(id)key {
	NSParameterAssert(document != nil);
	GBLogDebug(@"Registering custom document %@...", document);
	[_customDocuments addObject:document];
	[_customDocumentsByKey setObject:document forKey:key];
}

- (void)unregisterTopLevelObject:(id)object {
	if ([_classes containsObject:object]) {
		[_classes removeObject:object];
		[_classesByName removeObjectForKey:[object nameOfClass]];
		return;
	}
	if ([_categories containsObject:object]) {
		[_categories removeObject:object];
		[_categoriesByName removeObjectForKey:[object idOfCategory]];
		return;
	}
	if ([_protocols containsObject:object]) {
		[_protocols removeObject:object];
		[_protocolsByName removeObjectForKey:[object nameOfProtocol]];
		return;
	}
}

#pragma mark Data providing

- (GBClassData *)classWithName:(NSString *)name {
	return [_classesByName objectForKey:name];
}

- (GBCategoryData *)categoryWithName:(NSString *)name {
	return [_categoriesByName objectForKey:name];
}

- (GBProtocolData *)protocolWithName:(NSString *)name {
	return [_protocolsByName objectForKey:name];
}

- (GBDocumentData *)documentWithName:(NSString *)path {
	return [_documentsByName objectForKey:path];
}

- (GBDocumentData *)customDocumentWithKey:(id)key {
	return [_customDocumentsByKey objectForKey:key];
}

@synthesize classes = _classes;
@synthesize categories = _categories;
@synthesize protocols = _protocols;
@synthesize documents = _documents;
@synthesize documentSections = _documentSections;
@synthesize customDocuments = _customDocuments;

@end
