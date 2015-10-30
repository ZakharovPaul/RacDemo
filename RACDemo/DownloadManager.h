//
//  DownloadManager.h
//  
//
//  Created by Pavel Zakharov on 10/25/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>

@interface DownloadManager : NSObject
+(id)sharedManager;
- (RACSignal*)getInfoWithQuerry:(NSString*)querry;
- (RACSignal*)getPictureCollection:(NSArray<NSString*>*)urls;

@end
