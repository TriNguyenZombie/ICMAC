//
//  Utilities.m
//  iTest
//
//  Created by TriNguyen on 24/08/2022.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"

@implementation Utilities

+ (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

+ (NSString *)runCommandLine:(NSString *)commandToRun{
    @autoreleasepool {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/sh"];
        NSArray *arguments = [NSArray arrayWithObjects:
                              @"-c" ,
                              [NSString stringWithFormat:@"%@", commandToRun],
                              nil];
        NSLog(@"run command:%@", commandToRun);
        [task setArguments:arguments];
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];
        NSFileHandle *file = [pipe fileHandleForReading];
        [task launch];
        NSData *data = [file readDataToEndOfFile];
        @autoreleasepool {
            NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return output;
        }
    }
}

+ (NSString *)getDataOneLine{
    NSString* filePath = @"output";
    NSString* fileRoot = [[NSBundle mainBundle] pathForResource:filePath ofType:@"txt"];
    NSLog(@"[%s] data one line: %@", __func__, fileRoot);
    NSString* fileContents = [NSString stringWithContentsOfFile:fileRoot encoding:NSUTF8StringEncoding error:nil];
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:
          [NSCharacterSet newlineCharacterSet]];
    NSString* strsInOneLine = [allLinedStrings objectAtIndex:0];
//    NSLog(@"[%s] data one line: %@", __func__, strsInOneLine);
//    NSArray* singleStrs = [currentPointString componentsSeparatedByCharactersInSet:
//          [NSCharacterSet characterSetWithCharactersInString:@";"]];
    return strsInOneLine;
}

+ (NSDictionary *)dictionaryFromJsonString:(NSString *)stringJson
{
    NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error=Nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error)
    {
//        NSLog(@"%s Error al leer json: %@",__FUNCTION__, [error description]);
//        NSLog(@"%s String json: %@",__FUNCTION__, stringJson);
        return Nil;
    }
    return jsonDictionary;
}

+ (NSMutableDictionary *)getConfig:(NSString*)pathFileXML
{
    NSData *dataPlist = [NSData dataWithContentsOfFile:pathFileXML];
    NSError *error=nil;
    NSPropertyListFormat format;
    NSMutableDictionary* dic = [NSPropertyListSerialization propertyListWithData:dataPlist
                                                                         options:NSPropertyListImmutable
                                                                          format:&format
                                                                           error:&error];
//    NSLog( @"Dic Config: %@", dic );
    if(!dic){
        NSLog(@"Error: %@",error);
    }
    return dic;
}

@end
