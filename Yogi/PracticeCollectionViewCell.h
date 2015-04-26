//
//  PracticeCollectionViewCell.h
//  Yogi
//
//  Created by Kelsey Mayfield on 4/16/15.
//  Copyright (c) 2015 Kelsey Mayfield. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PracticeCollectionViewCell : UICollectionViewCell
- (void)setLabel:(NSString *)label withColor:(UIColor *)color;
- (void)addFlows:(NSArray *)flows;
+ (NSString *)reuseIdentifier;
@property (strong, nonatomic) UIView *practiceView;
@property (nonatomic) BOOL hasLabel;
@property (readonly, nonatomic) NSArray *flows;
@end