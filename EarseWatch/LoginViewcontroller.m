//
//  ViewController.m
//  EarseMac
//
//  Created by Greystone on 12/16/21.
//  Copyright © 2021 Greystone. All rights reserved.
//

#import "LoginViewcontroller.h"
#import "MainViewController.h"
#import "AppDelegate.h"
//#import "UITextFieldCell.h"
#import "UISecureTextFieldCell.h"
#import "UIImageView.h"
#import "UIButton.h"
#import "Utilities.h"
#import "define_gds.h"
#import "LibUSB/ProccessUSB.h"
#include <dirent.h>
#import "AFNetworking.h"
#import "ProtocolHW.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include "LinkServer.h"
#include "UserLogin.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>
#include <CommonCrypto/CommonHMAC.h>
#include <sys/types.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


@implementation LoginViewcontroller
@synthesize txtUserName;
@synthesize txtPasswrod;

NSMutableArray *arrServerLinks;
NSMutableArray *arrPushingList;

NSString *mMAC_address = @"";
NSString *mServerLink = @"http://pushing3.greystonedatatech.com/";
NSString *mServerLinkBackup = @"http://pushing3.greystonedatatech.com/";

- (void)loadView
{
    //    [super loadView];
    NSRect rect = [NSScreen mainScreen].frame;
    width = 800;height = 650;
    self.view = [[NSView alloc] initWithFrame:NSMakeRect((rect.size.width-width)/2, (rect.size.height-height)/2, width,height)];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.view.layer.borderColor = [NSColor brownColor].CGColor;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.cornerRadius = 7.0;
    self.view.layer.masksToBounds = YES;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
}

-(int)getRandomNumberBetween:(int)from and:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

