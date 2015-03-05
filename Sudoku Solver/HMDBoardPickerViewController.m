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



// Solving ivars
@property (nonatomic, strong) NSMutableArray *internalSudokuBoard;
@property (nonatomic, strong) NSMutableArray *internalSudokuBoardCopy;

@property (nonatomic, strong) NSMutableArray *originalBoard;

@property (nonatomic, strong) NSMutableArray *listOfCellsToGuess;


@property (nonatomic, strong) HMDSudokuTree *sudokuTree;

@property (nonatomic, copy) NSString *startingNumbers;

@property (nonatomic) BOOL solved;

@end

@implementation HMDBoardPickerViewController

static NSNumberFormatter *numberFormatter;

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
    
    if (!numberFormatter) numberFormatter = [[NSNumberFormatter alloc] init];
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
    self.startingNumbers = @"000670050080000009070980100052403800000000000003507690005039010300000080010052000"; // Tested one
    
    //Evil Level Puzzles
    //self.startingNumbers = @"700060300000500000090300875100600000004050200000008007436007090000006000001080006"; // 3,291 without, 4,200 with
    //self.startingNumbers = @"592001000000500000470002050000250008200000005300076000060100072000008000000700134"; // 5,000 without, 15,000 with
    //self.startingNumbers = @"000500048020040007530000960000780000009000400000056000013000025600010070890005000"; // 35,000 without, 6,587 with
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

#pragma mark - Initial board setup

- (void)setupInternalSudokuBoard:(NSString *)startingNumbers
{
    if (!self.internalSudokuBoard) {
        self.internalSudokuBoard = [[NSMutableArray alloc] init];
        self.originalBoard = [[NSMutableArray alloc] init];
    }
    
    // Setup the internalSudokuBoard
    for (NSInteger row = 0; row < 9; row++) {
        NSMutableArray *column = [[NSMutableArray alloc] init];
        [self.internalSudokuBoard insertObject:column atIndex:row];
    }
    
    // Filling the internalSudokuBoard from initial numbers
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            NSNumber *answer = [numberFormatter numberFromString:[startingNumbers substringToIndex:1]];
            HMDSudokuCell *cell = [[HMDSudokuCell alloc] initWithAnswer:answer possibleAnswers:nil];
            [self.originalBoard addObject:answer];
            
            [self.internalSudokuBoard[row] insertObject:cell atIndex:column];
            startingNumbers = [startingNumbers substringFromIndex:1];
        }
    }
    
    //[self printBoard];
    [self fillPossibleAnswers];
    [self solveBoard];
    
}

- (void)fillPossibleAnswers
{
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
            NSNumber *answer = cell.answer;
            
            if ([answer integerValue] == 0) {
                NSMutableArray *possibleAnswers = [[NSMutableArray alloc] init];
                
                for (NSInteger number = 1; number <= 9; number++) {
                    if ([self checkValidPlacementOfAnswer:number inRow:row andColumn:column]) {
                        HMDPossibleAnswer *possibleAnswer = [[HMDPossibleAnswer alloc] init];
                        possibleAnswer.answer = number;
                        [possibleAnswers addObject:possibleAnswer];
                    }
                }
                
                cell.possibleAnswers = possibleAnswers;
            }
        }
    }
}

#pragma mark - Utility methods for checking number placement

- (void)updatePossibleAnswers
{
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
            NSNumber *answer = cell.answer;
            
            if ([answer integerValue] == 0) {
                
                NSArray *possibleAnswers = [cell.possibleAnswers copy];
                
                for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                    
                    if (![self checkValidPlacementOfAnswer:possibleAnswer.answer inRow:row andColumn:column]) {
                        [cell.possibleAnswers removeObject:possibleAnswer];
                    }
                }
            }
        }
    }
}

