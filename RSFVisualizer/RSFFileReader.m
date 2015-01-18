//
//  RSFFileReader.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 13/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "RSFFileReader.h"

@interface RSFFileReader() <NSXMLParserDelegate>
@property (nonatomic, strong) NSData *data;
@property (nonatomic) int idx;
@property (nonatomic, strong) NSMutableArray *vars;
@end

@implementation RSFFileReader

#pragma mark - Search directory for RSF files

-(NSDictionary *)GetRSFFilesInDocumentsDirectory
{
  NSMutableDictionary *r;
  
  NSFileManager *fileMgr = [NSFileManager defaultManager];
  NSArray *documentsURLs = [fileMgr URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
  NSURL *documentURL;

  if ([documentsURLs count]>0) {
    // Read contents of Documents directory
    NSError *errorMsg;
    documentURL = [documentsURLs objectAtIndex:0];
    NSArray *directoryContent = [fileMgr contentsOfDirectoryAtURL:documentURL includingPropertiesForKeys:@[NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:&errorMsg];
    
    if (directoryContent) {
      // Found something
      r = [[NSMutableDictionary alloc] init];
      
      // Collect all RSF-files in a dictionary with key: rsfName, objects are in the form {@"txt" : (NSURL *), @"xml" : (NSURL *)}
      for (NSURL *fileURL in directoryContent) {
        NSString *fileExtension = [fileURL pathExtension];
        if (([fileExtension isEqualToString:@"txt"] || [fileExtension isEqualToString:@"xml"])) {
          NSString *rsfName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
          NSMutableDictionary *rsfObject = [r objectForKey:rsfName];
          if (!rsfObject) {
            rsfObject = [@{fileExtension : fileURL} mutableCopy];
            [r setObject:rsfObject forKey:rsfName];
          } else {
            [rsfObject setObject:fileURL forKey:fileExtension];
          }
        }
      }

      // See which RSF files that have both txt and xml file present in the documents directory
      NSEnumerator *enumerator = [r keyEnumerator];
      id key;
      while ((key = [enumerator nextObject])) {
        NSDictionary *dicObj = (NSDictionary *)[r objectForKey:key];
        NSURL *txtURL = [dicObj objectForKey:@"txt"];
        NSURL *xmlURL = [dicObj objectForKey:@"xml"];
        
        if( !txtURL || !xmlURL ) {
          // Both files not present, remove
          [r removeObjectForKey:key];
        }
      }
    } else {
      NSLog(@"Error reading documents directory\n%@", errorMsg);
    }
  } else {
    NSLog(@"Did not find any document directory!\n");
  }
  
  return r;
}

#pragma mark - Read XML file
-(void)setXmlFilePath:(NSString *)xmlFilePath
{
//  NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:xmlFilePath]];

  NSData *xmlData = [NSData dataWithContentsOfFile:xmlFilePath];
  NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
  parser.delegate = self;
  
  self.vars = [[NSMutableArray alloc] init];
  [parser parse];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                       namespaceURI:(NSString *)namespaceURI
                                      qualifiedName:(NSString *)qName
                                         attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqual:@"DataField"]) {
    [self.vars addObject:[attributeDict objectForKey:@"name"]];
  }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
  self.variableNames = self.vars;
}

#pragma mark - Read txt file
-(void)setRsfFilePath:(NSString *)rsfFilePath
{
  _rsfFilePath = rsfFilePath;
  
  self.data = [NSData dataWithContentsOfFile:rsfFilePath];
  self.idx = 0;
}

#define BUFFERSIZE 200
-(NSString *)readOneLine
{
  char c_str[BUFFERSIZE];
  char *buffer= (char *)[self.data bytes];
  
  int n=0;
  while (self.idx < [self.data length] && buffer[self.idx]!='\n') {
    c_str[n] = buffer[self.idx];
    self.idx++;
    n++;
  }
  if (self.idx > [self.data length] || buffer[self.idx]!='\n')  {
    return nil;
  } else {
    self.idx++;
    c_str[n]='\0';
    return [NSString stringWithCString:c_str encoding:NSASCIIStringEncoding];
  }
}

-(void)skipHeader
{
  [self readOneLine];
}

-(RSFNodeSpec *)readRSFEntry:(IDGenerator *)idGen
{
  NSArray *a = [[self readOneLine] componentsSeparatedByString:@" "];
  if ( [a count] == 6 ) {
    // No treeID nodeID parmID contPT mwcpSZ
    RSFNodeSpec *n = [[RSFNodeSpec alloc] init];
    NSString *s = a[1];
    n.treeID = (int)[s integerValue];
    n.nodeID = [idGen newID];
    s = a[3];
    n.parmID = (int)[s integerValue];
    if (n.parmID==0) {
      n.contPT = 0.0;
    } else {
      s = a[4];
      n.contPT = (double)[s doubleValue];
    }
    return n;
  } else {
    return nil;
  }
}

@end
