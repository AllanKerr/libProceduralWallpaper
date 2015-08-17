//
//  PWToggleButton.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-07-03.
//
//

#import "PWToggleButton.h"
#include <objc/runtime.h>

static int _toggleIndex = 0;
static NSString *_toggleName = nil;
static NSArray *_toggleValues = nil;

@interface PWToggleButton ()
@property (readwrite, nonatomic) int toggleIndex;
@property (nonatomic, copy) NSString *toggleName;
@property (nonatomic, copy) NSArray *toggleValues;
@end

@implementation PWToggleButton
@dynamic toggleIndex;
@dynamic toggleName;
@dynamic toggleValues;

- (int)toggleIndex
{
    return _toggleIndex;
}

- (void)setToggleIndex:(int)toggleIndex
{
    _toggleIndex = toggleIndex;
}

- (NSString *)toggleName
{
    return _toggleName;
}

- (void)setToggleName:(NSString *)toggleName
{
    if (_toggleName != nil) {
        [_toggleName release];
    }
    _toggleName = [toggleName copy];
}

- (NSArray *)toggleValues
{
    return _toggleValues;
}

- (void)setToggleValues:(NSArray *)toggleValues
{
    if (_toggleValues != nil) {
        [_toggleValues release];
    }
    _toggleValues = [toggleValues copy];
}

- (UILabel *)leftLabel
{
    return [self valueForKey:@"_leftLabel"];
}

- (UILabel *)rightLabel
{
    return [self valueForKey:@"_rightLabel"];
}

+ (id)buttonWithMotionButton:(SBSUIWallpaperMotionButton *)motionButton name:(NSString *)name values:(NSArray *)values
{
    if ([motionButton isKindOfClass:[PWToggleButton class]] == NO) {
        object_setClass(motionButton, [PWToggleButton class]);
    }
    PWToggleButton *toggleButton = (PWToggleButton *)motionButton;
    
    toggleButton.toggleIndex = 0;
    toggleButton.toggleValues = values;
    toggleButton.leftLabel.text = name;
    [toggleButton.leftLabel sizeToFit];
    [toggleButton updateToggleValue];
    [toggleButton setHidden:NO];
    
    return toggleButton;
}

- (void)_updateForStateChange
{
    [super _updateForStateChange];
    
    self.toggleIndex++;
    if (self.toggleIndex >= self.toggleValues.count) {
        self.toggleIndex = 0;
    }
    [self updateToggleValue];
}

- (void)updateToggleValue
{
    self.rightLabel.text = [self.toggleValues objectAtIndex:self.toggleIndex];
    [self.rightLabel sizeToFit];
}


- (void)dealloc
{
    [_toggleName release];
    [_toggleValues release];
    _toggleName = nil;
    _toggleValues = nil;
    
    [super dealloc];
}

@end
