//
//  PracticeCollectionViewController.m
//  Yogi
//
//  Created by Kelsey Mayfield on 4/16/15.
//  Copyright (c) 2015 Kelsey Mayfield. All rights reserved.
//

#import "PracticeCollectionViewController.h"
#import "ViewController.h"

@interface PracticeCollectionViewController ()
@property (strong, nonatomic) PracticeCVLayout *layout;
@property (strong, nonatomic) PracticeCVDataSource *dataSource;
@property (nonatomic) NSInteger selectedIndex;
@end

@implementation PracticeCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_selectedIndex = -1;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveStartPracticeNotification:) name:@"Start Practice Notification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveStartEditingNotification:) name:@"Start Editing Notification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDidExitNotification:) name:@"Did Exit Notification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSelectFlowNotification:) name:@"Select Flow Notification" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewFlowNotification:) name:@"Select icon" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSelectCardNotification:) name:@"Select Card" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeselectCardNotification:) name:@"Deselect Card" object:nil];
	
    
    // Set data source
	 _dataSource = [[PracticeCVDataSource alloc] init];
	
	// Set layout
	_layout = [[PracticeCVLayout alloc] init];
	_layout.actualCellHeight = CGRectGetHeight(self.view.frame) - 120;
	_layout.visibleCellHeight = 60;
	
	self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
	self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	self.collectionView.delegate = self;
	self.collectionView.dataSource = _dataSource;
	
	// Register cell classes
	[self.collectionView registerClass:[PracticeCollectionViewCell class] forCellWithReuseIdentifier:[PracticeCollectionViewCell reuseIdentifier]];
	
	self.clearsSelectionOnViewWillAppear = NO;
}

/*
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (_selectedIndex > 0) {
		NSLog(@"selected thingy tho %ld", [self.dataSource cardStateAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]]);
		
		[self.layout invalidateLayout];
	}
	
}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receiveStartPracticeNotification:(NSNotification *)notification
{
	if ([[notification name] isEqualToString:@"Start Practice Notification"]) {
		[self performSegueWithIdentifier:@"startPractice" sender:[notification object]];
	}
}

- (void)receiveStartEditingNotification:(NSNotification *)notification {
	if ([[notification name] isEqualToString:@"Start Editing Notification"]) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.collectionView performBatchUpdates:^{
			[self.dataSource selectCardAtIndexPath:indexPath];
		} completion:nil];
		
		[self.layout invalidateLayout];
	}
}

- (void)receiveSelectFlowNotification:(NSNotification *)notification {
	
}

- (void)receiveDidExitNotification:(NSNotification *)notification {
	if ([[notification name] isEqualToString:@"Did Exit Notification"]) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.collectionView performBatchUpdates:^{
			[self.dataSource selectCardAtIndexPath:indexPath];
		} completion:nil];
		
		[self.layout invalidateLayout];
	}
}

- (void)receiveNewFlowNotification:(NSNotification *)notification {
	if (_selectedIndex == 0) {
		[self performSegueWithIdentifier:@"Add Flow Segue" sender:self];
	} else if (_selectedIndex > 0){
		[self performSegueWithIdentifier:@"Flow Detail Segue" sender:self];
	}
	
}

- (void)receiveSelectCardNotification:(NSNotification *)notification {
	_selectedIndex = [notification.userInfo[@"row"] integerValue];
}

- (void)receiveDeselectCardNotification:(NSNotification *)notification{
	_selectedIndex = -1;
}

- (void)addFlows:(NSArray *)flows
{
	PracticeCollectionViewCell *cell = (PracticeCollectionViewCell *)[self.dataSource collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
	[cell addFlows:flows];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([sender isKindOfClass:[PracticeCollectionViewCell class]]) {
		PracticeCollectionViewCell *cell = (PracticeCollectionViewCell *)sender;
		NSMutableArray *practiceInfo = [NSMutableArray new];
		NSArray *flows = cell.flows;
		for (NSDictionary *flow in flows) {
			NSArray *postures = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:flow[@"name"] ofType:@"plist"]];
			[practiceInfo addObjectsFromArray:postures];
		}
		if ([segue.destinationViewController isKindOfClass:[ViewController class]]) {
			ViewController *vc = (ViewController *)segue.destinationViewController;
				
			vc.practiceInfo = practiceInfo;
		}
	} else if ([segue.destinationViewController isKindOfClass:[FlowDetailTableViewController class]]) {
		FlowDetailTableViewController *tvc = (FlowDetailTableViewController *)segue.destinationViewController;
//		tvc.flows = self.dataSource.practices[_selectedIndex];
		PracticeCollectionViewCell *cell = (PracticeCollectionViewCell *)[self.dataSource collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]];
		tvc.flows = cell.flows;
	}
	
}

/*

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete method implementation -- Return the number of sections
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.practices count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    return cell;
}

*/

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self.collectionView performBatchUpdates:^{
		[self.dataSource selectCardAtIndexPath:indexPath];
	} completion:nil];
	
	[self.layout invalidateLayout];
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