- (void)updatePossibleAnswersInRow:(NSInteger)inputRow andColumn:(NSInteger)inputColumn forAnswer:(NSInteger)answer
{
    
    for (NSInteger column = inputColumn + 1; column < 9; column++) {
        HMDSudokuCell *cell = self.internalSudokuBoard[inputRow][column];
        
        if ([cell.answer integerValue] == 0) {
            for (HMDPossibleAnswer *possibleAnswer in cell.possibleAnswers) {
                if (possibleAnswer.answer == answer) {
                    [cell.possibleAnswers removeObject:possibleAnswer];
                    break;
                }
            }
        }
    }
    
    for (NSInteger row = inputRow + 1; row < 9; row++) {
        HMDSudokuCell *cell = self.internalSudokuBoard[row][inputColumn];
        
        if ([cell.answer integerValue] == 0) {
            for (HMDPossibleAnswer *possibleAnswer in cell.possibleAnswers) {
                if (possibleAnswer.answer == answer) {
                    [cell.possibleAnswers removeObject:possibleAnswer];
                    break;
                }
            }
        }
    }
    
    NSInteger rowMin;
    NSInteger rowMax;
    
    NSInteger columnMin;
    NSInteger columnMax;
    
    switch ([self getQuadrantFromRow:inputRow andColumn:inputColumn]) {
        case 1:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 2:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 3:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
        case 4:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 5:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 6:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
        case 7:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 8:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 9:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
            
        default:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 0;
            columnMax = 2;
            break;
    }
    
    
    for (NSInteger row = inputRow + 1; row <= rowMax; row++) {
        for (NSInteger column = columnMin; column <= columnMax; column++) {
            HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
            
            if ([cell.answer integerValue] == 0) {
                for (HMDPossibleAnswer *possibleAnswer in cell.possibleAnswers) {
                    if (possibleAnswer.answer == answer) {
                        [cell.possibleAnswers removeObject:possibleAnswer];
                        break;
                    }
                }
            }
        }
    }
}

- (void)updatePossibleAnswersForCellsToGuess
{
    for (HMDCellCoordinates *coordinates in self.listOfCellsToGuess) {
        HMDSudokuCell *cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
        
        if ([cell.answer integerValue] == 0) {
            NSArray *possibleAnswers = [cell.possibleAnswers copy];
            
            for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                
                if (![self checkValidPlacementOfAnswer:possibleAnswer.answer inRow:coordinates.row andColumn:coordinates.column]) {
                    [cell.possibleAnswers removeObject:possibleAnswer];
                }
            }

        }
        
    }
}

- (void)restorePossibleAnswersForCellsToGuess
{
    for (HMDCellCoordinates *coordinates in self.listOfCellsToGuess) {
        HMDSudokuCell *cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
        
        if ([cell.answer integerValue] == 0) {
            NSMutableArray *possibleAnswers = [[NSMutableArray alloc] init];
            
            for (NSInteger number = 1; number <= 9; number++) {
                if ([self checkValidPlacementOfAnswer:number inRow:coordinates.row andColumn:coordinates.column]) {
                    HMDPossibleAnswer *possibleAnswer = [[HMDPossibleAnswer alloc] init];
                    possibleAnswer.answer = number;
                    [possibleAnswers addObject:possibleAnswer];
                }
            }
            
            cell.possibleAnswers = possibleAnswers;
        }
    }
    
}

- (NSInteger)instancesOfAnswerInRowColumnAndQuadrant:(NSInteger)answer inRow:(NSInteger)row andColumn:(NSInteger)column
{
    
    NSInteger columnCount = [self instancesOfAnswerInColumn:column inRow:row forAnswer:answer];
    NSInteger rowCount = [self instancesOfAnswerInRow:row inColumn:column forAnswer:answer];
    NSInteger quadrantCount = [self instancesOfAnswerInQuadrantFromRow:row inColumn:column forAnswer:answer];

    
    return columnCount + rowCount + quadrantCount;
}

