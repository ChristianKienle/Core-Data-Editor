#import "CDERelationshipsContainerView.h"
#import "CDERelationshipsViewController.h"

@implementation CDERelationshipsContainerView

#pragma mark - NSResponder
- (BOOL)performKeyEquivalent:(NSEvent *)event {
    BOOL superWantsToPerform = [super performKeyEquivalent:event];
    if(superWantsToPerform) {
        return YES;
    }
    
    if(self.relationshipsViewController != nil) {
        return [self.relationshipsViewController performKeyEquivalent:event];
    }
    return NO;
}

@end
