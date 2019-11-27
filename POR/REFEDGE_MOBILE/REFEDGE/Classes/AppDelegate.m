/*
 Copyright (c) 2011-2014, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AppDelegate.h"
#import <SalesforceSDKCore/SFPushNotificationManager.h>
#import <SalesforceSDKCore/SFDefaultUserManagementViewController.h>
#import <SalesforceSDKCore/SalesforceSDKManager.h>
#import <SalesforceSDKCore/SFUserAccountManager.h>
#import <SalesforceCommonUtils/SFLogger.h>
#import "REFEDGE-Bridging-Header.h"
#import "REFEDGE-Swift.h"
#import <SystemConfiguration/SCNetworkReachability.h>

// Fill these in when creating a new Connected Application on Force.com
static NSString * const RemoteAccessConsumerKey = @"3MVG9sG9Z3Q1RlbdjdipI7.mQaoLMU4gnI5Zvfe9_h_mbDCwBfDRQtLyHL.YBSDxgn3nRG.qfR63VqE9IxmTf";
static NSString * const OAuthRedirectURI        = @"sfdc://success";
bool network;
NSDictionary *notificationData;
bool onLoadNotification;
NotificationsViewController * controller;
@interface AppDelegate ()

/**
 * Convenience method for setting up the main UIViewController and setting self.window's rootViewController
 * property accordingly.
 */
- (void)setupRootViewController;

/**
 * (Re-)sets the view state when the app first loads (or post-logout).
 */
- (void)initializeAppViewState;

@end

@implementation AppDelegate

@synthesize window = _window;

- (id)init
{
    self = [super init];
    if (self) {
        //[SFLogger setLogLevel:SFLogLevelDebug];
        [SalesforceSDKManager sharedManager].connectedAppId = RemoteAccessConsumerKey;
        [SalesforceSDKManager sharedManager].connectedAppCallbackUri = OAuthRedirectURI;
        [SalesforceSDKManager sharedManager].authScopes = @[ @"web", @"api" ];
        __weak AppDelegate *weakSelf = self;
        [SalesforceSDKManager sharedManager].postLaunchAction = ^(SFSDKLaunchAction launchActionList) {
            [[SFPushNotificationManager sharedInstance] registerForRemoteNotifications];
            [weakSelf log:SFLogLevelInfo format:@"Post-launch: launch actions taken: %@", [SalesforceSDKManager launchActionsStringRepresentation:launchActionList]];
            [weakSelf setupRootViewController];
        };
        [SalesforceSDKManager sharedManager].launchErrorAction = ^(NSError *error, SFSDKLaunchAction launchActionList) {
            [weakSelf log:SFLogLevelError format:@"Error during SDK launch: %@", [error localizedDescription]];
            [weakSelf initializeAppViewState];
            [[SalesforceSDKManager sharedManager] launch];
        };
        [SalesforceSDKManager sharedManager].postLogoutAction = ^{
            [weakSelf handleSdkManagerLogout];
        };
        [SalesforceSDKManager sharedManager].switchUserAction = ^(SFUserAccount *fromUser, SFUserAccount *toUser) {
            [weakSelf handleUserSwitch:fromUser toUser:toUser];
        };
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self initializeAppViewState];
    //NSTimeInterval interval = 300;//5 min
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    if (launchOptions != nil)
    {
        UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotification) {
            NSDictionary *dUserInfo = localNotification.userInfo;
            notificationData = dUserInfo;
        }
    }
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"VIEW_DETAIL_IDENTIFIER";
    acceptAction.title = @"View Detail";
    acceptAction.activationMode = UIUserNotificationActivationModeBackground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = @"referenceNotification";
    [notificationCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    [notificationCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    NSSet *categories = [NSSet setWithObjects:notificationCategory, nil];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                                (UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:categories];
        [application registerUserNotificationSettings:settings];
    }
    network = AppDelegate.isNetworkAvailable;
    [[SalesforceSDKManager sharedManager] launch];
    return YES;
}
-(void)salesforceLogin:(NSObject*) obj{
    
    [[SFPushNotificationManager sharedInstance] registerForRemoteNotifications];
    [[SalesforceSDKManager sharedManager] launch];
}

