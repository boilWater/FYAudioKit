//
//  FYMemoModel.m
//  FYAudioKit_Example
//
//  Created by liangbai on 2017/7/27.
//  Copyright © 2017年 boilwater. All rights reserved.
//

#import "FYMemoModel.h"

#define TITLE_KEY @"title_key"
#define DATE_KEY  @"date_key"
#define TIME_KEY  @"time_key"
#define URL_KEY   @"url_key"

@implementation FYMemoModel

+ (instancetype)memoWithTitle:(NSString *)title url:(NSURL *)url {
    return [[self alloc] initWithTitle:title url:url];
}

- (BOOL)deleteMemo {
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:self.url error:&error];
    if (!success) {
        
    }
    return success;
}

#pragma mark - privated Metods

- (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url {
    self = [super init];
    if (self) {
        _title = [title copy];
        _url = url;
        
        NSDate *currentDate = [NSDate date];
        _date = [self dateWithDate:currentDate];
        _time = [self timeWithDate:currentDate];
    }
    return self;
}

#pragma mark - Coding protocol

- (void) encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:TITLE_KEY];
    [aCoder encodeObject:self.url forKey:URL_KEY];
    [aCoder encodeObject:self.date forKey:DATE_KEY];
    [aCoder encodeObject:self.time forKey:TIME_KEY];
}

- (nullable instancetype) initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _title = [aDecoder decodeObjectForKey:TITLE_KEY];
        _url = [aDecoder decodeObjectForKey:URL_KEY];
        _date = [aDecoder decodeObjectForKey:DATE_KEY];
        _time = [aDecoder decodeObjectForKey:TIME_KEY];
    }
    return self;
}

#pragma mark - Configuration date and time

- (NSString *)dateWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [self formatterWithFormat:@"MMddyyyy"];
    return [formatter stringFromDate:date];
}

- (NSString *)timeWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [self formatterWithFormat:@"HHmmss"];
    return [formatter stringFromDate:date];
}

- (NSDateFormatter *)formatterWithFormat:(NSString *)template {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:[NSLocale currentLocale]];
    [formatter setDateFormat:format];
    return formatter;
}

@end
