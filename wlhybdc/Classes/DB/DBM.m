//
//  DBM.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-14.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "DBM.h"


static DBM* _gDBM = nil;

@interface DBM ()
{
    
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

@end



@implementation DBM

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+(DBM*)dbm
{
    if(!_gDBM){
        _gDBM=[[self alloc] init];
    }
    return _gDBM;
}

-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}


#pragma mark users -----

- (id)lastLoginUser
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"lastlogin" ascending:NO];
    [request setSortDescriptors:@[sort]];
    [request setFetchLimit:1];
    NSError * err = nil;
    NSArray * r = [self.managedObjectContext executeFetchRequest:request error:&err];
    if(!r){
        NSLog(@"select user error:%@",err);
        return nil;
    }
    return [r lastObject];
}

- (id)getUserByMemberId:(NSString *)memberId
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"lastlogin" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberId=%@",memberId];
    
    [request setSortDescriptors:@[sort]];
    [request setPredicate:predicate];
    
    NSError* error = nil;
    NSArray * array = [self.managedObjectContext executeFetchRequest:request error:&error];
    if(!array){
        NSLog(@"select user error:%@",error);
        return nil;
    }
    return [array lastObject];
}



-(id)userExtInfos:(NSString *)memberId
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"UsersExt"];
    NSError * err = nil;
    NSArray * r = [[DBM dbm].managedObjectContext executeFetchRequest:request error:&err];
    if(!r){
        NSLog(@"select UsersExt error:%@",err);
        return nil;
    }
    return [r lastObject];
}

//---Prescription
#pragma mark ---Prescription
-(id) getPrescriptionByMemberId:(NSNumber*)memberId
{    
    return [self getEntityByMemberId:memberId andTableName:@"Prescription"];
}

// UsersExt
-(id)getUsersExtByMemberId:(NSNumber *)memberId
{
    return [self getEntityByMemberId:memberId andTableName:@"UsersExt"];
}

//---------
#pragma mark common
-(id)createNewRecord:(NSString *)tableName
{
    NSLog(@"tableName :: %@", tableName);
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:self.managedObjectContext];
    return obj;
}


//----
-(void)saveRecord:(NSManagedObject*) obj info:(NSDictionary*)info
{
    if(obj && info){
        NSDictionary * p = [[obj entity] propertiesByName];
        for(NSString* key in info){
            id v = [p objectForKey:key];
            if([v isKindOfClass:[NSAttributeDescription class]]){
                id value = [self suitableType:[info objectForKey:key] withType:v ];
                if(value){
                    [obj setValue:value forKey:key];
                }
            }
        }
    }
}

// json中传入的基本上是字符串和数字，所以只是简单的转换了这两种数据类型
-(id)suitableType:(id)fromType withType:(NSAttributeDescription*)withType
{
    id result = nil;
    switch (withType.attributeType) {
        //case NSUndefinedAttributeType:break;
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
        case NSDecimalAttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
        case NSBooleanAttributeType:
            if([fromType isKindOfClass:[NSNumber class]]){
                result = fromType;
            }else{
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                f.numberStyle=NSNumberFormatterDecimalStyle;
                result = [f numberFromString:[NSString stringWithFormat:@"%@",fromType]];
            }
            break;
        case NSStringAttributeType:
            if([fromType isKindOfClass:[NSString class]]){
                result = fromType;
            }else{
                result = [NSString stringWithFormat:@"%@",fromType];
            }

            break;
//        case NSDateAttributeType:;
//        case NSBinaryDataAttributeType:;
//        case NSTransformableAttributeType:;
//        case NSObjectIDAttributeType:break;
        default:
            result = fromType;
            break;
    }
    return result;
}


/////////////////////////////////////
#pragma mark private common function
-(id)getEntityByMemberId:(NSNumber*)memberId andTableName :(NSString*)tableName
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:tableName];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberId=%@",memberId];
    [request setPredicate:predicate];
    
    NSError * err = nil;
    NSArray * r = [[DBM dbm].managedObjectContext executeFetchRequest:request error:&err];
    if(!r){
        NSLog(@"select UsersExt error:%@",err);
        return nil;
    }
    return [r lastObject];
}



//---------------------------------------

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
           // abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"wlhy" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"wlhy.wdb"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES,NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
       
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
