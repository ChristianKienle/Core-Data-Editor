#import "CDEDatePickerViewController.h"
#import "CDEDatePickerViewControllerDelegate.h"

@implementation CDEDatePickerViewController

#pragma mark Creating
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (id)init {
   self = [self initWithNibName:@"CDEDatePickerViewController" bundle:nil];
   if(self) {
      self.delegate = nil;
   }
   return self;
}

- (IBAction)changeDate:(id)sender
{
    NSDate *date = [sender dateValue];
    
    // Only get the year, month and day from the date
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned yearMonthDayUnits = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *dateComponents = [calendar components:yearMonthDayUnits fromDate:date];
    
    NSDate *dateTime = self.dateTimePicker.dateValue;
    
    unsigned hourMinuteUnits = NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDateComponents *dateTimeComponents = [calendar components:hourMinuteUnits fromDate:dateTime];
    
    NSDateComponents *resultingComponents = [NSDateComponents new];
    [resultingComponents setYear:dateComponents.year];
    [resultingComponents setMonth:dateComponents.month];
    [resultingComponents setDay:dateComponents.day];
    
    [resultingComponents setHour:dateTimeComponents.hour];
    [resultingComponents setMinute:dateTimeComponents.minute];
    
    NSDate *result = [calendar dateFromComponents:resultingComponents];
    
    self.dateTimePicker.dateValue = result;
    self.dateTimePicker.textColor = [NSColor blackColor];
}

- (IBAction)changeDateTime:(id)sender
{
    self.datePicker.dateValue = [sender dateValue];
    self.dateTimePicker.textColor = [NSColor blackColor];
}


#pragma mark Actions
- (IBAction)cancel:(id)sender  {
   [self.delegate datePickerViewControllerDidCancel:self];
}

- (IBAction)ok:(id)sender {
   [self.delegate datePickerViewControllerDidConfirmDate:self];
}

#pragma mark Dealloc
- (void)dealloc {
   self.delegate = nil;
   self.datePicker = nil;
}

@end