- (NSInteger)instancesOfAnswerInQuadrantFromRow:(NSInteger)inputRow inColumn:(NSInteger)inputColumn forAnswer:(NSInteger)answer
{
    NSInteger count = 0;
    
    NSInteger rowMin;
    NSInteger rowMax;
    
    NSInteger columnMin;
    NSInteger columnMax;
    
    switch ([self getQuadrantFromRow:inputRow andColumn:inputColumn]) {
        case 1:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 2:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 3:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
        case 4:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 5:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 6:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
        case 7:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 8:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 9:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
            
        default:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 0;
            columnMax = 2;
            break;
    }
    
    
    for (NSInteger row = rowMin; row <= rowMax; row++) {
        for (NSInteger column = columnMin; column <= columnMax; column++) {
            if (row != inputRow && column != inputColumn) {
                HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
                
                if ([cell.answer integerValue] == 0) {
                    NSArray *possibleAnswers = [cell.possibleAnswers copy];

                    for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                        if (possibleAnswer.answer == answer) {
                            count++;
                        }
                    }
                }
            }
            
        }
    }
    
    return count;
}

- (NSInteger)instancesOfAnswerInRow:(NSInteger)inputRow inColumn:(NSInteger)inputColumn forAnswer:(NSInteger)answer
{
    NSInteger count = 0;
    
    for (NSInteger column = 0; column < 9; column++) {
        if (column != inputColumn) {
            HMDSudokuCell *cell = self.internalSudokuBoard[inputRow][column];
            
            if ([cell.answer integerValue] == 0) {
                NSArray *possibleAnswers = [cell.possibleAnswers copy];

                for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                    if (possibleAnswer.answer == answer) {
                        count++;
                    }
                }
            }
        }
    }
    
    return count;
}

- (NSInteger)instancesOfAnswerInColumn:(NSInteger)inputColumn inRow:(NSInteger)inputRow forAnswer:(NSInteger)answer
{
    NSInteger count = 0;
    
    for (NSInteger row = 0; row < 9; row++) {
        if (row != inputRow) {
            HMDSudokuCell *cell = self.internalSudokuBoard[row][inputColumn];
            
            if ([cell.answer integerValue] == 0) {
                NSArray *possibleAnswers = [cell.possibleAnswers copy];

                for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                    if (possibleAnswer.answer == answer) {
                        count++;
                    }
                }
            }
        }
    }
    
    return count;
}

