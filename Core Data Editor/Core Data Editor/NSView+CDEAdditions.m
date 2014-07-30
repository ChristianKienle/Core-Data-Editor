#import "NSView+CDEAdditions.h"

@implementation NSView (CDEAdditions)

#pragma mark - Convenience
- (void)addSubviewAndMakeItToTakeAllAvailableSpace_cde:(NSView *)greedyView {
    NSView *contentView = self;
    [greedyView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [contentView addSubview:greedyView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(greedyView);
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[greedyView]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[greedyView]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views]];
}

@end
