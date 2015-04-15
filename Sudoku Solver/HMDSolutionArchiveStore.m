//
//  HMDSolutionArchiveStore.m
//  Sudoku Solver
//
//  Created by Trent You on 4/15/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDSolutionArchiveStore.h"
#import "HMDArchivedSolution.h"

@implementation HMDSolutionArchiveStore


#pragma mark - Init

+ (instancetype)sharedStore
{
    static HMDSolutionArchiveStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)initPrivate
{
    self = [super init];

    
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[HMDSolutionArchiveStore" userInfo:nil];
    return nil;
}




#pragma mark - Archiving

- (void)archiveSolution:(NSString *)solution
{
    HMDArchivedSolution *archivedSolution = [[HMDArchivedSolution alloc] initWithSolution:solution];
    
    NSString *path = [self solutionArchivePath];
    
    NSMutableArray *unarchivedSolutions = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if (!unarchivedSolutions) {
        NSMutableArray *solutions = [[NSMutableArray alloc] initWithObjects:archivedSolution, nil];
        [NSKeyedArchiver archiveRootObject:solutions toFile:path];
    } else {
        [unarchivedSolutions addObject:archivedSolution];
        [NSKeyedArchiver archiveRootObject:unarchivedSolutions toFile:path];
    }
    
    
}

#pragma mark - Unarchiving

- (NSMutableArray *)solutionList
{
    NSString *path = [self solutionArchivePath];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}


#pragma mark - Convenience methods

- (NSString *)solutionArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"solutions.archive"];
}





















@end