- (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

RLMResults<UserLogin *> *allUserLogin;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSThread *threadGetTokenAndDownloadFileChecksum = [[NSThread alloc] initWithTarget:self selector:@selector(downloadFileConfig) object:nil];
    [threadGetTokenAndDownloadFileChecksum start];
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSLog(@"%s [Login-Screen] viewDidLoad ======> 1: ",__func__);
    enterPassword = 0;
    arrServerLinks =  delegate.arrServerLinks;
    
    NSError *error = nil;
    //Realm detect new properties and removed properties
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    // Set the new schema version. This must be greater than the previously used
    // version (if you've never set a schema version before, the version is 0).
    config.schemaVersion = 2;
    
    // Set the block which will be called automatically when opening a Realm with a
    // schema version lower than the one set above
    
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // We haven’t migrated anything yet, so oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
            // Nothing to do!
            // Realm will automatically detect new properties and removed properties
            // And will update the schema on disk automatically
        }
    };
    
    // Tell Realm to use this new configuration object for the default Realm
    
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    // Now that we've told Realm how to handle the schema change, opening the file
    // will automatically perform the migration
    
    [RLMRealm defaultRealm];
    RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
    //RLMRealm *realmT = [RLMRealm defaultRealm];
    NSLog(@"Local database path: %@",[RLMRealmConfiguration defaultConfiguration]);
    //NSLog(@"Local database path: %@",realmT);
    
    @try {
        allUserLogin = [UserLogin allObjects];
        NSLog(@"[Login-Screen][Get User From Database] allUserLogin: %lu", (unsigned long) allUserLogin.count);
        for(int i = 0; i < allUserLogin.count; i++) {
            NSLog(@"[Login-Screen][Get User From Database] allUserLogin[i].username: %@", allUserLogin[i].username);
            NSLog(@"[Login-Screen][Get User From Database] allUserLogin[i].password: %@", allUserLogin[i].password);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"[Login-Screen][Get User From Database] NSException exception.reason: %@", exception.reason);
    }
    @finally {
        NSLog(@"[Login-Screen][Get User From Database] Finally condition");
    }
    
    
    
    @try {
        // Get all link from database
        RLMResults<LinkServer *> *allLinkServer = [LinkServer allObjects];
        NSLog(@"[Login-Screen] allLinkServer: %lu", (unsigned long)allLinkServer.count);
        if (allLinkServer.count == 0) {
            
            [arrServerLinks removeAllObjects];
            
            arrServerLinks = delegate.arrServerLinks;
            
            
            if (arrServerLinks.count > 0) {
                NSError *error = nil;
                RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
                RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
                for(int i = 0; i < arrServerLinks.count; i++) {
                    [realm beginWriteTransaction];
                    LinkServer *mLinkServer = [[LinkServer alloc] init];
                    mLinkServer.ID = [NSString stringWithFormat:@"%i", i];
                    mLinkServer.linkServer = arrServerLinks[i];
                    NSLog(@"[Login-Screen] mLinkServer.ID: %@", mLinkServer.ID);
                    NSLog(@"[Login-Screen] mLinkServer.linkServer: %@",  mLinkServer.linkServer);
                    [realm addObject:mLinkServer];
                    [realm commitWriteTransaction];
                }
            }
            
            for(int i = 0; i < arrServerLinks.count; i++) {
                NSLog(@"[Login-Screen] DEBUG allLinkServer.count == 0 arrServerLinks[i]: %@", arrServerLinks[i]);
            }
        }
        else {
            //            [arrServerLinks removeAllObjects];
            //            for(int i = 0; i < allLinkServer.count; i++) {
            //                [arrServerLinks addObject:allLinkServer[i].linkServer];
            //                NSLog(@"[Login-Screen] allLinkServer[i].linkServer: %@", allLinkServer[i].linkServer);
            //                NSLog(@"[Login-Screen] arrServerLinks[i]: %@", arrServerLinks[i]);
            //            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"[Login-Screen] NSException exception.reason: %@", exception.reason);
        
        if (arrServerLinks.count > 0) {
            NSError *error = nil;
            RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
            RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
            for(int i = 0; i < arrServerLinks.count; i++) {
                [realm beginWriteTransaction];
                LinkServer *mLinkServer = [[LinkServer alloc] init];
                mLinkServer.ID = [NSString stringWithFormat:@"%i", i];
                mLinkServer.linkServer = arrServerLinks[i];
                NSLog(@"[Login-Screen] mLinkServer.ID: %@", mLinkServer.ID);
                NSLog(@"[Login-Screen] mLinkServer.linkServer: %@",  mLinkServer.linkServer);
                [realm addObject:mLinkServer];
                [realm commitWriteTransaction];
            }
        }
        
    }
    @finally {
        NSLog(@"[Login-Screen] Finally condition");
    }
    
    
    if(arrServerLinks.count>0)
    {
        int randomNumber = [self getRandomNumberBetween:0 and:(arrServerLinks.count - 1)];
        mServerLink = arrServerLinks[randomNumber];
    }
    NSLog(@"%s viewDidLoad ======> mServerLink: %@", __func__, mServerLink);
    
    
    //Show View Login
    NSView *viewTop = [[NSView alloc] initWithFrame:NSMakeRect(0, height - 50, width, 50)];
    viewTop.wantsLayer = YES;
    viewTop.layer.backgroundColor = delegate.colorBanner.CGColor;
    [self.view addSubview:viewTop];
    
    NSTextField *txtHeader = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, width, 47)];
    txtHeader.cell = [[NSTextFieldCell alloc] init];
    [viewTop addSubview:txtHeader];
    txtHeader.alignment = NSTextAlignmentLeft;
    txtHeader.font = [NSFont fontWithName:@"Roboto-Regular" size:24];
    txtHeader.backgroundColor = [NSColor clearColor];
    txtHeader.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtHeader.textColor = [NSColor whiteColor];
    txtHeader.stringValue = @"   Login";
    
    
    NSButton *btClose = [[NSButton alloc] initWithFrame:NSMakeRect(width - 40,height - 40, 30, 30)];
    btClose.title = @"";
    btClose.image = [NSImage imageNamed:@"CloseWhite.png"];
    [[btClose cell] setBackgroundColor:delegate.colorBanner];
    btClose.wantsLayer = YES;
    [btClose setBordered:NO];
    [btClose setToolTip:@"Close"];
    [btClose setTarget:self];
    [btClose setAction:@selector(btCloseClick:)];
    [self.view addSubview:btClose];
    
    NSImageView *imageLogo = [[NSImageView alloc] initWithFrame:NSMakeRect(width/2 - 135,height - 284,270,194)];
    imageLogo.image = [NSImage imageNamed:@"mac_login_logo"];
    [self.view addSubview:imageLogo];
    
    
    imgUser = [[NSImageView alloc] initWithFrame:NSMakeRect(180, height - 400, 450, 60)];
    imgUser.image = [NSImage imageNamed:@"txtUser"];
    imgUser.layer.cornerRadius = 10.0;
    [self.view addSubview:imgUser];
    
    txtUserName = [[UITextField alloc] initWithFrame:NSMakeRect(230, height - 400, 400, 50)];
    txtUserName.cell = [[NSTextFieldCell alloc] init];
    [self.view addSubview:txtUserName];
    [txtUserName.cell setFocusRingType:NSFocusRingTypeNone];
    txtUserName.placeholderString = @"Username";
    txtUserName.alignment = NSTextAlignmentLeft;
    txtUserName.font = [NSFont fontWithName:@"Roboto-Regular" size:25];
    txtUserName.bordered = NO;
    txtUserName.wantsLayer = YES;
    txtUserName.editable = YES;
    txtUserName.backgroundColor = [NSColor clearColor];
    txtUserName.delegate = self;
    txtUserName.uidelegate = self;
    txtUserName.stringValue = @"";
    
    
    
    imgPass = [[NSImageView alloc] initWithFrame:NSMakeRect(180, height - 475, 450, 60)];
    imgPass.image = [NSImage imageNamed:@"txtPass"];
    [self.view addSubview:imgPass];
    
    txtPasswrod = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(230, height - 475, 450, 50)];
    txtPasswrod.cell = [[NSSecureTextFieldCell alloc] init];
    [txtPasswrod.cell setFocusRingType:NSFocusRingTypeNone];
    txtPasswrod.placeholderString = @"Password";
    txtPasswrod.alignment = NSTextAlignmentLeft;
    txtPasswrod.font = [NSFont fontWithName:@"Roboto-Regular" size:25];//[NSFont controlContentFontOfSize:25];
    txtPasswrod.bordered = NO;
    txtPasswrod.wantsLayer = YES;
    txtPasswrod.editable = YES;
    txtPasswrod.backgroundColor = [NSColor clearColor];
    txtPasswrod.delegate = self;
    [txtPasswrod setTarget:self];
    [txtPasswrod setAction:@selector(btLoginClick:)];
    [self.view addSubview:txtPasswrod];
    
    txtPasswrod.stringValue = @"";
    
    
    UIButton *btLogin = [[UIButton alloc] initWithFrame:NSMakeRect(width/2-80 ,height - 570, 180, 60)];
    btLogin.title = @"";
    [[btLogin cell] setBackgroundColor:[NSColor whiteColor]];
    [btLogin setImage:[NSImage imageNamed:@"bt_login_normal.png"]];
    [btLogin setButtonImage:[NSImage imageNamed:@"bt_login_normal"] forState:UIControlStateNormal];
    [btLogin setButtonImage:[NSImage imageNamed:@"bt_login_press"] forState:UIControlStatePress];
    [btLogin setButtonImage:[NSImage imageNamed:@"bt_login_disable"] forState:UIControlStateDisabled];
    [btLogin sizeToFit];
    btLogin.layer.cornerRadius = 10;
    [btLogin setBordered:NO];
    [btLogin setToolTip:@"Login"];
    [btLogin setTarget:self];
    [btLogin setAction:@selector(btLoginClick:)];
    [self.view addSubview:btLogin];
    
    NSImageView *imgPower = [[NSImageView alloc] initWithFrame:NSMakeRect(width - 260, 10, 230, 40)];
    imgPower.image = [NSImage imageNamed:@"Power_by_Greystone"];
    [self.view addSubview:imgPower];
    
    // NSLog(@"%@",[[[NSFontManager sharedFontManager] availableFontFamilies] description]);
    
    [self askAllowDocument];
    
    mMAC_address = [[self getMacAddress]
                    stringByReplacingOccurrencesOfString:@":" withString:@""];
    // Test code
