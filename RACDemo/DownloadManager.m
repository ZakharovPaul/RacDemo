//
//  DownloadManager.m
//  
//
//  Created by Pavel Zakharov on 10/25/15.
//
//

#import "DownloadManager.h"
#import <ReactiveCocoa.h>

static DownloadManager *myManager;
static const NSString *baseUrl = @"http://127.0.0.1:8000/";

@implementation DownloadManager

+ (id)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myManager = [[DownloadManager alloc]init];
   });
    return myManager;
}

- (RACSignal*)getInfoWithQuerry:(NSString*)querry{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURL *url = [NSURL URLWithString:[baseUrl stringByAppendingString:querry]];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSDictionary *headers = ((NSHTTPURLResponse*)response).allHeaderFields;
            if(error){
                [subscriber sendError:error];
            }else if([[headers valueForKey:@"Content-Type"]isEqualToString:@"image/png"] ||
                     [[headers valueForKey:@"Content-Type"]isEqualToString:@"image/jpeg"]) {
                if(data){
                    UIImage* image = [UIImage imageWithData:data];
                    [subscriber sendNext:image];
                    [subscriber sendCompleted];
                }
            }else if([[headers valueForKey:@"Content-Type"] isEqualToString:@"application/json"]) {
                if(data){
                    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:kNilOptions
                                                                           error:&error];
                    [subscriber sendNext:json];
                    [subscriber sendCompleted];
                }
            }
        }]resume];
        return nil;

    }];
}

- (RACSignal*)getPictureCollection:(NSArray<NSString*>*)urls{
   return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableArray *images = [[NSMutableArray alloc]init];
        for (NSString *url in urls) {
            [[self getInfoWithQuerry:url] subscribeNext:^(UIImage *image) {
                [images addObject:image];
                [subscriber sendNext:images];
            }error:^(NSError *error) {
                [subscriber sendError:error];
            }];
        }
        return nil;
    }];
}


@end
