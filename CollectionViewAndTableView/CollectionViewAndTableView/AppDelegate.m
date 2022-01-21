//
//  AppDelegate.m
//  CollectionViewAndTableView
//
//  Created by 家濠 on 2022/1/20.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [UIWindow new];
    
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:[ViewController new]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}


@end
