//
//  HMDBoardPickerViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 1/26/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "HMDBoardPickerViewController.h"
#import "HMDSolutionViewController.h"
#import "HMDQuadrantView.h"
#import "HMDSudokuCell.h"
#import "HMDCellCoordinates.h"
#import "HMDSudokuTree.h"
#import "HMDSudokuTreeNode.h"
#import "HMDPossibleAnswer.h"
#import "MBProgressHUD.h"
#import "HMDSolver.h"

const CGFloat PICKER_VIEW_ANIMATION_DURATION = 0.4;

@interface HMDBoardPickerViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *solveButton;


// Picker view

@property (nonatomic, strong) HMDQuadrantView *currentQuadrantView;
@property (strong, nonatomic) IBOutlet UIView *pickerContainerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic) BOOL pickerPresented;

@property (nonatomic, strong) UIView *clearLayer;
@property (nonatomic, weak) UILabel *currentlySelectedLabel;
@property (nonatomic, strong) NSArray *numbersForPickerData;

@property (nonatomic, strong) NSMutableArray *pickerInternalSudokuBoard;

// Solver

@property (nonatomic, strong) HMDSolver *solver;
@property (nonatomic, copy) NSString *startingNumbers;
@end

@implementation HMDBoardPickerViewController


#pragma mark - View life cycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _numbersForPickerData = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:253/255.0 green:245/255.0 blue:230/255.0 alpha:1.0];
    [self presentQuadrantViewForQuadrant:1 fromDirection:NoDirection];
    [self setupSwipeGesturesForQuadrantView];
    [self setupClearLayer];
    [self setupPickerContainerView];
    
    
    //self.startingNumbers = @"000260701680070090190004500820100040004602900050003028009300074040050036703018000";
    //self.startingNumbers = @"031200700040080019006000000007040001014090560800050400000000900260030040005008270";
    //self.startingNumbers = @"607039005400060009503000082069004103000010000304700560840000206900020001100980704";
    //self.startingNumbers = @"000502800400010090005000300370850000600000004000029053006000400040070002003406000";
    //self.startingNumbers = @"610700800000000000084095037750004300000060000001900076340150720000000000008002014";
    //self.startingNumbers = @"500600400800030002030009600003507000400000001000302700002800040300060007004001006";
    
    //Hard Level Puzzles
    //self.startingNumbers = @"700900020000007003190520000000200870006000200079005000000012046300700000080004001"; // solved with logic
    //self.startingNumbers = @"386007190007008004001000000003080000050020060000050200000000900800300600092800573"; // solved with logic
    //self.startingNumbers = @"760100000108000002005060007804600000020901070000005201900080600200000704000006038"; // 681 without, 63 with
    //self.startingNumbers = @"900006000000091408380000200005009004007080300600100900009000027803650000000900005"; // 201 without, 782 with
    //self.startingNumbers = @"000670050080000009070980100052403800000000000003507690005039010300000080010052000"; // Tested one
    
    //Evil Level Puzzles
    //self.startingNumbers = @"700060300000500000090300875100600000004050200000008007436007090000006000001080006"; // 3,291 without, 4,200 with
    //self.startingNumbers = @"592001000000500000470002050000250008200000005300076000060100072000008000000700134"; // 5,000 without, 15,000 with
    self.startingNumbers = @"000500048020040007530000960000780000009000400000056000013000025600010070890005000"; // 35,000 without, 6,587 with
    //self.startingNumbers = @"800730000000500186005090000057000000690000014000000690000020800963007000000054003"; // 6417 without, 27873 with, 22487 with sorted smallest first
    //self.startingNumbers = @"060001007400783000000000100300200070001070600070005002002000000000367004800400010"; // 8680 without, 8070 with, 8803 with sorted smallest first (23:90 32-bit) (19:90 64-bit)
    //self.startingNumbers = @"002000039604000870000070400020100000500302008000009020007050000059000601130000200"; // 3249 without, 3676 with, 34629 with sorted smallest first
    //self.startingNumbers = @"103500040009000006000096300870000503000000000401000027004670000300000200020001708"; // 3982 without (14:33 32-bit) (11:71 64-bit), 7204 with (23:20 32-bit) (17:50 64-bit), 1199 with sorted smallest first (6:25 32-bit)
    //self.startingNumbers = @"003004000500871000208000000800050010006030900070040002000000307000419006000300400"; // 1375 without, 1876 with, 6658 with sorted smallest first
    //self.startingNumbers = @"700096001094500000000000260200064700000000000005720006028000000000001930900250004"; // 6877 without, 20819 with

}


#pragma mark - Setup input board

