#import <CoreData/CoreData.h>

@interface NSRelationshipDescription (CDEAdditions)
@property (nonatomic, readonly, getter=isToOne_cde) BOOL isToOne_cde;
@property (nonatomic, readonly, getter=isManyToMany_cde) BOOL isManyToMany_cde;

@end
