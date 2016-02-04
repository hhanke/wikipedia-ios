//
//  UIView+VisualTestSizingUtils.m
//  Wikipedia
//
//  Created by Brian Gerstle on 9/3/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "UIView+VisualTestSizingUtils.h"

@implementation UIView (VisualTestSizingUtils)

- (CGRect)wmf_sizeThatFitsWidth:(CGFloat)width {
    CGSize sizeThatFitsWidth = [self systemLayoutSizeFittingSize:CGSizeMake(width, 0)
                                   withHorizontalFittingPriority:UILayoutPriorityRequired
                                         verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
    return (CGRect){
               .origin = CGPointZero,
               .size   = CGSizeMake(floor(sizeThatFitsWidth.width), floor(sizeThatFitsWidth.height))
    };
}

- (void)wmf_sizeToFitWindowWidth {
    UIWindow* window = self.window ? : [[UIApplication sharedApplication] keyWindow];
    [self wmf_sizeToFitWidth:window.bounds.size.width];
}

- (void)wmf_sizeToFitWidth:(CGFloat)width {
    self.frame = [self wmf_sizeThatFitsWidth:width];
}

@end

@interface UICollectionViewCell (VisualTestSizingUtils)

@end

@implementation UICollectionViewCell (VisualTestSizingUtils)

- (void)wmf_sizeToFitWidth:(CGFloat)width {
    [super wmf_sizeToFitWidth:width];
    self.contentView.frame = self.frame;
}

@end

@interface UITableViewCell (VisualTestSizingUtils)

@end

@implementation UITableViewCell (VisualTestSizingUtils)

- (void)wmf_sizeToFitWidth:(CGFloat)width {
    [super wmf_sizeToFitWidth:width];
    self.contentView.frame = self.frame;
}

@end
