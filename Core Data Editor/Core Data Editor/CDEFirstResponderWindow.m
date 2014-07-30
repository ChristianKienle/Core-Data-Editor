#import "CDEFirstResponderWindow.h"

NSString* const CDEFirstResponderWindowDidMakeFirstResponderNotification = @"CDEFirstResponderWindowDidMakeFirstResponderNotification";
NSString* const CDEFirstResponderWindowDidMakeFirstResponderNotificationResponder = @"responder";

@implementation CDEFirstResponderWindow

#pragma mark NSWindow
- (BOOL)makeFirstResponder:(NSResponder *)responder {
   BOOL result = [super makeFirstResponder:responder];
   if(result == YES && responder != nil) {
      [[NSNotificationCenter defaultCenter] postNotificationName:CDEFirstResponderWindowDidMakeFirstResponderNotification object:self userInfo:@{CDEFirstResponderWindowDidMakeFirstResponderNotificationResponder: responder}];
   }
   return result;
}

@end
