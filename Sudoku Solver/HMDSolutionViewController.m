//
//  HMDSolutionViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 1/26/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDSolutionViewController.h"
#import "HMDSudokuCell.h"

#import <QuartzCore/QuartzCore.h>

@interface HMDSolutionViewController ()

@property (nonatomic, copy) NSArray *solution;

@end

@implementation HMDSolutionViewController

- (instancetype)initWithSolution:(NSArray *)solution
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        
        _solution = solution;
    }
    
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSolutionBoard];
    
}


- (void)setupSolutionBoard
{
    if ([self.solution count] != 81) {
        NSLog(@"Solution incorrect length");
        return;
    }
    
    CGFloat labelSize = 30.0;
    
    CGFloat xStartPosition = ([UIScreen mainScreen].bounds.size.width - (labelSize * 9)) / 2.0;
    CGFloat yStartPosition = ([UIScreen mainScreen].bounds.size.height / 2.0) - (labelSize * 4.5);
    
    CGFloat xPosition = xStartPosition;
    CGFloat yPosition = yStartPosition;
    
    for (int i = 1; i <= 81; i++) {
        
        UILabel *cell = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, yPosition, labelSize, labelSize)];
        
        cell.textAlignment = NSTextAlignmentCenter;
        cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.layer.borderWidth = 0.5f;
        
        if ((i > 18 && i < 28) || (i > 45 && i < 55)) {
            CALayer *bottomBorder = [CALayer layer];
            
            bottomBorder.borderColor = [UIColor blackColor].CGColor;
            bottomBorder.borderWidth = 2.0f;
            bottomBorder.frame = CGRectMake(0.0f, labelSize, labelSize, 1.0f);
            
            [cell.layer addSublayer:bottomBorder];
        }
        
        if ((i % 3 == 0 || i % 6 == 0) && i % 9 != 0) {
            CALayer *rightBorder = [CALayer layer];
            
            rightBorder.borderColor = [UIColor blackColor].CGColor;
            rightBorder.borderWidth = 2.0f;
            rightBorder.frame = CGRectMake(labelSize, 0.0f, 2.0f, labelSize);
            
            [cell.layer addSublayer:rightBorder];
        }
        
        
        NSNumber *answer = self.solution[i - 1];
        
        if ([answer integerValue] == 0) {
            cell.text = @"";
        } else {
            cell.text = [answer stringValue];
        }
        
        [self.view addSubview:cell];
        
        xPosition += labelSize;
        
        if (i % 9 == 0) {
            yPosition += labelSize;
            xPosition = xStartPosition;
        }
        
    }
    
    
}




- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}






@end
