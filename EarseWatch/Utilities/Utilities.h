//
//  Utilities.h
//  iTest
//
//  Created by TriNguyen on 24/08/2022.
//

#ifndef Utilities_h
#define Utilities_h

#define FILE_PATH_COMMAND @"/Volumes/MACOS/output.txt"
#define FILE_PATH_COMMAND_DEBUG @"/Users/tringuyen/Downloads/output.txt"

@interface Utilities : NSObject {
    
}
+ (NSString *)runCommand:(NSString *)commandToRun;
+ (NSString *)runCommandLine:(NSString *)commandToRun;
+ (NSString *)getDataOneLine;
+ (NSDictionary *)dictionaryFromJsonString:(NSString *)stringJson;
+ (NSMutableDictionary *)getConfig:(NSString *)pathFileXML;
@end
#endif /* Utilities_h */