- (BOOL)checkValidPlacementOfAnswer:(NSInteger)answer inRow:(NSInteger)row andColumn:(NSInteger)column
{
    if (![self checkColumnForAnswer:answer inRow:row andColumn:column] && ![self checkRowForAnswer:answer inRow:row andColumn:column] && ![self checkQuadrantForAnswer:answer inRow:row andColumn:column]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)checkColumnForAnswer:(NSInteger)answer inRow:(NSInteger)inputRow andColumn:(NSInteger)inputColumn
{
    for (NSInteger row = 0; row < 9; row++) {
        if (row != inputRow) {
            HMDSudokuCell *cell = self.internalSudokuBoard[row][inputColumn];
            NSNumber *cellAnswer = cell.answer;
            
            if ([cellAnswer integerValue] == answer) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)checkRowForAnswer:(NSInteger)answer inRow:(NSInteger)inputRow andColumn:(NSInteger)inputColumn
{
    for (NSInteger column = 0; column < 9; column++) {
        if (column != inputColumn) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[inputRow][column];
            NSNumber *cellAnswer = cell.answer;
            
            if ([cellAnswer integerValue] == answer) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSInteger)getQuadrantFromRow:(NSInteger)row andColumn:(NSInteger)column
{
    if (row <= 2) {
        return (column / 3) + 1;
    } else if (row > 2 && row < 6) {
        return (column / 3) + 4;
    } else {
        return (column / 3) + 7;
    }
}

- (BOOL)checkQuadrantForAnswer:(NSInteger)answer inRow:(NSInteger)inputRow andColumn:(NSInteger)inputColumn
{
    NSInteger rowMin;
    NSInteger rowMax;
    
    NSInteger columnMin;
    NSInteger columnMax;
    
    switch ([self getQuadrantFromRow:inputRow andColumn:inputColumn]) {
        case 1:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 2:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 3:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
        case 4:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 5:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 6:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
        case 7:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 8:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 9:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
            
        default:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 0;
            columnMax = 2;
            break;
    }
    
    
    for (NSInteger row = rowMin; row <= rowMax; row++) {
        for (NSInteger column = columnMin; column <= columnMax; column++) {
            if (row != inputRow && column != inputColumn) {
                
                HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
                NSNumber *cellAnswer = cell.answer;
                
                if ([cellAnswer integerValue] == answer) {
                    return YES;
                }
            }

        }
    }
    
    
    return NO;
    
}

- (BOOL)subGroupExclusionCheck
{
    BOOL changed = NO;
    
    for (NSInteger row = 0; row < 7; row += 3) {
        for (NSInteger column = 0; column < 7; column += 3) {
            
            for (NSInteger answer = 1; answer <= 9; answer++) {
                
                NSInteger occurenceCount = 0;
                NSInteger rowCoordinateOfOccurence = 0;
                NSInteger columnCoordinateOfOccurence = 0;
                
                for (NSInteger quadrantRow = 0; quadrantRow <= 2; quadrantRow++) {
                    for (NSInteger quadrantColumn = 0; quadrantColumn <= 2; quadrantColumn++) {
                        
                        HMDSudokuCell *cell = self.internalSudokuBoard[row + quadrantRow][column + quadrantColumn];
                        NSMutableArray *possibleAnswers = cell.possibleAnswers;
                        
                        for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                            if (possibleAnswer.answer == answer) {
                                occurenceCount++;
                                rowCoordinateOfOccurence = row + quadrantRow;
                                columnCoordinateOfOccurence = column + quadrantColumn;
                            }
                        }
                    }
                }
                
                if (occurenceCount == 1) {
                    HMDSudokuCell *cell = self.internalSudokuBoard[rowCoordinateOfOccurence][columnCoordinateOfOccurence];
                    cell.answer = [NSNumber numberWithInteger:answer];
                    [cell.possibleAnswers removeAllObjects];
                    changed = YES;

                    [self updatePossibleAnswers];
                }
            }
        }
    }
    
    return changed;
}

#pragma mark - Solving board

- (BOOL)isSolved
{
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
            if ([cell.answer integerValue] == 0) return NO;
            
            if (![self checkValidPlacementOfAnswer:[cell.answer integerValue] inRow:row andColumn:column]) return NO;
            
        }
    }
    
    return YES;
}


- (void)resetBoard
{
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoardCopy[row][column];
            HMDSudokuCell *cellCopy = [cell copyWithZone:nil];
            
            self.internalSudokuBoard[row][column] = cellCopy;
        }
    }
}


- (void)solveBoard
{
    BOOL changed;
    static NSInteger logicLoopCount = 0;
    
    do {
        changed = NO;
        
        for (NSInteger row = 0; row < 9; row++) {
            for (NSInteger column = 0; column < 9; column++) {
                
                HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
                NSNumber *answer = cell.answer;
                
//                NSLog(@"Row: %ld", (long)row);
//                NSLog(@"Column %ld", (long)column);
//                NSLog(@"cell.possibleAnswers before: %@", cell.possibleAnswers);

                if ([answer integerValue] == 0 && [cell.possibleAnswers count] == 1) {
                    
                    HMDPossibleAnswer *possibleAnswer = [cell.possibleAnswers firstObject];
                    cell.answer = [NSNumber numberWithInteger:possibleAnswer.answer];
                    [cell.possibleAnswers removeAllObjects];
//                    NSLog(@"cell.possibleAnswers after: %@", cell.possibleAnswers);

                    [self updatePossibleAnswers];
                    
                    changed = YES;
                }
            }
        }
        
        if (changed == NO) changed = [self subGroupExclusionCheck];
        logicLoopCount++;
        
    } while (changed);

    
    NSLog(@"Number of logic loops: %ld", (long)logicLoopCount);
    
    if ([self isSolved]) {
        return;
    }
    
    [self setupTree];
    self.solved = [self treeTraverseGuess:self.sudokuTree.root];
}

