#import "CDECSVImportWindowController.h"
#import "CDECSVAccessoryViewController.h"
#import "CDECSVDelimiter.h"
#import "CDECSVImportWindowControllerResultItem.h"
#import "CDECSVImportWindowControllerResult.h"

// Additions: Begin
#import "NSString+CDEAdditions.h"
#import "NSArray+CDECSV.h"
// Additions: End

// 3rd Party: Begin
#import "CHCSVParser.h"
// 3rd Party: End

NSString *const CDECSVImportWindowControllerMappingAttributeName = @"attributeName";
NSString *const CDECSVImportWindowControllerMappingColumnNames = @"columnNames";
NSString *const CDECSVImportWindowControllerMappingIndexOfSelectedColumn = @"indexOfSelectedColumn";

@interface CDECSVImportWindowController ()

#pragma mark - UI
@property (nonatomic, weak) IBOutlet NSArrayController *entityDescriptionsArrayController;
@property (nonatomic, weak) IBOutlet NSArrayController *mappingsArrayController;
@property (nonatomic, weak) IBOutlet NSTextField *pathToCSVFileTextField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *entitiesPopupButton;

#pragma mark - UI / Object Controller
@property (nonatomic, copy) NSNumber *validCSVFileChosen; // enables import button
@property (nonatomic, strong) NSEntityDescription *destinationEntityDescription; // bound to popup

#pragma mark Working with the CSV File
@property (nonatomic, copy) NSURL *URLToImport;
@property (nonatomic, strong) CDECSVAccessoryViewController *delimiterViewController;
@property (nonatomic, copy) NSArray *contentsOfCSVFile;

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSArray *entityDescriptions;

#pragma mark Presenting the Window Controller
@property (nonatomic, copy) CDECSVImportWindowControllerCompletionHandler completionHandler;

@end

@implementation CDECSVImportWindowController

#pragma mark Working with the CSV File
- (NSArray *)columnNamesOfCSVFile {
    BOOL containsAtLeastOneLine = (self.contentsOfCSVFile.count >= 1);
    if(containsAtLeastOneLine == NO) {
        return @[];
    }
    
    NSArray *firstLine = (self.contentsOfCSVFile)[0];

    BOOL firstLineContainsColumnNames = self.delimiterViewController.firstLineContainsColumnNames;
    if(firstLineContainsColumnNames) {
        return firstLine;
    }
    
    NSUInteger numberOfColumns = firstLine.count;
    BOOL fileHasZeroColumns = (numberOfColumns == 0);
    if(fileHasZeroColumns) {
        return @[];
    }
    
    // Create artificial Column Names
    NSMutableArray *result = [NSMutableArray array];
    NSIndexSet *columnIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, numberOfColumns)];
    [columnIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        NSString *columnName = [NSString stringWithFormat:@"%lu. Column", index];
        [result addObject:columnName];
    }];
    
    return result;
}