//    mMAC_address = @"AC:DE:48:00:11:22";
    // End test code
    NSLog(@"%s MAC address: [2] %@", __func__, mMAC_address);
    

    
    delegate.serialNumberStation = [[NSString alloc] initWithString:mMAC_address];
    
    
    threadSendLinkServerVerfy = [[NSThread alloc] initWithTarget:self selector:@selector(runSendLinkServerVerfy) object:nil];
    NSLog(@"%s viewDidAppear ======> threadSendLinkServerVerfy.executing %hhd", __func__, threadSendLinkServerVerfy.executing);
    if (threadSendLinkServerVerfy.executing == FALSE) {
        [threadSendLinkServerVerfy start];
    }
    
    //Get links of server
    //{ "command" : 16, "key" : 1280, "machine_type":"iwatch_eraser","modelsystem" : 1, "prversion" : 5, "stationsn" : "10C37B9DC6DE", "status" : 0 }
    NSMutableDictionary *dictGetServer = [[NSMutableDictionary alloc]init];
    [dictGetServer setValue:@(16) forKey:@"command"];
    [dictGetServer setValue:@(1280) forKey:@"key"];
    [dictGetServer setValue:@(1) forKey:@"modelsystem"];
    [dictGetServer setValue:@(5) forKey:@"prversion"];
    [dictGetServer setValue:mMAC_address forKey:@"stationsn"];
    [dictGetServer setValue:@(0) forKey:@"status"];
    
    //[dictGetServer setValue:@"9801A79D664B" forKey:@"stationsn"];
    
    [dictGetServer setValue:@"iwatch_eraser" forKey:@"machine_type"];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictGetServer options:NSJSONWritingPrettyPrinted error:&err];
    NSLog(@"[GetServer][NSURLSessionDataTask] JSON = %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
   
    mServerLinkBackup = mServerLink;
    NSURL *URL = [NSURL URLWithString:mServerLink];
    //2 - create AFNetwork manager
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //3 - set a body
    //4 - create request
    [manager POST: URL.absoluteString
       parameters: dictGetServer
         progress: nil
     //5 - response handling
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @try {
            NSString *jsonStringResponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"[GetServer][NSURLSessionDataTask] jsonStringResponse: %@", jsonStringResponse);
            NSData *data = [jsonStringResponse dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"[GetServer][NSURLSessionDataTask] pushinglist: %@",[json objectForKey:@"pushinglist"]);
            if([json objectForKey:@"pushinglist"] != nil) {
                arrPushingList = [json objectForKey:@"pushinglist"];
                NSLog(@"[GetServer][NSURLSessionDataTask] arrPushingList.count: %lu", (unsigned long)arrPushingList.count);
                if (arrPushingList.count > 0) {
                    //NSError *error = nil;
                    //RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
                    //RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    for(int i = 0; i < arrPushingList.count; i++) {
                        [realm beginWriteTransaction];
                        LinkServer *mLinkServer = [[LinkServer alloc] init];
                        mLinkServer.ID = [NSString stringWithFormat:@"%i", i];
                        mLinkServer.linkServer = arrPushingList[i];
                        NSLog(@"[GetServer][NSURLSessionDataTask] mLinkServer.ID: %@", mLinkServer.ID);
                        NSLog(@"[GetServer][NSURLSessionDataTask] mLinkServer.linkServer: %@",  mLinkServer.linkServer);
                        [realm addOrUpdateObject:mLinkServer];
                        [realm commitWriteTransaction];
                    }
                }
                NSLog(@"[GetServer][NSURLSessionDataTask] update Link Server DONE!!!");
                sendLinkServerVerifyLogin = TRUE;
            } else {
                NSLog(@"[GetServer][NSURLSessionDataTask] Reply Couldn't parse status");
                arrPushingList = arrServerLinks;
                
            }
        }
        @catch (NSException *exception) {
            NSLog(@"[GetServer][NSURLSessionDataTask] NSException exception.reason: %@", exception.reason);
        }
        @finally {
            NSLog(@"[GetServer][NSURLSessionDataTask] Finally condition");
        }
        
        
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"[GetServer][NSURLSessionDataTask] Reply error: %@", error);
    }
    ];
}

