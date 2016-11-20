#import <Foundation/Foundation.h>

@interface FilteringArray<ObjectType>: NSObject
- (void)setFilterPredicate:(NSPredicate *)predicate;
- (void)addObject:(ObjectType)anObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (ObjectType)objectAtIndex:(NSUInteger)index;
- (void)addObjectsFromArray:(NSArray<ObjectType> *)otherArray;
- (NSUInteger)indexOfObject:(ObjectType)anObject;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (NSArray<ObjectType> *)objectsAtIndexes:(NSIndexSet *)indexes;
- (NSUInteger)count;
@end
