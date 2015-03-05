//
//  HMDBoardPickerViewController.h
//  Sudoku Solver
//
//  Created by Trent You on 1/26/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Direction) {
    NoDirection,
    LeftDirection,
    RightDirection,
    UpDirection,
    DownDirection
};

@interface HMDBoardPickerViewController : UIViewController

@end