- (void)presentQuadrantViewForQuadrant:(NSInteger)quadrant fromDirection:(Direction)direction
{
    CGFloat xStart;
    CGFloat yStart;

    switch (direction) {
        case LeftDirection:
            xStart = [[UIScreen mainScreen] bounds].size.width;
            yStart = 0.0f;
            break;
            
        case RightDirection:
            xStart = -[[UIScreen mainScreen] bounds].size.width;
            yStart = 0.0f;
            break;
            
        case UpDirection:
            xStart = 0.0f;
            yStart = [[UIScreen mainScreen] bounds].size.height;
            break;
            
        case DownDirection:
            xStart = 0.0f;
            yStart = -[[UIScreen mainScreen] bounds].size.height;
            break;
            
        default:
            xStart = 0.0f;
            yStart = 0.0f;
            break;
    }
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height - 100.0f;
    
    HMDQuadrantView *quadrantView = [[HMDQuadrantView alloc] initWithFrame:CGRectMake(xStart, yStart, width, height)];
    
    
    quadrantView.backgroundColor = [UIColor colorWithRed:253/255.0 green:245/255.0 blue:230/255.0 alpha:1.0];
    quadrantView.quadrant = quadrant;
    
    
    CGFloat labelOffset = 10.0f;
    CGFloat labelSize = ([[UIScreen mainScreen] bounds].size.width - (labelOffset * 2.0)) / 3.0;
    
    CGFloat xStartPosition = labelOffset;
    CGFloat yStartPosition = ([[UIScreen mainScreen] bounds].size.height / 2.0) - (1.5 * labelSize);
    
    CGFloat xPosition = xStartPosition;
    CGFloat yPosition = yStartPosition;
    
    for (NSInteger i = 1; i <= 9; i++) {
        UILabel *cell = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, yPosition, labelSize, labelSize)];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentNumberPicker:)];
        tap.numberOfTouchesRequired = 1;
        [cell addGestureRecognizer:tap];
        cell.userInteractionEnabled = YES;
        
        cell.backgroundColor = [UIColor whiteColor];
        cell.layer.borderWidth = 1.0f;
        cell.layer.borderColor = [UIColor grayColor].CGColor;
        
        cell.textAlignment = NSTextAlignmentCenter;
        cell.font = [UIFont fontWithName:@"quicksand-light" size:45];
        
        [quadrantView addSubview:cell];
        
        xPosition += labelSize;
        
        if (i % 3 == 0) {
            xPosition = xStartPosition;
            yPosition += labelSize;
        }
        
    }
    CGFloat quadrantIndicatorSize = 30.0f;
    
    UIImageView *quadrantIndicator = [[UIImageView alloc] init];
    
    quadrantIndicator.image = [self indicatorImageForQuadrant:quadrant];
    quadrantIndicator.frame = CGRectMake(width - labelOffset - quadrantIndicatorSize, height - quadrantIndicatorSize, quadrantIndicatorSize, quadrantIndicatorSize);
    
    [quadrantView addSubview:quadrantIndicator];

    [self.view addSubview:quadrantView];
    
    HMDQuadrantView *buffer = self.currentQuadrantView;

    self.solveButton.alpha = 0.0;
    
    [UIView animateWithDuration:0.75 delay:0.0 usingSpringWithDamping:0.65 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.currentQuadrantView.frame = CGRectMake(-xStart, -yStart, width, height);
        quadrantView.frame = CGRectMake(0.0f, 0.0f, width, height);
        
    }completion:^(BOOL finished) {
        [buffer removeFromSuperview];
    }];
    self.solveButton.alpha = 1.0;

    self.currentQuadrantView = quadrantView;
}

- (UIImage *)indicatorImageForQuadrant:(NSInteger)quadrant
{
    switch (quadrant) {
        case 1:
            return [UIImage imageNamed:@"Quadrant1"];
            break;
            
        case 2:
            return [UIImage imageNamed:@"Quadrant2"];
            break;
            
        case 3:
            return [UIImage imageNamed:@"Quadrant3"];
            break;
            
        case 4:
            return [UIImage imageNamed:@"Quadrant4"];
            break;
            
        case 5:
            return [UIImage imageNamed:@"Quadrant5"];
            break;
            
        case 6:
            return [UIImage imageNamed:@"Quadrant6"];
            break;
            
        case 7:
            return [UIImage imageNamed:@"Quadrant7"];
            break;
            
        case 8:
            return [UIImage imageNamed:@"Quadrant8"];
            break;
            
        case 9:
            return [UIImage imageNamed:@"Quadrant9"];
            break;
            
        default:
            return [UIImage imageNamed:@"Quadrant1"];
            break;
    }
}