/**
 * This method will called when remote registeration will fail
 *
 */
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    //NSLog(@"Failed to get token, error: %@", error);
}
/**
 * This method will called when remote registration will success
 *
 **/
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //NSLog(@"My device token is: %@", deviceToken);
    [[SFPushNotificationManager sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    if ([[SFUserAccountManager sharedInstance] currentUser].credentials.accessToken != nil) {
        [[SFPushNotificationManager sharedInstance] registerForSalesforceNotifications];
    }
}
#pragma mark - Private methods

- (void)initializeAppViewState
{
    NSString * storyboardName = @"Main";
    NSString * viewControllerID = @"HomeView";
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    self.window.rootViewController = (HomeViewController *)[storyboard instantiateViewControllerWithIdentifier:viewControllerID];
    [self.window makeKeyAndVisible];}
- (void)setupRootViewController
{
    NSString * storyboardName = @"Main";
    NSString * viewControllerID = @"NotificationView";
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    controller = (NotificationsViewController *)[storyboard instantiateViewControllerWithIdentifier:viewControllerID];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:controller];
    if (network) {
        onLoadNotification = true;
        UserInfo *userInfo = [UserInfo alloc];
        userInfo.userId = [[SFUserAccountManager sharedInstance] currentUser].credentials.userId;
        userInfo.userName = [SFUserAccountManager sharedInstance].currentUser.fullName;
        controller.userInfo  = userInfo;
        controller.notificationData = notificationData;
        [self fetchSetting:userInfo.userId];
        [self fetchData];
    }
    controller.isOffline = network;
    self.window.rootViewController = navVC;
    //NSLog(@" refresh token : %@",[[SFUserAccountManager sharedInstance] currentUser].credentials.refreshToken);
}

- (void)resetViewState:(void (^)(void))postResetBlock
{
    if ([self.window.rootViewController presentedViewController]) {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
            postResetBlock();
        }];
    } else {
        postResetBlock();
    }
}

- (void)handleSdkManagerLogout
{
    [self log:SFLogLevelDebug msg:@"SFAuthenticationManager logged out.  Resetting app."];
    [self resetViewState:^{
        [self initializeAppViewState];
        NSArray *allAccounts = [SFUserAccountManager sharedInstance].allUserAccounts;
        if ([allAccounts count] > 1) {
            SFDefaultUserManagementViewController *userSwitchVc = [[SFDefaultUserManagementViewController alloc] initWithCompletionBlock:^(SFUserManagementAction action) {
                [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
            }];
            [self.window.rootViewController presentViewController:userSwitchVc animated:YES completion:NULL];
        } else {
            if ([allAccounts count] == 1) {
                [SFUserAccountManager sharedInstance].currentUser = ([SFUserAccountManager sharedInstance].allUserAccounts)[0];
            }
            [[SalesforceSDKManager sharedManager] launch];
        }
    }];
}

- (void)handleUserSwitch:(SFUserAccount *)fromUser
                  toUser:(SFUserAccount *)toUser
{
    [self log:SFLogLevelDebug format:@"SFUserAccountManager changed from user %@ to %@.  Resetting app.",
     fromUser.userName, toUser.userName];
    [self resetViewState:^{
        [self initializeAppViewState];
        [[SalesforceSDKManager sharedManager] launch];
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandle
{
    controller.notificationData = userInfo;
    if(onLoadNotification && userInfo!= nil){
        [[NSNotificationCenter defaultCenter] postNotificationName: @"RemoteNotification" object:userInfo userInfo:userInfo];
    }
    completionHandle(UIBackgroundFetchResultNewData);
}


-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    if(onLoadNotification && notification.userInfo!= nil){
        [[NSNotificationCenter defaultCenter] postNotificationName: @"RemoteNotification" object:notification.userInfo userInfo:notification.userInfo];
    }
}

+(bool)isNetworkAvailable
{
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "login.salesforce.com" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    return canReach;
}
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    __block UIBackgroundTaskIdentifier watchKitHandler;
    watchKitHandler = [[UIApplication sharedApplication]
                       beginBackgroundTaskWithName:@"backgroundTask"
                       expirationHandler:^{
                           watchKitHandler = UIBackgroundTaskInvalid;
                       }];
    [self fetchData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC * 5), dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        completionHandler(UIBackgroundFetchResultNewData);
        [[UIApplication sharedApplication] endBackgroundTask:watchKitHandler];
    });
}

-(void)fetchData{
    NSString *userId = [[SFUserAccountManager sharedInstance] currentUser].credentials.userId;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDate *lastFetchTime = [defaults objectForKey:@"LAST_FETCH_TIME"];
    if(lastFetchTime == nil){
        NSDate* date = [NSDate date];
        [defaults setObject:date forKey:@"LAST_FETCH_TIME"];
        [defaults synchronize];
    }
    
    ReferenceHandler *refHandler =[ReferenceHandler alloc];
    [refHandler loadNotifyMeSetting:userId];
}
-(void) fetchSetting:(NSString*) userId{
    ReferenceHandler *refHandler =[ReferenceHandler alloc];
    [refHandler fetchSettings:userId];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler{
}
@end