- (void)sortListOfCellsToGuess
{
    for (NSInteger i = 0; i < [self.listOfCellsToGuess count] - 1; i++) {
        HMDCellCoordinates *coordinates = self.listOfCellsToGuess[i];
        HMDSudokuCell *cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
        
        NSInteger min = [cell.possibleAnswers count];
        NSInteger minIndex = i;

        for (NSInteger j = i + 1; j < [self.listOfCellsToGuess count]; j++) {
            
            coordinates = self.listOfCellsToGuess[j];
            cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
            
            if (min > [cell.possibleAnswers count]) {
                min = [cell.possibleAnswers count];
                minIndex = j;
            }
            
        }
        HMDCellCoordinates *temp = self.listOfCellsToGuess[i];
        
        self.listOfCellsToGuess[i] = self.listOfCellsToGuess[minIndex];
        self.listOfCellsToGuess[minIndex] = temp;
        
    }
}

- (void)setupTree
{
    if (!self.listOfCellsToGuess) {
        
        self.listOfCellsToGuess = [[NSMutableArray alloc] init];
        
        for (NSInteger row = 0; row < 9; row++) {
            for (NSInteger column = 0; column < 9; column++) {
                
                HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
                
                if ([cell.answer integerValue] == 0) {
                    HMDCellCoordinates *coordinates = [[HMDCellCoordinates alloc] initWithRowCoordinates:row column:column];
                    [self.listOfCellsToGuess addObject:coordinates];
                }
            }
        }
    }
    
    //[self sortListOfCellsToGuess];

    self.sudokuTree = [[HMDSudokuTree alloc] init];
    HMDSudokuTreeNode *root = [[HMDSudokuTreeNode alloc] init];
    root.parent = nil;
    root.treeLevel = -1;
    
    self.sudokuTree.root = root;
    

}

- (void)evaluateOptimalPossibleAnswerPathForCell:(HMDSudokuCell *)cell inCoordinates:(HMDCellCoordinates *)coordinates
{
    NSMutableArray *possibleAnswers = cell.possibleAnswers;
    
    if ([possibleAnswers count] == 0 || [possibleAnswers count] == 1) {
        return;
    }
    
    for (NSInteger i = 0; i < [possibleAnswers count]; i++) {
        HMDPossibleAnswer *possibleAnswer = possibleAnswers[i];
        possibleAnswer.weight = [self instancesOfAnswerInRowColumnAndQuadrant:possibleAnswer.answer inRow:coordinates.row andColumn:coordinates.column];
    }
    
    for (NSInteger i = 0; i < [possibleAnswers count] - 1; i++) {
        HMDPossibleAnswer *minPossibleAnswer = possibleAnswers[i];
        NSInteger minIndex = i;
        NSInteger min = minPossibleAnswer.weight;
        
        for (NSInteger j = i + 1; j < [possibleAnswers count]; j++) {
            HMDPossibleAnswer *possibleAnswer = possibleAnswers[j];
            if (possibleAnswer.weight < min) {
                min = possibleAnswer.weight;
                minIndex = j;
            }
        }
        
        HMDPossibleAnswer *temp = possibleAnswers[i];
        possibleAnswers[i] = possibleAnswers[minIndex];
        possibleAnswers[minIndex] = temp;
        
    }
    
    NSLog(@"Reordered possible answers for row: %ld column: %ld", (long)coordinates.row, (long)coordinates.column);
    
    for (NSInteger i = 0; i < [possibleAnswers count]; i++) {
        HMDPossibleAnswer *possibleAnswer = possibleAnswers[i];
        NSLog(@"Possible Answer: %ld, Weight: %ld", (long)possibleAnswer.answer, (long)possibleAnswer.weight);
    }
    NSLog(@"\n");
}

- (HMDSudokuTreeNode *)getNextParentNodeWithSibling:(HMDSudokuTreeNode *)parent
{
    while (!parent.nextSibling) {
        parent = parent.parent;
    }
    
    return parent;
}