- (void)setupSwipeGesturesForQuadrantView
{
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeFromQuadrant)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeFromQuadrant)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upSwipeFromQuadrant)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(downSwipeFromQuadrant)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:leftSwipe];
    [self.view addGestureRecognizer:rightSwipe];
    [self.view addGestureRecognizer:upSwipe];
    [self.view addGestureRecognizer:downSwipe];
}

#pragma mark - Quadrant view navigation

- (void)leftSwipeFromQuadrant
{
    NSInteger currentQuadrant = self.currentQuadrantView.quadrant;
    
    if (currentQuadrant == 3 || currentQuadrant == 6 || currentQuadrant == 9) {
        return;
    } else {
        if (self.pickerPresented) {
            [self dismissPicker:nil];
        }
        [self presentQuadrantViewForQuadrant:(currentQuadrant + 1) fromDirection:LeftDirection];
    }
}

- (void)rightSwipeFromQuadrant
{
    NSInteger currentQuadrant = self.currentQuadrantView.quadrant;
    
    if (currentQuadrant == 1 || currentQuadrant == 4 || currentQuadrant == 7) {
        return;
    } else {
        if (self.pickerPresented) {
            [self dismissPicker:nil];
        }
        [self presentQuadrantViewForQuadrant:(currentQuadrant - 1) fromDirection:RightDirection];
    }
}

- (void)upSwipeFromQuadrant
{
    NSInteger currentQuadrant = self.currentQuadrantView.quadrant;
    
    if (currentQuadrant == 7 || currentQuadrant == 8 || currentQuadrant == 9) {
        return;
    } else {
        if (self.pickerPresented) {
            [self dismissPicker:nil];
        }
        [self presentQuadrantViewForQuadrant:(currentQuadrant + 3) fromDirection:UpDirection];
    }
}

- (void)downSwipeFromQuadrant
{
    NSInteger currentQuadrant = self.currentQuadrantView.quadrant;
    
    if (currentQuadrant == 1 || currentQuadrant == 2 || currentQuadrant == 3) {
        return;
    } else {
        if (self.pickerPresented) {
            [self dismissPicker:nil];
        }
        [self presentQuadrantViewForQuadrant:(currentQuadrant - 3) fromDirection:DownDirection];
    }
}


#pragma mark - Input board methods

- (void)presentNumberPicker:(UITapGestureRecognizer *)sender
{
    self.currentlySelectedLabel = (UILabel *)sender.view;
    
    CGFloat initialWidth = self.currentlySelectedLabel.frame.size.width;
    CGFloat initialHeight = self.currentlySelectedLabel.frame.size.height;
    
    CGFloat initialXPosition = self.currentlySelectedLabel.frame.origin.x;
    CGFloat initialYPosition = self.currentlySelectedLabel.frame.origin.y;
    
    self.pickerContainerView.frame = CGRectMake(initialXPosition, initialYPosition, initialWidth, initialHeight);
    
    [self.view addSubview:self.clearLayer];
    [self.view addSubview:self.pickerContainerView];
    
    CGFloat pickerViewWidth = 216.0f;
    CGFloat pickerViewHeight = 216.0f;
    
    CGFloat pickerViewSideOffset = ([[UIScreen mainScreen] bounds].size.width - pickerViewWidth) / 2.0;
    
    CGFloat pickerViewXPosition = pickerViewSideOffset;
    CGFloat pickerViewYPosition = ([[UIScreen mainScreen] bounds].size.height / 2.0) - (pickerViewHeight / 2.0);
    
    NSInteger selectedRow;
    
    if (self.currentlySelectedLabel.text) {
        selectedRow = [self.currentlySelectedLabel.text integerValue];
    } else {
        selectedRow = 0;
    }
    
    [self cancelAllSwipeGestures];
    [self.pickerView selectRow:selectedRow inComponent:0 animated:NO];
    
    [UIView animateWithDuration:PICKER_VIEW_ANIMATION_DURATION delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:0 animations:^{
        self.pickerContainerView.alpha = 1.0;
        self.pickerContainerView.frame = CGRectMake(pickerViewXPosition, pickerViewYPosition, pickerViewWidth, pickerViewHeight);
        
    } completion:nil];
    
    self.pickerPresented = YES;
    self.doneButton.hidden = NO;
    self.pickerView.hidden = NO;
}

- (void)cancelAllSwipeGestures
{
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
            recognizer.enabled = NO;
        }
    }
}

- (void)reenableAllSwipeGestures
{
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
            recognizer.enabled = YES;
        }
    }
}