BOOL sendLinkServerVerifyLogin = FALSE;

- (void) runSendLinkServerVerfy
{
    //Create link server verify package
    NSMutableDictionary *dictLinkServerVerify = [[NSMutableDictionary alloc]init];
    [dictLinkServerVerify setValue:@(1) forKey:@"modelsystem"];
    [dictLinkServerVerify setValue:@(5) forKey:@"prversion"];
    [dictLinkServerVerify setValue:@(17) forKey:@"command"];
    [dictLinkServerVerify setValue:@(0) forKey:@"status"];
    [dictLinkServerVerify setValue:[[self getMacAddress] stringByReplacingOccurrencesOfString:@":" withString:@":"] forKey:@"stationsn"];
    //[dictLinkServerVerify setValue:@"9801A79D664B" forKey:@"stationsn"];
    [dictLinkServerVerify setValue:@(99) forKey:@"key"];
    [dictLinkServerVerify setValue:@"iwatch_eraser" forKey:@"machine_type"];
    [dictLinkServerVerify setValue:@(0) forKey:@"type"];
    
    while (TRUE) {
        if (sendLinkServerVerifyLogin == TRUE) {
            
           
            NSURL *URL = [NSURL URLWithString:mServerLinkBackup];
            
            NSLog(@"[runSendLinkServerVerfy][NSURLSessionDataTask] mServerLinkBackup: %@", mServerLinkBackup);
            
            //2 - create AFNetwork manager
            AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            //manager.requestSerializer = [AFJSONRequestSerializer serializer];
            //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            //3 - set a body
            //4 - create request
            [manager POST: URL.absoluteString
               parameters: dictLinkServerVerify
                 progress: nil
             //5 - response handling
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                @try {
                    NSString *jsonStringResponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    NSLog(@"[runSendLinkServerVerfy][NSURLSessionDataTask] [Link-Server-Verify] jsonStringResponse: %@", jsonStringResponse);
                    NSData *data = [jsonStringResponse dataUsingEncoding:NSUTF8StringEncoding];
                    //software
                    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    sendLinkServerVerifyLogin = FALSE;
                }
                @catch (NSException *exception) {
                    NSLog(@"[runSendLinkServerVerfy][NSURLSessionDataTask] [Link-Server-Verify] NSException exception.reason: %@", exception.reason);
                }
                @finally {
                    NSLog(@"[runSendLinkServerVerfy][NSURLSessionDataTask] [Link-Server-Verify] Finally condition");
                }
            }
                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"[runSendLinkServerVerfy][NSURLSessionDataTask] [Link-Server-Verify] error: %@", error);
            }
            ];
        }
        sleep(1);
    }
}

