//
//  AppDelegate.m
//  EarseMac
//
//  Created by Greystone on 12/16/21.
//  Copyright © 2021 Greystone. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewcontroller.h"
#import <Realm/Realm.h>
#import "DeviceInfo.h"
#import "DeviceMapping.h"
#import "MainViewController.h"
#import "LinkServer.h"
#import "ProtocolHW.h"
//#import "AboutViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window;
@synthesize viewController;
@synthesize userName;
@synthesize colorBanner;
@synthesize isLogout;
@synthesize arrPushingListDelegate;
@synthesize arrServerLinks;
@synthesize autoPrint;
@synthesize mainViewController;
@synthesize dicInfoSettingSave;
@synthesize serialNumberStation;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSRect rect = [NSScreen mainScreen].frame;
    height = 650; width = 800;
    autoPrint = YES;
    colorBanner = [NSColor colorWithRed:0x30*1.0/0xff green:0x30*1.0/0xff blue:0x30*1.0/0xff alpha:1.0];
    arrServerLinks = nil;
    [self loadSettingInfoSave];
    NSString *strServer = [dicInfoSettingSave objectForKey:@"server"];
    [self loadArrayServer:strServer];
    
    
    window = [[UIWindow alloc] initWithContentRect:NSMakeRect((rect.size.width-width)/2, (rect.size.height-height)/2, width,height)
                                   styleMask:NSBorderlessWindowMask
                                   backing:NSBackingStoreBuffered
                                     defer:NO];
    [window setBackgroundColor:[NSColor clearColor]];
    [window center];
    
    window.title = @"iCombine Mac";
    viewController = [[LoginViewcontroller alloc] init];
    window.contentViewController = viewController;
    [window makeKeyAndOrderFront:NSApp];
    [window setLevel:NSNormalWindowLevel];
    [window setAcceptsMouseMovedEvents:YES];
    
    
}
- (void)loadArrayServer:(NSString*)strServerLocation
{
    if(arrServerLinks == nil)
        arrServerLinks =  [[NSMutableArray alloc] init];
   
    NSString *pathLib = [self pathLib];
    pathLib = [pathLib stringByAppendingString:@"/config/Server.config"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    if([[NSFileManager defaultManager] fileExistsAtPath:pathLib])
//    {
//        NSString *info = [NSString stringWithContentsOfFile:pathLib encoding:NSUTF8StringEncoding error:nil];
//        dic = (NSMutableDictionary *)[self diccionaryFromJsonString:info];
//
//    }
//    else
//    {
//
        NSMutableArray *arrdalas = [NSMutableArray arrayWithObjects:
                                    @"http://pushing16.greystonedatatech.com/",
                                    @"http://pushing3.greystonedatatech.com/",
                                    @"http://pushing17.greystonedatatech.com/",
                                    @"http://pushing25.greystonedatatech.com/",
                                    @"http://pushing9.greystonedatatech.com/",
                                    @"http://pushing2.greystonedatatech.com/",
                                    @"http://pushing2.greystonedatatech.com/",
                                    @"http://pushing30.greystonedatatech.com/",
                                    nil];
        [dic setObject:arrdalas forKey:@"dalas"];
        
        
        NSString *info = [self jsonStringFromDictionary:dic];
        [info writeToFile:pathLib atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    }
//    if([[strServerLocation lowercaseString] isEqualToString:@"dalas"])
//    {
        arrServerLinks = [[dic objectForKey:@"dalas"] mutableCopy];
//    }
   
}
- (NSMutableDictionary *)loadSettingInfoSave
{
    NSString *pathLib = [self pathLib];
    pathLib = [pathLib stringByAppendingString:@"/config/Setting.config"];
    if([[NSFileManager defaultManager] fileExistsAtPath:pathLib]==YES)
    {
        NSString *info = [NSString stringWithContentsOfFile:pathLib encoding:NSUTF8StringEncoding error:nil];
        dicInfoSettingSave = (NSMutableDictionary *)[self diccionaryFromJsonString:info];
    }
    else
    {
        dicInfoSettingSave = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1],@"enable_auto_detect_device_after_proccess_complete",
                              @"https:\/\/storage101.ord1.clouddrive.com\/v1\/MossoCloudFS_6d2201cb-63f4-47a5-97f4-08c7ff9621ba\/",@"localLink",
                              [NSNumber numberWithInt:1],@"auto_run_after_plugin_device",
                              [NSNumber numberWithInt:120],@"timeout",//timeout erase
                              [NSNumber numberWithInt:120],@"timeout_test",//timeout test
                              @"Dalas",@"server",
                              @"Dalas",@"location",
                              [NSNumber numberWithInt:50],@"baterry_timeout",
                              [NSNumber numberWithInt:1000],@"battery_cycle_count",
                              [NSNumber numberWithInt:30],@"battery_lever",
                              [NSNumber numberWithInt:0],@"battery_settings",
                              [NSNumber numberWithInt:30],@"battery_soh",
                              @"Elapsed time Proccess",@"elapsed_time",
                              [NSNumber numberWithInt:0],@"auto_mail_report",
                              @"",@"email_reoprt",
                              [NSNumber numberWithInt:0],@"enable_auto_detect_device_after_proccess_complete",
                              @"Manual erasure",@"erasure_method",
                              @"Weekly",@"recurrences",
                              @"text.local",@"localLink",
                              nil];
    }
   
    return dicInfoSettingSave;
}
- (BOOL)saveSettingInfo:(NSMutableDictionary *)dic
{
    NSString *pathLib = [self pathLib];
    pathLib = [pathLib stringByAppendingString:@"/config/Setting.config"];
    NSLog(@"dic setting: %@",dic);
    NSString *data = [self jsonStringFromDictionary:dic];
    NSLog(@"data: %@",data);
    [data writeToFile:pathLib atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSError *err=nil;
    [data writeToFile:pathLib atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if(err)
        return NO;
    
    return YES;
}
- (void)logout
{
    isLogout = YES;
    [window setLevel:NSNormalWindowLevel];
    window.contentViewController = viewController;
    [self.window toggleFullScreen:Nil];
    [self.window toggleToolbarShown:Nil];
    self.window.collectionBehavior = NSWindowCollectionBehaviorDefault;
 //   [window setLevel:NSMainMenuWindowLevel];
    viewController = [[LoginViewcontroller alloc] init];
    window.contentViewController = viewController;
    [window center];
    [window displayIfNeeded];
    if(self.mainViewController != nil)
    {
        self.mainViewController = nil;
    }
}

-(NSMutableAttributedString *)setColorTitleFor:(NSButton*) ButtonInfo color:(NSColor *)color size:(int)size
{
    //NSColor *color = [NSColor whiteColor];
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[ButtonInfo attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [colorTitle addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:size] range:titleRange];
    [ButtonInfo setAttributedTitle:colorTitle];
    [ButtonInfo setWantsLayer:YES];
    return colorTitle;
}
-(NSMutableAttributedString *)setColorTitleFor:(NSButton*) ButtonInfo color:(NSColor *)color Font:(NSFont*)font
{
    //NSColor *color = [NSColor whiteColor];
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[ButtonInfo attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [colorTitle addAttribute:NSFontAttributeName value:font range:titleRange];
    [ButtonInfo setAttributedTitle:colorTitle];
    [ButtonInfo setWantsLayer:YES];
    return colorTitle;
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (NSString*)pathLib
{
    
//    NSArray * paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
//    NSString * desktopPath = [paths objectAtIndex:0];
//    NSLog(@"%s Desktop:%@",__func__,desktopPath);
//
//    paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
//    desktopPath = [paths objectAtIndex:0];
//    NSLog(@"%s Document:%@",__func__,desktopPath);
//
//    paths = NSSearchPathForDirectoriesInDomains (NSDownloadsDirectory, NSUserDomainMask, YES);
//    desktopPath = [paths objectAtIndex:0];
//    NSLog(@"%s Downloads:%@",__func__,desktopPath);
//
//    NSLog(@" Home path:%@",[NSURL fileURLWithPath:NSHomeDirectory()].path);
//    NSLog(@" Desktop path:%@",[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]].path);
//    NSLog(@" Documents path:%@",[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]].path);
//    NSLog(@" Downloads path:%@",[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"]].path);
//    NSLog(@" Current app path: %@",[[NSBundle mainBundle] bundleURL]);
    NSString *documentsPath = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/EarseMac/Lib"]].path;
    NSLog(@"%s path lib:%@",__func__,documentsPath);
    return  documentsPath;
}
bool postDataToServerFinish = NO;
- (NSString*)postToServer:(NSString *)serverLink data:(NSString*)postString
{
    NSLog(@"%s postString:%@",__func__,postString);
    postString = [self encodeBase64:postString];
    
    //NSLog(@"%s postString de:%@",__func__,[self decodeBase64:postString]);
    
   // dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",serverLink]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"%s postString : %@",__func__,postString);
        NSError *error=Nil;
        NSURLResponse *response;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if(!error)
        {
            NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
           // NSLog(@"%s data : %@",__func__,data);
            
            
            data = [self decodeBase64:data];
            NSLog(@"%s respone data passed : %@",__func__,data);
            if(data == nil)
            {
                return @"";
            }
           
            return data;
        }
        else
        {
            NSLog(@"%s respone data failed post to : %@ data:%@",__func__,serverLink, postString);
            return @"";
        }
   // });
  //  return YES;
}

- (NSString *) encodeBase64:(NSString *) inputString
{
    
    NSData *encodeData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
    NSLog(@"Encode String Value: %@", base64String);
    return base64String;
    
//    NSData *data = [inputPassword dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
//    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(data.bytes, data.length, digest);
//    NSData *hashData = [[NSData alloc] initWithBytes:digest length: sizeof digest];
//    NSString *base64 = [hashData base64EncodedStringWithOptions:1];
//
//    return  base64;
}
- (NSString *) decodeBase64:(NSString *) inputString
{
   // [NSJSONSerialization dataWithJSONObject:dictSyncUsersLogin options:NSJSONWritingPrettyPrinted error:&errSyncUsersLogin];
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:inputString options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    //NSLog(@"Decode String Value: %@", decodedString);
    return decodedString;
}



#pragma mark -
#pragma mark Dictionary converter

- (NSDictionary *)diccionaryFromJsonString:(NSString *)stringJson
{
    NSLog(@"%s [diccionaryFromJsonString]String json: %@",__FUNCTION__, stringJson);
    NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error=Nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error)
    {
        NSLog(@"%s Error al leer json: %@",__FUNCTION__, [error description]);
        NSLog(@"%s String json: %@",__FUNCTION__, stringJson);
        return Nil;
    }
    return jsonDictionary;
}

- (NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary
{
    @try
    {
        NSError *error = Nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        if (error)
        {
            NSLog(@"%s Error: %@",__FUNCTION__, error);
        }
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        return jsonString;
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s Error: %@",__FUNCTION__, [exception debugDescription]);
        
        NSDate * now = [NSDate date];
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *newDateString = [outputFormatter stringFromDate:now];
        newDateString = [NSString stringWithFormat:@"error(%@): %@",newDateString,[exception description]];
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *fileJsonlog = [NSString stringWithFormat:@"%@/jsonerror.txt", [paths objectAtIndex:0]];
        [newDateString writeToFile:fileJsonlog atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

@end