- (void)setupClearLayer
{
    self.clearLayer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    self.clearLayer.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPicker:)];
    tap.numberOfTapsRequired = 1;
    tap.cancelsTouchesInView = YES;
    
    [self.clearLayer addGestureRecognizer:tap];
}

- (void)setupPickerContainerView
{
    self.pickerContainerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.pickerContainerView.layer.borderColor = [UIColor grayColor].CGColor;
    self.pickerContainerView.layer.borderWidth = 0.3f;
    self.pickerContainerView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.pickerContainerView.layer.shadowOpacity = 0.8;
    self.pickerContainerView.layer.shadowRadius = 2.0f;
    self.pickerContainerView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
}

- (IBAction)dismissPicker:(id)sender
{
    CGFloat finalWidth = self.currentlySelectedLabel.frame.size.width;
    CGFloat finalHeight = self.currentlySelectedLabel.frame.size.height;
    
    CGFloat finalXPosition = self.currentlySelectedLabel.frame.origin.x;
    CGFloat finalYPosition = self.currentlySelectedLabel.frame.origin.y;
    
    self.pickerView.hidden = YES;
    self.doneButton.hidden = YES;
    
    [self reenableAllSwipeGestures];
    [UIView animateKeyframesWithDuration:PICKER_VIEW_ANIMATION_DURATION delay:0.0 options:0 animations:^{
        self.pickerContainerView.frame = CGRectMake(finalXPosition, finalYPosition, finalWidth, finalHeight);
        self.pickerContainerView.alpha = 0.1;
        
    }completion:^(BOOL finished) {
        self.doneButton.enabled = NO;
        [self.pickerContainerView removeFromSuperview];
    }];
    
    self.pickerPresented = NO;
    self.currentlySelectedLabel = nil;
    [self.clearLayer removeFromSuperview];
}


#pragma mark - UIPickerView delegate/datasource methods


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.numbersForPickerData count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.numbersForPickerData[row] stringValue];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    
    label.text = [self.numbersForPickerData[row] stringValue];
    label.font = [UIFont fontWithName:@"quicksand-light" size:30];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.doneButton.enabled = YES;
    NSNumber *number = self.numbersForPickerData[row];
    
    if ([number integerValue] == 0) {
        self.currentlySelectedLabel.text = nil;
    } else {
        self.currentlySelectedLabel.text = [number stringValue];
    }
    
}

#pragma mark - Printing solution

- (void)fillPickerInternalSudokuBoard
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    self.pickerInternalSudokuBoard = [[NSMutableArray alloc] init];
    // Setup the internalSudokuBoard
    for (NSInteger row = 0; row < 9; row++) {
        NSMutableArray *column = [[NSMutableArray alloc] init];
        [self.pickerInternalSudokuBoard insertObject:column atIndex:row];
    }
    
    // Filling the internalSudokuBoard from initial numbers
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            NSNumber *answer = [numberFormatter numberFromString:[self.startingNumbers substringToIndex:1]];
            HMDSudokuCell *cell = [[HMDSudokuCell alloc] initWithAnswer:answer possibleAnswers:nil];
            [self.pickerInternalSudokuBoard addObject:answer];
            
            [self.pickerInternalSudokuBoard[row] insertObject:cell atIndex:column];
            self.startingNumbers = [self.startingNumbers substringFromIndex:1];
        }
    }
}

- (void)printBoardWithSolution:(NSArray *)solution andTimeToSolve:(double)timeToSolve
{
    HMDSolutionViewController *solutionViewController = [[HMDSolutionViewController alloc] initWithSolution:solution originalBoard:[self.pickerInternalSudokuBoard copy] andTimeToSolve:timeToSolve];
    [self presentViewController:solutionViewController animated:YES completion:nil];
}


- (IBAction)solveButton:(id)sender
{
    [self fillPickerInternalSudokuBoard];
    self.solver = [[HMDSolver alloc] init];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Solving..";
    hud.labelFont = [UIFont fontWithName:@"quicksand-regular" size:20];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDate *startTime = [NSDate date];
        NSArray *solution = [self.solver solvePuzzleWithStartingNumbers:self.pickerInternalSudokuBoard];
        NSLog(@"Solution: %@", solution);
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSDate *endTime = [NSDate date];
            NSTimeInterval timeToSolve = [endTime timeIntervalSinceDate:startTime];
            
            if (solution) {
                [self printBoardWithSolution:solution andTimeToSolve:timeToSolve];
                self.solver = nil;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
            } else {
                //error message for incorrect starting puzzle
            }
            
        });
    });

}

- (void)didReceiveMemoryWarning
{
    NSLog(@"Received memory warning");
}


@end