- (void)askAllowDocument
{
    NSURL * docDirURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:NULL];
    assert(docDirURL != nil);
    opendir(docDirURL.fileSystemRepresentation);
}
-(void) viewWillAppear
{
    txtUserName.editable = YES;
}

- (void)btCloseClick:(id)sender
{
    NSLog(@"%s",__func__);
    exit(0);
}


- (NSString *) md5EncodeBase64:(NSString *) inputPassword
{
    NSData *data = [inputPassword dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, data.length, digest);
    NSData *hashData = [[NSData alloc] initWithBytes:digest length: sizeof digest];
    NSString *base64 = [hashData base64EncodedStringWithOptions:1];
    
    return  base64;
}

MainViewController *controller;
bool clickedLoginButton = FALSE;
- (void)btLoginClick:(id)sender
{
    //    return ;
    //    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    //    delegate.userName = self->txtUserName.stringValue;
    //    delegate.mMacAddress = mMAC_address;
    //    delegate.arrPushingListDelegate = arrPushingList;
    //    delegate.mMacAddress2Send = [[self getMacAddress] stringByReplacingOccurrencesOfString:@":" withString:@":"];
    //    MainViewController *controller = [[MainViewController alloc] init];
    //    delegate.mainViewController = controller;
    //    NSWindow *mainWindow = [[[NSApplication sharedApplication] windows] objectAtIndex:0];//[[NSApplication sharedApplication] mainWindow];
    //    [mainWindow setContentViewController:controller];
    //    [mainWindow center];
    //    return ;
    
    //    NSRunAlertPanel(@"Title", @"This is your message.", @"OK", nil, nil);
    
    //    NSAlert *alert= [[NSAlert alloc] init];
    //    [alert setIcon:[NSImage imageNamed:@"Warning"]];
    //    alert.window.title = @"Warning";
    //    alert.messageText = @"Warning";
    //    alert.informativeText = @"Are you sure you want to logout?";
    //    [alert addButtonWithTitle:@"No"];
    //    [alert addButtonWithTitle:@"Yes"];
    //
    //
    //    alert.alertStyle = NSAlertStyleWarning;
    //    [alert.window makeKeyAndOrderFront:nil];
    //    alert.accessoryView =  [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 500, 0)] ;
    //    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
    //        // check returnCode here
    //    }];
    //    NSModalResponse buttonclick = [alert runModal];
    //    if(buttonclick == NSAlertFirstButtonReturn)
    //    {}
    
    
    //    ProccessUSB *libusb = [[ProccessUSB alloc] init];
    //    NSMutableArray *arr = [libusb getListiWatchDevice];
    //    NSLog(@"%s arr: %@",__func__,arr);
    //    NSLog(@"%s list Module:%@",__func__,[libusb getListModule]);
    //
    //    return;
    //    ProccessUSB *libusb = [[ProccessUSB alloc] init];
    //    NSMutableArray *arr = [libusb getListiMacDevice];
    //    NSLog(@"%s arr: %@",__func__,arr);
    //    return;
    //===============
    //    ProtocolHW *pro = [[ProtocolHW alloc] init];
    //    NSDictionary*dic = [pro checkVersion:@"A601V5NB"];
    //    if(dic)
    //        NSLog(@"%@",dic);
    //    return;
    if (clickedLoginButton == FALSE)
    {
        clickedLoginButton = TRUE;
        
        NSString *user = [txtUserName.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *password = [txtPasswrod.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *strPassword = [NSString stringWithFormat: @"%@%@", password, @"{s+(_a*}"];
        NSLog(@"%s passwordEncryptByMd5 strPassword: %@",__func__, strPassword);
        NSLog(@"%s passwordEncryptByMd5 user: %@",__func__, user);
        
        NSString *strPasswordMD5EncodeBase64 = [self md5EncodeBase64:strPassword];
        NSLog(@"%s strPasswordMD5EncodeBase64: %@", __func__, strPasswordMD5EncodeBase64);
        if (allUserLogin.count > 0)
        {
            @try {
                NSLog(@"[Login-Screen][Get User From Database][btLoginClick] allUserLogin: %lu", (unsigned long) allUserLogin.count);
                for(int i = 0; i < allUserLogin.count; i++)
                {
                    NSLog(@"[Login-Screen][Get User From Database][btLoginClick] allUserLogin[i].username: %@", allUserLogin[i].username);
                    NSLog(@"[Login-Screen][Get User From Database][btLoginClick] allUserLogin[i].password: %@", allUserLogin[i].password);
                    NSLog(@"%s[Login-Screen][Get User From Database][btLoginClick] strPassword: %@", __func__, strPasswordMD5EncodeBase64);
                    if([user isEqualToString:allUserLogin[i].username])
                    {
                        NSLog(@"[Login-Screen][Get User From Database][btLoginClick] Matched user");
                        if([strPasswordMD5EncodeBase64 isEqualToString:allUserLogin[i].password])
                        {
                            NSLog(@"[Login-Screen][Get User From Database][btLoginClick] Matched password");
                            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                            delegate.userName = self->txtUserName.stringValue;
                            delegate.mMacAddress = mMAC_address;
                            delegate.arrPushingListDelegate = arrPushingList;
                            delegate.mMacAddress2Send = [[self getMacAddress] stringByReplacingOccurrencesOfString:@":" withString:@":"];
                            MainViewController *controller = [[MainViewController alloc] init];
                            delegate.mainViewController = controller;
                            NSWindow *mainWindow = [[[NSApplication sharedApplication] windows] objectAtIndex:0];//[[NSApplication sharedApplication] mainWindow];
                            [mainWindow setContentViewController:controller];
                            [mainWindow center];
                            sleep(1);
                            clickedLoginButton = FALSE;
                            NSLog(@"[Login-Screen][Get User From Database][btLoginClick] Login Offline ====================");
                            return;
                        }
                        
                    }
                }
                
                NSLog(@"[Login-Screen][Get User From Database][btLoginClick] Login Online ====================");
                
                NSMutableDictionary *dictLogin = [[NSMutableDictionary alloc]init];
                [dictLogin setValue:user forKey:@"username"];
                [dictLogin setValue:password forKey:@"password"];
                [dictLogin setValue:@(12) forKey:@"command"];
                [dictLogin setValue:@(1) forKey:@"encryptedpasswd"];
                [dictLogin setValue:@(1686) forKey:@"key"];
                [dictLogin setValue:@(1) forKey:@"modelsystem"];
                [dictLogin setValue:@(5) forKey:@"prversion"];
                [dictLogin setValue:@"" forKey:@"site"]; //ATT
                [dictLogin setValue:mMAC_address forKey:@"stationsn"];
                [dictLogin setValue:@(0) forKey:@"status"];
                [dictLogin setValue:@"iwatch_eraser" forKey:@"machine_type"];
                
                NSError *err;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictLogin options:NSJSONWritingPrettyPrinted error:&err];
                NSLog(@"[Login][NSURLSessionDataTask] JSON = %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
                // 1 - define resource URL
              
                int sizeOfarrPushingList = (int)arrPushingList.count - 1;
                NSLog(@"sizeOfarrPushingList: %d", sizeOfarrPushingList);
                
                if (sizeOfarrPushingList > 1) {
                    int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                    mServerLink = arrPushingList[randomNumber];
                } else if (sizeOfarrPushingList == 1) {
                    mServerLink = arrPushingList[0];
                }
                NSLog(@"Login with Link: %@", mServerLink);
                
           
                NSURL *URL = [NSURL URLWithString:mServerLink];
                
                NSLog(@"Login with Link (real): %@", mServerLink);
                
                
                //2 - create AFNetwork manager
                AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                
                //manager.requestSerializer = [AFJSONRequestSerializer serializer];
                //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                //3 - set a body
                //4 - create request
                [manager POST: URL.absoluteString
                   parameters: dictLogin
                     progress: nil
                 //5 - response handling
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    //NSLog(@"Reply POST JSON: %@", responseObject);
                    NSString *jsonStringResponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    @try {
                        NSLog(@"[Login][NSURLSessionDataTask] jsonStringResponse: %@", jsonStringResponse);
                        
                        NSData *data = [jsonStringResponse dataUsingEncoding:NSUTF8StringEncoding];
                        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        NSLog(@"[Login][NSURLSessionDataTask] status: %@",[json objectForKey:@"status"]);
                        if([[json objectForKey:@"status"]  isEqual: @"success"]) {
                            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                            delegate.userName = self->txtUserName.stringValue;
                            delegate.mMacAddress = mMAC_address;
                            delegate.arrPushingListDelegate = arrPushingList;
                            //delegate.arrServerLinks = arrPushingList;
                            delegate.mMacAddress2Send = [[self getMacAddress] stringByReplacingOccurrencesOfString:@":" withString:@":"];
                            MainViewController *controller = [[MainViewController alloc] init];
                            delegate.mainViewController = controller;
                            NSWindow *mainWindow = [[[NSApplication sharedApplication] windows] objectAtIndex:0];//[[NSApplication sharedApplication] mainWindow];
                            [mainWindow setContentViewController:controller];
                            [mainWindow center];
                            sleep(1);
                            clickedLoginButton = FALSE;
                        } else
                        {
                            NSAlert *alert = [NSAlert alertWithMessageText:@"Login Failed" defaultButton:@"Close" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", [json objectForKey:@"status"]];
                            [alert runModal];
                            clickedLoginButton = FALSE;
                        }
                    }
                    @catch (NSException *exception)
                    {
                        NSLog(@"[Login][NSURLSessionDataTask] NSException exception.reason: %@", exception.reason);
                        clickedLoginButton = FALSE;
                    }
                    @finally
                    {
                        NSLog(@"[Login][NSURLSessionDataTask] Finally condition");
                        clickedLoginButton = FALSE;
                    }
                }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"[Login][NSURLSessionDataTask] Reply error: %@", error);
                    clickedLoginButton = FALSE;
                }
                ];
                
                
            }
            @catch (NSException *exception) {
                NSLog(@"[Login-Screen][Get User From Database][btLoginClick] NSException exception.reason: %@", exception.reason);
                clickedLoginButton = FALSE;
            }
            @finally {
                NSLog(@"[Login-Screen][Get User From Database][btLoginClick] Finally condition");
                clickedLoginButton = FALSE;
            }
        }
        else
        {
            NSLog(@"[Login-Screen][Get User From Database][btLoginClick] Login Online ====================");
            
            NSMutableDictionary *dictLogin = [[NSMutableDictionary alloc]init];
            [dictLogin setValue:user forKey:@"username"];
            [dictLogin setValue:password forKey:@"password"];
            [dictLogin setValue:@(12) forKey:@"command"];
            [dictLogin setValue:@(1) forKey:@"encryptedpasswd"];
            [dictLogin setValue:@(1686) forKey:@"key"];
            [dictLogin setValue:@(1) forKey:@"modelsystem"];
            [dictLogin setValue:@(5) forKey:@"prversion"];
            [dictLogin setValue:@"" forKey:@"site"];
            [dictLogin setValue:mMAC_address forKey:@"stationsn"];
            [dictLogin setValue:@(0) forKey:@"status"];
            [dictLogin setValue:@"iwatch_eraser" forKey:@"machine_type"];
            
            NSError *err;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictLogin options:NSJSONWritingPrettyPrinted error:&err];
            NSLog(@"[Login][NSURLSessionDataTask] JSON = %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
         
            int sizeOfarrPushingList = (int)arrPushingList.count - 1;
            NSLog(@"sizeOfarrPushingList: %d", sizeOfarrPushingList);
            
            if (sizeOfarrPushingList > 1) {
                int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                mServerLink = arrPushingList[randomNumber];
            } else if (sizeOfarrPushingList == 1) {
                mServerLink = arrPushingList[0];
            }
            NSLog(@"Login with Link: %@", mServerLink);
            
            
            NSURL *URL = [NSURL URLWithString:mServerLink];
            
            NSLog(@"Login with Link (real): %@", mServerLink);
            
            
            //2 - create AFNetwork manager
            AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            //manager.requestSerializer = [AFJSONRequestSerializer serializer];
            //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            //3 - set a body
            //4 - create request
            [manager POST: URL.absoluteString
               parameters: dictLogin
                 progress: nil
             //5 - response handling
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                //NSLog(@"Reply POST JSON: %@", responseObject);
                NSString *jsonStringResponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                @try {
                    NSLog(@"[Login][NSURLSessionDataTask] jsonStringResponse: %@", jsonStringResponse);
                    
                    NSData *data = [jsonStringResponse dataUsingEncoding:NSUTF8StringEncoding];
                    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"[Login][NSURLSessionDataTask] status: %@",[json objectForKey:@"status"]);
                    if([[json objectForKey:@"status"]  isEqual: @"success"]) {
                        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                        delegate.userName = self->txtUserName.stringValue;
                        delegate.mMacAddress = mMAC_address;
                        delegate.arrPushingListDelegate = arrPushingList;
                        delegate.mMacAddress2Send = [[self getMacAddress] stringByReplacingOccurrencesOfString:@":" withString:@":"];
                        MainViewController *controller = [[MainViewController alloc] init];
                        delegate.mainViewController = controller;
                        NSWindow *mainWindow = [[[NSApplication sharedApplication] windows] objectAtIndex:0];//[[NSApplication sharedApplication] mainWindow];
                        [mainWindow setContentViewController:controller];
                        [mainWindow center];
                        sleep(1);
                        clickedLoginButton = FALSE;
                    } else {
                        NSAlert *alert = [NSAlert alertWithMessageText:@"Login Failed" defaultButton:@"Close" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", [json objectForKey:@"status"]];
                        [alert runModal];
                        clickedLoginButton = FALSE;
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"[Login][NSURLSessionDataTask] NSException exception.reason: %@", exception.reason);
                    clickedLoginButton = FALSE;
                }
                @finally {
                    NSLog(@"[Login][NSURLSessionDataTask] Finally condition");
                    clickedLoginButton = FALSE;
                }
            }
                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"[Login][NSURLSessionDataTask] Reply error: %@", error);
                clickedLoginButton = FALSE;
            }
            ];
        }
        
    }
    
    
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
//- (void) deleteWatch
//{
//    ProccessUSB *libusb = [[ProccessUSB alloc] init];
//    NSString *UniqueDeviceID = @"34ab381d997043cadb184d76c46a2dbb98c8c57e";
//    NSString *path = @"/Users/duyetle/Documents/IPSW/Watch_2_Regular_6.3_17U208_Restore.ipsw";
//    [libusb restoreWatch:UniqueDeviceID pathFile:path];
//}
#pragma mark - Textfield delegate