- (BOOL)treeTraverseGuess:(HMDSudokuTreeNode *)root
{
    HMDSudokuTreeNode *parent = root;
    HMDSudokuTreeNode *nextSibling;
    NSInteger iterationCount = 0;
    
    while ((signed long)parent.treeLevel < (signed long)[self.listOfCellsToGuess count] - 1) {
        iterationCount++;
        
        HMDCellCoordinates *coordinates = self.listOfCellsToGuess[parent.treeLevel + 1];
        HMDSudokuCell *cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
        
        //[self evaluateOptimalPossibleAnswerPathForCell:cell inCoordinates:coordinates];

        NSArray *possibleAnswers = [cell.possibleAnswers copy];
        
        if ([possibleAnswers count] == 0) {
            HMDCellCoordinates *parentCoordinates = self.listOfCellsToGuess[parent.treeLevel];
            HMDSudokuCell *parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column];
            
            if (parent.nextSibling) {
//                NSLog(@"Encountered empty possible answers in treeLevel %ld, moving to sibling", (long)(parent.treeLevel + 1));

                parent.parent.firstChild = parent.nextSibling;
                parent = parent.nextSibling;
                parentCell.answer = [parent.answer copy];
                
//                NSLog(@"New answer: %@ for treeLevel %ld", parentCell.answer, (long)parent.treeLevel);
                [self restorePossibleAnswersForCellsToGuess];
                [self updatePossibleAnswersForCellsToGuess];
                //[self evaluateOptimalPossibleAnswerPathForCell:cell inCoordinates:coordinates];
                
                possibleAnswers = [cell.possibleAnswers copy];
                
//                NSLog(@"--------------------------");
//                NSLog(@"current treeLevel: %ld", (long)parent.treeLevel + 1);
//                NSLog(@"possible answers for treeLevel:");
//                for (NSInteger i = 0; i < [possibleAnswers count]; i++) {
//                    HMDPossibleAnswer *pa = possibleAnswers[i];
//                    NSLog(@"%ld", (long)pa.answer);
//                }
//                NSLog(@"--------------------------");

                
            } else {
//                NSLog(@"Encountered empty possible answers in treeLevel %ld, searching for next higher parent with sibling", (long)(parent.treeLevel + 1));

                NSInteger previousTreeLevel = parent.treeLevel;
                
                parent = [self getNextParentNodeWithSibling:parent];
//                NSLog(@"Coordinates of next parent with sibling, row: %ld, column: %ld", (long)parent.coordinates.row, (long)parent.coordinates.column);
                NSInteger newTreeLevel = parent.treeLevel;
                
                parent.parent.firstChild = parent.nextSibling;
                parent = parent.nextSibling;
                
                
                for (NSInteger level = previousTreeLevel; level > newTreeLevel; level--) {
                    HMDCellCoordinates *coordinatesForCellToReset = self.listOfCellsToGuess[level];
                    HMDSudokuCell *cellToReset = self.internalSudokuBoard[coordinatesForCellToReset.row][coordinatesForCellToReset.column];
                    
                    cellToReset.answer = @0;
                }
                
                parentCoordinates = self.listOfCellsToGuess[newTreeLevel];
                parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column];
                
                parentCell.answer = [parent.answer copy];
//                NSLog(@"New answer: %@ for treeLevel: %ld", parentCell.answer, (long)newTreeLevel);

                [self restorePossibleAnswersForCellsToGuess];
                [self updatePossibleAnswersForCellsToGuess];
                
//                NSLog(@"--------------------------");
//
//                for (NSInteger level = newTreeLevel + 1; level <= previousTreeLevel; level++) {
//                    HMDCellCoordinates *coordinatesForCellToReset = self.listOfCellsToGuess[level];
//                    HMDSudokuCell *cellToReset = self.internalSudokuBoard[coordinatesForCellToReset.row][coordinatesForCellToReset.column];
//                    
//                    NSLog(@"Cell row: %ld, column: %ld", (long)coordinatesForCellToReset.row, (long)coordinatesForCellToReset.column);
//                    NSLog(@"possible answers:");
//                    for (HMDPossibleAnswer *possibleAnswer in cellToReset.possibleAnswers) {
//                        NSLog(@"%ld", (long)possibleAnswer.answer);
//                    }
//                    NSLog(@"\n");
//                }
//                
//                NSLog(@"--------------------------");

                continue;
            }
        }

        
        for (NSInteger i = [possibleAnswers count] - 1; i >= 0; i--) {
            HMDPossibleAnswer *possibleAnswer = possibleAnswers[i];
            HMDSudokuTreeNode *child = [[HMDSudokuTreeNode alloc] init];
            
            child.answer = [NSNumber numberWithInteger:possibleAnswer.answer];
            child.parent = parent;

            child.treeLevel = parent.treeLevel + 1;
            
            HMDCellCoordinates *childCoordinates = self.listOfCellsToGuess[child.treeLevel];
            child.coordinates = childCoordinates;
        
            if (i == 0) {
                parent.firstChild = child;
                child.nextSibling = nextSibling;
                nextSibling = nil;
                
                cell.answer = [NSNumber numberWithInteger:possibleAnswer.answer];
                [cell.possibleAnswers removeAllObjects];
                
                parent = child;
//                NSLog(@"Selected answer:");
                
            } else {
                if (nextSibling) {
                    child.nextSibling = nextSibling;
                } else {
                    child.nextSibling = nil;
                }
                
                nextSibling = child;
            }
            
//            NSLog(@"Node: %@", [child.answer stringValue]);
        }
        //[self updatePossibleAnswers];
        
        HMDCellCoordinates *parentCoordinates = self.listOfCellsToGuess[parent.treeLevel];
        HMDSudokuCell *parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column];

        [self updatePossibleAnswersInRow:parentCoordinates.row andColumn:parentCoordinates.column forAnswer:[parentCell.answer integerValue]];

        
