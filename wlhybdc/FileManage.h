//
//  FileManage.h
//  wlhybdc
//
//  Created by Hello on 13-9-3.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManage : NSObject

+ (FileManage *)fileManage;

+ (NSString *)documentsPath;

- (void)writeData:(NSData *)data toFile:(NSString *)filePath;
- (NSData *)getDataFromFile:(NSString *)filepath;


@end
