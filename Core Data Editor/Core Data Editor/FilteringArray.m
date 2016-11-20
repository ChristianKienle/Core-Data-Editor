#import "FilteringArray.h"

@interface FilteringArray ()

@property (strong) NSMutableArray *_allObjects;
@property (strong) NSMutableArray *_filteredObjects;
@property (strong) NSPredicate *_predicate;

@end

@implementation FilteringArray

- (instancetype)init {
  self = [super init];
  self._allObjects = [NSMutableArray new];
  self._filteredObjects = [NSMutableArray new];
  return self;
}

- (void)setFilterPredicate:(NSPredicate *)predicate {
  self._predicate = predicate;
  [self applyFilter];
}

- (void)applyFilter {
  self._filteredObjects = self._allObjects;
  
  if(self._predicate == nil) {
    return;
  }
  
  [self._filteredObjects filterUsingPredicate:self._predicate];
}

- (void)addObject:(id)object {
  [self._allObjects addObject: object];
  [self applyFilter];
}
- (void)removeObjectAtIndex:(NSUInteger)index {
  [self._allObjects removeObjectAtIndex:index];
  [self applyFilter];
}
- (id)objectAtIndex:(NSUInteger)index {
  if(self._predicate == nil) {
    return [self._allObjects objectAtIndex:index];
  }
  return [self._filteredObjects objectAtIndex:index];
}
- (void)addObjectsFromArray:(NSArray *)otherArray {
  [self._allObjects addObjectsFromArray:otherArray];
  [self applyFilter];
}
- (NSUInteger)indexOfObject:(id)object {
  if(self._predicate == nil) {
    return [self._allObjects indexOfObject:object];
  }
  return [self._filteredObjects indexOfObject:object];
  
}

- (NSUInteger)count {
  if(self._predicate == nil) {
    return self._allObjects.count;
  }
  return self._filteredObjects.count;
  
}
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
  NSArray *objectsToRemove = [[self objects] objectsAtIndexes:indexes];
  [self._allObjects removeObjectsInArray:objectsToRemove];
  [self applyFilter];
}

- (NSMutableArray *)objects {
  return self._predicate == nil ? self._allObjects : self._filteredObjects;
}
- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
  return [self.objects objectsAtIndexes:indexes];
}
@end
