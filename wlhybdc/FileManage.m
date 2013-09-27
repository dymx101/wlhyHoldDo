//
//  FileManage.m
//  wlhybdc
//
//  Created by Hello on 13-9-3.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "FileManage.h"

static FileManage *shareSelf = nil;


@interface FileManage ()

@property(strong, nonatomic) NSFileManager *fileManager;

@end


@implementation FileManage


+ (FileManage *)fileManage
{
    if(!shareSelf){
        shareSelf = [[self alloc] init];
    }
    return shareSelf;
}

-(id)init
{
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];
    }
    return self;
}

//负责获取Documents文件夹的位置
+ (NSString *)documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsdir = [paths objectAtIndex:0];
    return documentsdir;
}

//读取文件内容
- (NSData *)getDataFromFile:(NSString *)filepath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        NSData *data = [[NSData alloc] initWithContentsOfFile:filepath];
        return data;
    } else {
        return nil;
    }
}

//将内容写到指定的文件
- (void)writeData:(NSData *)data toFile:(NSString *)filePath
{
    [self creatFile:filePath];
    [data writeToFile:filePath atomically:YES];
}


-(NSString *)tempPath
{
    return NSTemporaryDirectory();
}

- (void)creatFile:(NSString *)filePath
{
    if ([_fileManager fileExistsAtPath:filePath]) {
        return;
    }
    [_fileManager createFileAtPath:filePath contents:nil attributes:nil];
}

@end