- (CDECSVImportWindowControllerResult *)resultForCurrentConfiguration {
    /* 
     (
        attributeName = $name of attribute
        columnNames = ($colum names)
        indexOfSelectedColumn = $index (0 = ignore)
     )
    */
    if(self.contentsOfCSVFile.count == 0) {
        return nil;
    }
    NSMutableArray *resultItems = [NSMutableArray array];
    
    NSArray *resultingContentsOfCSVFile = self.contentsOfCSVFile;
    BOOL firstLineContainsColumnNames = self.delimiterViewController.firstLineContainsColumnNames;
    if(firstLineContainsColumnNames) {
        resultingContentsOfCSVFile = [resultingContentsOfCSVFile subarrayWithRange:NSMakeRange(1, self.contentsOfCSVFile.count - 1)];
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumberFormatter *numberFormatter = defaults.floatingPointNumberFormatter_cde;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:self.delimiterViewController.dateFormat];
    
    for(NSArray *line in resultingContentsOfCSVFile) {
        NSMutableDictionary *keyedValuesForUsedAttributes = [NSMutableDictionary dictionary];
        NSArray *mappings = (NSArray *)self.mappingsArrayController.arrangedObjects;
        for(NSDictionary *mappingDictionary in mappings) {
            NSUInteger indexOfSelectedColumn = [mappingDictionary[CDECSVImportWindowControllerMappingIndexOfSelectedColumn] unsignedIntegerValue];
            BOOL ignoreMapping = (indexOfSelectedColumn == 0);
            if(ignoreMapping) {
                continue;
            }
            
            NSUInteger resultingColumnIndex = indexOfSelectedColumn - 1;
            BOOL lineHasNotEnoughEntries = line.count <= resultingColumnIndex;
            if(lineHasNotEnoughEntries) {
                continue;
            }
            NSString *CSVValue = line[resultingColumnIndex];
            
            NSString *attributeName = mappingDictionary[CDECSVImportWindowControllerMappingAttributeName];
            NSAttributeDescription *attributeDescription = (self.destinationEntityDescription.attributesByName)[attributeName];
            
            NSAttributeType attributeType = attributeDescription.attributeType;
            
            id value = [CSVValue valueForAttributeType:attributeType dateFormatter:dateFormatter numberFormatter_cde:numberFormatter];
            
            Class correctValueClass = NSClassFromString(attributeDescription.attributeValueClassName);
            BOOL isCorrectClass = [value isKindOfClass:correctValueClass];            
            if(isCorrectClass == NO || value == nil) {
                continue;
            }
            
            keyedValuesForUsedAttributes[attributeName] = value;
        }
        CDECSVImportWindowControllerResultItem *item = [[CDECSVImportWindowControllerResultItem alloc] initWithKeyedValuesForUsedAttributes:keyedValuesForUsedAttributes];
        [resultItems addObject:item];
    }
    
    CDECSVImportWindowControllerResult *result = [[CDECSVImportWindowControllerResult alloc] initWithItems:resultItems destinationEntityDescription:self.destinationEntityDescription];
    return result;
}

- (IBAction)showOpenCSVFilePanel:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.allowsMultipleSelection = NO;
    panel.allowedFileTypes = @[@"csv"];
    panel.accessoryView = self.delimiterViewController.view;
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        BOOL userChoseOKButton = (NSFileHandlingPanelOKButton == result);
        if(userChoseOKButton == NO) {
            return;
        }
        
        NSError *error = nil;
        NSString *delimiter = self.delimiterViewController.selectedDelimiter.stringRepresentation;
        NSArray *CSVFileAsArray = [NSArray arrayWithContentsOfURL:panel.URL delimiter:delimiter error_cde:&error];
        
        BOOL CSVParserFailed = (CSVFileAsArray == nil);
        
        if(CSVParserFailed) {
            self.contentsOfCSVFile = nil;
            self.validCSVFileChosen = @NO;
            self.pathToCSVFileTextField.stringValue = [NSString string];
            [self updateMappingsArrayController];
            [NSApp presentError:error];
            return;
        }
        self.contentsOfCSVFile = CSVFileAsArray;
        self.validCSVFileChosen = @YES;
        self.URLToImport = panel.URL;
        self.pathToCSVFileTextField.stringValue = self.URLToImport.path;
        [self updateMappingsArrayController];
    }];
}

