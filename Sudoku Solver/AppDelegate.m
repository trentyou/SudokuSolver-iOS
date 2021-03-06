//
//  AppDelegate.m
//  Sudoku Solver
//
//  Created by Trent You on 1/26/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "AppDelegate.h"
#import "HMDBoardPickerViewController.h"
#import "HMDMainMenuViewController.h"

#import "UIColor+_SudokuSolver.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *userDefaultsDefaults = @{ @"isFirstLaunch" : [NSNumber numberWithBool:YES] };
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
    
    HMDMainMenuViewController *mainMenu = [[HMDMainMenuViewController alloc] init];
    
    UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:mainMenu];
    self.window.rootViewController = mainNav;
    [self.window makeKeyAndVisible];
    
    //UIPageViewController dot customization
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    pageControl.backgroundColor = [UIColor lightBeigeColor];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