//        NSLog(@"\n");
//        NSLog(@"Tree Level %ld", (long)parent.treeLevel);
//        NSLog(@"--");
//        NSLog(@"\n");
//        NSLog(@"\n");
//        NSLog(@"\n");
//        NSLog(@"--");

    }

    if ([self isSolved]) {
        NSLog(@"SOLVED");
        NSLog(@"Iteration count: %ld", (long)iterationCount);
        self.sudokuTree.root.firstChild = nil;
        return YES;
    } else {
        return NO;
    }
}



- (void)printBoard
{
    NSMutableArray *solution = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[i][j];
            NSNumber *value = cell.answer;
            
            [solution addObject:value];
        }
    }
    
    HMDSolutionViewController *solutionViewController = [[HMDSolutionViewController alloc] initWithSolution:[solution copy] originalBoard:[self.originalBoard copy] andTimeToSolve:0.0];
    [self presentViewController:solutionViewController animated:YES completion:nil];
}

- (void)printBoardWithTimeToSolve:(double)timeToSolve
{
    NSMutableArray *solution = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[i][j];
            NSNumber *value = cell.answer;
            
            [solution addObject:value];
        }
    }
    
    HMDSolutionViewController *solutionViewController = [[HMDSolutionViewController alloc] initWithSolution:[solution copy] originalBoard:[self.originalBoard copy] andTimeToSolve:timeToSolve];
    [self presentViewController:solutionViewController animated:YES completion:nil];
}


- (IBAction)solveButton:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Solving..";
    hud.labelFont = [UIFont fontWithName:@"quicksand-regular" size:20];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDate *startTime = [NSDate date];
        [self setupInternalSudokuBoard:self.startingNumbers];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSDate *endTime = [NSDate date];
            NSTimeInterval timeToSolve = [endTime timeIntervalSinceDate:startTime];
            
            if (self.solved) {
                [self printBoardWithTimeToSolve:timeToSolve];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            
        });
    });

}

- (void)didReceiveMemoryWarning
{
    NSLog(@"Received memory warning");
}


@end