#pragma mark Working with the Mapping
- (void)updateMappingsArrayController {
    if(self.validCSVFileChosen.boolValue == NO) {
        self.mappingsArrayController.content = [NSMutableArray array];
        return;
    }
    
    NSMutableArray *CSVColumnNames = [NSMutableArray new];
    [CSVColumnNames addObject:@"Don't Import"];
    [CSVColumnNames addObjectsFromArray:[self columnNamesOfCSVFile]];
    
    NSEntityDescription *selectedEntityDescription = self.destinationEntityDescription;
    
    NSMutableArray *mappings = [NSMutableArray array];
    for(NSAttributeDescription *attribute in selectedEntityDescription.supportedCSVAttributes_cde) {
        NSMutableDictionary *mapping = [@{ @"attributeNameForDisplay" : attribute.nameForDisplay_cde,
                                          @"attributeName" : attribute.name,
                                           @"columnNames" : CSVColumnNames,
                                           @"indexOfSelectedColumn" : @0 } mutableCopy];
        [mappings addObject:mapping];
    }
    
    [self.mappingsArrayController setContent:mappings];
}


#pragma mark Working with the Entity Descriptions
- (void)setEntityDescriptions:(NSArray *)entityDescriptions {
    _entityDescriptions = entityDescriptions;
    
    self.destinationEntityDescription = self.entityDescriptions.lastObject;
    [self updateMappingsArrayController];
}

- (IBAction)selectedDestinationEntityChanged:(id)sender {
    [self updateMappingsArrayController];
}

#pragma mark Presenting the Window Controller
- (void)beginSheetModalForWindow:(NSWindow *)parentWindow entityDescriptions:(NSArray *)entityDescriptions selectedEntityDescription:(NSEntityDescription *)selectedEntityDescription completionHandler:(CDECSVImportWindowControllerCompletionHandler)completionHandler {
    NSParameterAssert(entityDescriptions);
    NSParameterAssert(parentWindow);
    self.entityDescriptions = entityDescriptions;
    if(selectedEntityDescription != nil) {
        self.destinationEntityDescription = selectedEntityDescription;
    } else if(entityDescriptions.count > 0) {
        self.destinationEntityDescription = entityDescriptions[0];
    }
    self.completionHandler = completionHandler;
    [self window];
    // Entities Popup Button: Begin
    
    [self.entitiesPopupButton removeAllItems];
    
    NSMenuItem *selectedItem = nil;
    for(NSEntityDescription *entity in self.entityDescriptions) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:entity.nameForDisplay_cde action:NULL keyEquivalent:@""];
        item.image = entity.icon_cde;
        item.representedObject = entity;
        [self.entitiesPopupButton.menu addItem:item];
        if([entity isEqual:selectedEntityDescription] && selectedEntityDescription != nil) {
            selectedItem = item;
        }
    }
    
    if(selectedItem != nil) {
        [self.entitiesPopupButton selectItem:selectedItem];
    } else if(entityDescriptions.count > 0) {
        [self.entitiesPopupButton selectItemAtIndex:0];
    }
    
    // Entities Popup Button: End
    [self updateMappingsArrayController];
    
    [NSApp beginSheet:self.window modalForWindow:parentWindow modalDelegate:self didEndSelector:@selector(importWindowDidEnd:returnCode:contextInfo:) contextInfo:NULL];
    [self showOpenCSVFilePanel:self];
}
     
- (void)importWindowDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
    self.completionHandler ? self.completionHandler([self resultForCurrentConfiguration]) : nil;
    self.completionHandler = nil;
}

- (IBAction)cancelImport:(id)sender {
    self.completionHandler = nil;
    [NSApp endSheet:self.window];
}

- (IBAction)confirmImport:(id)sender {
    [NSApp endSheet:self.window];
}

- (IBAction)takeSelectedEntityFromSender:(id)sender {
    NSEntityDescription *selectedEntity = [[self.entitiesPopupButton selectedItem] representedObject];
    self.destinationEntityDescription = selectedEntity;
    [self updateMappingsArrayController];
}

#pragma mark NSWindowController
- (void)windowDidLoad {
    [super windowDidLoad];
    self.delimiterViewController = [CDECSVAccessoryViewController new];
    self.validCSVFileChosen = @NO;
}

#pragma mark - NSMenuDelegate
- (void)menuWillOpen:(NSMenu *)menu {
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
}

- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)item {
}

@end