/////<NSTextFieldDelegate>
//- (void)controlTextDidBeginEditing:(NSNotification *)obj
//{
//    NSLog(@"%s khi them ky tu dau tien",__func__);
//}
- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    if(obj.object == txtUserName)
    {
        NSLog(@"%s roi khoi username",__func__);
        imgUser.image = [NSImage imageNamed:@"txtUser"];
        imgPass.image = [NSImage imageNamed:@"txtPass_cursor"];
    }
    else if(obj.object == txtPasswrod)
    {
        NSLog(@"%s ra khoi password",__func__);
        enterPassword = enterPassword + 1;
        [self performSelector:@selector(checkEnter:) withObject:[NSNumber numberWithInt:enterPassword] afterDelay:1];
    }
}


bool enterLogin = FALSE;

- (void)checkEnter:(NSNumber *)num
{
    NSLog(@"%s checkEnter =====> %d ",__func__, [num intValue]);
    
    if(enterPassword == 2)
    {
        //[self performSelector:@selector(btLoginClick:) withObject:nil afterDelay:0];
        
    }
}

-(BOOL)textFieldDidBecomeFirstResponder:(NSTextField *)sender
{
    if(sender == txtUserName)
    {
        enterPassword++;
        NSLog(@"%s username",__func__);
        imgUser.image = [NSImage imageNamed:@"txtUser_cursor"];
        imgPass.image = [NSImage imageNamed:@"txtPass"];
    }
    else if(sender == txtPasswrod)
        NSLog(@"%s password",__func__);
    return YES;
}
///<UITextFieldDelegate>
-(BOOL)textFieldDidResignFirstResponder:(NSTextField *)sender
{
    //   // cai nay chay truoc textFieldDidBecomeFirstResponder
    return YES;
}
- (void)controlTextDidChange:(NSNotification *)obj
{
    //NSLog(@"%s dang them ky tu",__func__);
}

