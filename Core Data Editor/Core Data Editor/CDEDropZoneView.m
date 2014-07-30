#import "CDEDropZoneView.h"
#import "CDEDropZoneViewDelegate.h"

@interface CDEDropZoneView ()

#pragma mark Properties
@property (nonatomic, retain) NSAnimation *borderAnimation;

@end

@interface CDEDropZoneView (Private)

#pragma mark Helper
- (NSString *)pasteboardType;
- (NSURL *)draggedURLFromDraggingInfo:(id<NSDraggingInfo>)info;
- (NSDragOperation)dragOperationWithDraggingInfo:(id<NSDraggingInfo>)info;
- (NSAttributedString *)attributedStringToDisplayFrom:(NSString *)string;
- (NSAttributedString *)attributedErrorMessage;
- (NSRect)attributedErrorMessageRect;
- (NSRect)errorMessageIconRect;

#pragma mark Drawing
- (void)drawBackground;
- (void)drawDropZone;
- (void)drawIcon;
- (void)drawErrorMessage;

@end

@implementation CDEDropZoneView (Private)

#pragma mark Helper
- (NSString *)pasteboardType {
   return NSURLPboardType;
}

- (NSURL *)draggedURLFromDraggingInfo:(id<NSDraggingInfo>)info {
   if(info == nil) {
      return nil;
   }
   
   NSPasteboard *pasteboard = [info draggingPasteboard];
   return [NSURL URLFromPasteboard:pasteboard];
}


- (NSDragOperation)dragOperationWithDraggingInfo:(id<NSDraggingInfo>)info {
   return NSDragOperationCopy;
}

- (NSAttributedString *)attributedStringToDisplayFrom:(NSString *)string {
   if(string == nil) {
      return [[NSAttributedString alloc] initWithString:[NSString string]];
   }
   
   NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
   [titleParagraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
   titleParagraphStyle.alignment = NSCenterTextAlignment;
   
    NSShadow *shadow = [NSShadow new];
	[shadow setShadowColor:[NSColor whiteColor]];
	[shadow setShadowBlurRadius:1.0f];
	[shadow setShadowOffset:NSMakeSize(0, -1.0f)];
	[shadow set];
   
   NSDictionary *titleAttributes = @{NSFontAttributeName: [NSFont labelFontOfSize:20.0], NSForegroundColorAttributeName: [NSColor grayColor], NSParagraphStyleAttributeName: titleParagraphStyle, NSShadowAttributeName: shadow};
   
   NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:titleAttributes];
   return attributedString;
}

- (NSAttributedString *)attributedErrorMessage {
   NSMutableAttributedString *attributedErrorMessage = [[NSMutableAttributedString alloc] initWithString:[NSString string]];
   
   NSMutableAttributedString *attributedTitleErrorMessage = [[self attributedStringToDisplayFrom:self.displayedError.localizedDescription] mutableCopy];
   
   CGFloat titleFontSize = [NSFont systemFontSizeForControlSize:NSRegularControlSize];
   
   [attributedTitleErrorMessage addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:titleFontSize] range:NSMakeRange(0, attributedTitleErrorMessage.mutableString.length)];
   
   [attributedErrorMessage appendAttributedString:attributedTitleErrorMessage];
   [attributedErrorMessage appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
   
   NSMutableAttributedString *attributedLocalizedRecoverySuggestion = [[self attributedStringToDisplayFrom:self.displayedError.localizedRecoverySuggestion] mutableCopy];
   
   [attributedLocalizedRecoverySuggestion addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:titleFontSize] range:NSMakeRange(0, attributedLocalizedRecoverySuggestion.mutableString.length)];
   
   [attributedErrorMessage appendAttributedString:attributedLocalizedRecoverySuggestion];
   return [attributedErrorMessage copy];
}