- (void)getTokenAndDownloadChecksumFile
{
    NSLog(@"[getTokenAndDownloadChecksumFile] ------------------- get token id then download file config from CDN ---------------");
    NSString *token = [self createTokenWithUser: @USER_NAME_CDN api: @API_KEY_CDN];
    NSLog(@"[getTokenAndDownloadChecksumFile] token id: %@", token);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFileConfig = [NSString stringWithFormat: @"%@/EarseMac/Lib/config/ipsw_info.config", documentsDirectory];
    
    NSString *command = [NSString stringWithFormat: @"curl -H \"X-Auth-Token: %@\" https://storage101.dfw1.clouddrive.com/v1/MossoCloudFS_6d2201cb-63f4-47a5-97f4-08c7ff9621ba/Macbook_Erasure/IPSW/ipsw_info.config --output %@", token, pathFileConfig];
    [Utilities runCommand: command];
}

- (NSString *)createTokenWithUser:(NSString *)username api:(NSString*)apikey
{
    NSString *commandGetToken = @"curl -X POST https://identity.api.rackspacecloud.com/v2.0/tokens -H 'Content-Type: application/json' -d '{\"auth\":{\"RAX-KSKEY:apiKeyCredentials\":{\"username\":\"greycdn.user\",\"apiKey\":\"608720ab85c3498c82f5fda650f9a079\"}}}'";
    NSString *result = [Utilities runCommand: commandGetToken];
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSDictionary *dic  = [delegate diccionaryFromJsonString:result];
    NSString *strToken = [NSString stringWithFormat:@"%@",[[[dic objectForKey:@"access"] objectForKey:@"token"] objectForKey:@"id"]];
    return strToken;
}

- (void)downloadFileConfig
{
    NSLog(@"[downloadFileConfig] -- Check and download ipsw_info.config");
    [self getTokenAndDownloadChecksumFile];
}

@end