- (NSRect)attributedErrorMessageRect {
   CGFloat borderSpacing = 2.0;
   NSRect titleRect = self.bounds;
   titleRect.origin.x += borderSpacing;
   titleRect.size.width -= 2.0 * borderSpacing;
   
   CGFloat titleHeight = NSHeight([[self attributedErrorMessage] boundingRectWithSize:NSMakeSize(NSWidth(titleRect), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin]);
   
   titleRect.origin.y = (0.5 * (NSHeight(titleRect) - titleHeight));
   titleRect.size.height = titleHeight;
   return titleRect;
}

- (NSRect)errorMessageIconRect {
   NSSize cautionImageSize = NSMakeSize(32.0, 32.0);
   NSRect cautionImageRect = NSMakeRect(0.5 * (NSWidth(self.bounds) - cautionImageSize.width), NSMaxY([self attributedErrorMessageRect]) + 10.0, cautionImageSize.width, cautionImageSize.height);
   return cautionImageRect;
}

#pragma mark Drawing
- (void)drawBackground {
   NSColor *topColor = [NSColor colorWithCalibratedWhite:1 alpha:0.7];
   NSColor *bottomColor = [NSColor colorWithCalibratedWhite:0.923 alpha:0.7];
//   NSColor *topColor = [NSColor colorWithCalibratedWhite:0.923 alpha:1.000];
//   NSColor *bottomColor = [NSColor colorWithCalibratedWhite:0.8 alpha:1.000];

   NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:topColor endingColor:bottomColor];
   [gradient drawInRect:self.bounds angle:-90.0];
}

- (void)drawDropZone {
   CGFloat borderSpacing = 25.0;
   
   NSRect dashedBorderRect = NSInsetRect(self.bounds, borderSpacing, borderSpacing);
   CGFloat dashedBorderRectRadius = 5.0;
   NSBezierPath *dashedBorderPath = [NSBezierPath bezierPathWithRoundedRect:dashedBorderRect xRadius:dashedBorderRectRadius yRadius:dashedBorderRectRadius];
   
   const CGFloat dashPattern[2] = { 10.0, 10.0 };
   
   CGFloat phase = 0.0;
   if(self.borderAnimation != nil && self.borderAnimation.isAnimating) {
      phase = self.borderAnimation.currentProgress * 20.0;
   }
   
   [dashedBorderPath setLineDash:dashPattern count:2 phase:phase];
   
   [[NSColor grayColor] set];
   [dashedBorderPath stroke];
   
   NSString *title = [self.delegate titleForDropZoneView:self];
   if(title == nil) {
      title = @"";
   }
   
   NSAttributedString *titleAttributedString = [self attributedStringToDisplayFrom:title];
   
   NSRect titleRect = dashedBorderRect;
//   titleRect.origin.x += borderSpacing;
//   titleRect.size.width -= 2.0 * borderSpacing;
   
   CGFloat titleHeight = NSHeight([titleAttributedString boundingRectWithSize:NSMakeSize(NSWidth(titleRect), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin]);
   
    titleRect.origin.y = NSMidY(titleRect) - (0.5 * titleHeight);
   titleRect.size.height = titleHeight;
   
   [titleAttributedString drawInRect:titleRect];
}

- (void)drawIcon {
   NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:self.URL.path];
   CGFloat inset = 0.25 * NSWidth(self.bounds);
   NSRect iconRect = NSInsetRect(self.bounds, inset, inset);
   [icon drawInRect:iconRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)drawErrorMessage {
   NSImage *cautionImage = [NSImage imageNamed:NSImageNameCaution];
   [cautionImage drawInRect:[self errorMessageIconRect] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
   
   CGFloat borderSpacing = 5.0;
   NSAttributedString *attributedErrorMessage = [self attributedErrorMessage];
   
   NSRect titleRect = self.bounds;
   titleRect.origin.x += borderSpacing;
   titleRect.size.width -= 2.0 * borderSpacing;
   
   CGFloat titleHeight = NSHeight([attributedErrorMessage boundingRectWithSize:NSMakeSize(NSWidth(titleRect), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin]);
   
   titleRect.origin.y = (0.5 * (NSHeight(titleRect) - titleHeight));
   titleRect.size.height = titleHeight;
   
   [attributedErrorMessage drawInRect:titleRect];
}

@end

@implementation CDEDropZoneView

#pragma mark Creating and Initializing
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       self.borderAnimation = nil;
       [self registerForDraggedTypes:@[NSFilenamesPboardType, NSURLPboardType]];
       self.URL = nil;
    }
    return self;
}

- (void)awakeFromNib {
   if([super respondsToSelector:_cmd]) {
      [super awakeFromNib];
   }
}

#pragma mark Accessors
- (void)setURL:(NSURL *)newURL {
   if(newURL != _URL) {
      _URL = [newURL copy];
   }
   
   [self setNeedsDisplay:YES];
}

- (void)setDisplayedError:(NSError *)newDisplayedError {
   if(_displayedError != newDisplayedError) {
      _displayedError = [newDisplayedError copy];
   }
   [self setNeedsDisplay:YES];
}

#pragma mark Dealloc

- (void)dealloc {
   self.borderAnimation.delegate = nil;
   if(self.borderAnimation != nil && [self.borderAnimation isAnimating]) {
      [self.borderAnimation stopAnimation];
   }
}

#pragma mark NSView
- (void)drawRect:(NSRect)dirtyRect {
   [super drawRect:dirtyRect];
   [self drawBackground];
   
   if(self.URL == nil && self.displayedError == nil) {
      [self drawDropZone];
   } 
   if(self.URL != nil && self.displayedError == nil) {
      [self drawIcon];
   }
   if(self.displayedError != nil) {
      [self drawErrorMessage];
   }
   
//   [NSGraphicsContext saveGraphicsState];
   [[NSColor grayColor] set];
   [[NSBezierPath bezierPathWithRect:NSInsetRect(self.bounds, 0.0, 0.0)] stroke];
   
//   NSRect focusRingFrame = self.bounds;
//   focusRingFrame.size.height -= 2.0;
//   NSSetFocusRingStyle(NSFocusRingOnly);
//   [[NSBezierPath bezierPathWithRect: NSInsetRect(focusRingFrame,0,0)] fill];
//   [NSGraphicsContext restoreGraphicsState];
}


#pragma mark Drag and Drop Support
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
   NSDragOperation dragOperation = [self.delegate dropZoneView:self validateDrop:sender];
   if(dragOperation == NSDragOperationNone) {
      return dragOperation;
   }
   
   if(self.borderAnimation == nil) {
      self.borderAnimation = [[NSAnimation alloc] initWithDuration:0.3 animationCurve:NSAnimationLinear];
      [self.borderAnimation setAnimationBlockingMode:NSAnimationNonblocking];
      [self.borderAnimation setDelegate:self];
      NSAnimationProgress progMarks[] = {0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0};
      
      int i, count = 20;
      for (i=0; i<count; i++) {
         [self.borderAnimation addProgressMark:progMarks[i]];
      }
      [self.borderAnimation startAnimation];
   }

   return dragOperation;

}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender {
   return NSDragOperationEvery;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender {
   if(self.borderAnimation != nil) {
      [self.borderAnimation stopAnimation];
   }
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender {
   return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
   if(self.borderAnimation != nil) {
      [self.borderAnimation stopAnimation];
   }
   
   if([self.delegate dropZoneView:self acceptDrop:sender] == NO) {
      return NO;
   }
   
   NSPasteboard *pasteboard = [sender draggingPasteboard];
   NSArray *classes = @[[NSURL class]];
   NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @YES};
   NSArray *fileURLs = [pasteboard readObjectsForClasses:classes options:options];
   self.URL = [fileURLs lastObject];
   if(self.delegate != nil) {
      [self.delegate dropZoneView:self didChangeURL:self.URL];
   }
   [self setNeedsDisplay:YES];
   return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
}

#pragma mark NSAnimationDelegate
- (void)animation:(NSAnimation *)animation didReachProgressMark:(NSAnimationProgress)progress {
   [self setNeedsDisplay:YES];
}

- (void)animationDidEnd:(NSAnimation *)animation {
   [animation setCurrentProgress:0.0];
   [animation startAnimation];
}

- (void)animationDidStop:(NSAnimation *)animation {
   self.borderAnimation = nil;
}

@end
