//
//  ViewController.m
//  RACDemo
//
//  Created by Pavel Zakharov on 10/24/15.
//  Copyright © 2015 Pavel Zakharov. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACEXTScope.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

//topView

@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UIImageView *productLogo;
@property (weak, nonatomic) IBOutlet UILabel *productPublisher;
@property (weak, nonatomic) IBOutlet UILabel *productInfo;
@property (weak, nonatomic) IBOutlet UILabel *productRaiting;

//collectionView

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//descriptionView

@property (weak, nonatomic) IBOutlet UITextField *descriptionLabel;

//support

@property (weak, nonatomic) IBOutlet UIView *supportView;
@property (weak, nonatomic) IBOutlet UITextField *supportLabel;
@property (weak, nonatomic) IBOutlet UIView *descrview;


//bottomView

@property (weak, nonatomic) IBOutlet UIView *bottomview;
@property (weak, nonatomic) IBOutlet UITextField *publisher;
@property (weak, nonatomic) IBOutlet UITextField *category;
@property (weak, nonatomic) IBOutlet UITextField *updated;
@property (weak, nonatomic) IBOutlet UITextField *version;
@property (weak, nonatomic) IBOutlet UITextField *size;
@property (weak, nonatomic) IBOutlet UITextField *limitations;
@property (weak, nonatomic) IBOutlet UITextField *fanilySharing;
@property (weak, nonatomic) IBOutlet UITextField *capabilities;
@property (weak, nonatomic) IBOutlet UITextField *languages;

//additional RAC properties

@property (strong, nonatomic) NSDictionary *topDictionary;
@property (strong, nonatomic) NSDictionary *infoDictionary;
@property (strong, nonatomic) NSString *support;
@property (strong, nonatomic) NSString *descr;
@property (strong, nonatomic) UIImage *logo;
@property (strong, nonatomic) NSArray<UIImage *> *imageCollection;
@property (strong, nonatomic) NSArray<NSString *> *urls;
@property (weak, nonatomic) IBOutlet UIButton *getButton;
@end

@implementation ViewController

static NSString * const reuseIdentifier = @"imageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self setUpBorders];
        
    self.urls = @[@"limbo1.jpg",@"limbo2.jpg",@"limbo3.jpg",@"limbo4.jpg",@"limbo5.jpg"];

    RACSignal *topRecieved = [[DownloadManager sharedManager]getInfoWithQuerry:@"topviewdata.json"];
    [topRecieved subscribeNext:^(NSDictionary *topDict) {
        NSLog(@"%@",topDict);
        self.topDictionary = topDict;
    }];
    
    RACSignal *supportRecieved = [[DownloadManager sharedManager]getInfoWithQuerry:@"supportviewdata.json"];
    [supportRecieved subscribeNext:^(NSDictionary *supportDict) {
        NSLog(@"%@",supportDict);
        self.support = [supportDict valueForKey:@"support"];
    }];
    
    RACSignal *descriptionRecieved = [[DownloadManager sharedManager]getInfoWithQuerry:@"descriptionviewdata.json"];
    [descriptionRecieved subscribeNext:^(NSDictionary *descrDict) {
        NSLog(@"%@",descrDict);
        self.descr = [descrDict valueForKey:@"description"];
    }];
    
    RACSignal *InfoRecieved = [[DownloadManager sharedManager]getInfoWithQuerry:@"infoviewdata.json"];
    [InfoRecieved subscribeNext:^(NSDictionary *infoDict) {
        NSLog(@"%@",infoDict);
        self.infoDictionary = infoDict;
    }];
    
    RACSignal *logoRecieved = [[DownloadManager sharedManager]getInfoWithQuerry:@"logo.png"];
    [logoRecieved subscribeNext:^(UIImage *logo) {
        NSLog(@"logo");
        self.logo = logo;
    }];
    
    [[[RACSignal combineLatest:(@[topRecieved, supportRecieved, descriptionRecieved, InfoRecieved,logoRecieved])]
      deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        [self initUserInterface];
    }completed:^{
        [[[[DownloadManager sharedManager]getPictureCollection:self.urls] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSMutableArray<UIImage*> *images) {
            self.imageCollection = images;
            [self.collectionView reloadData];
        }];
    }];
    
    [[self.getButton rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        [self showAlertAndValidateData];
    }];
}

- (void)setUpBorders{
    self.collectionView.layer.borderWidth = 1;
    self.collectionView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.descrview.layer.borderWidth = 1;
    self.descrview.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.supportView.layer.borderWidth = 1;
    self.supportView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.bottomview.layer.borderWidth = 1;
    self.bottomview.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.getButton.layer.borderWidth = 2;
    self.getButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
}

- (void)showAlertAndValidateData{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Apple ID"
                                          message:@"Please enter your email and password"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Email";
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Password";
         textField.secureTextEntry = YES;
     }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //Do some stuff
    }];
    
    okAction.enabled = NO;
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    RACSignal *emailSignal = [alertController.textFields.firstObject.rac_textSignal filter:^BOOL(id value) {
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:((NSString*)value) options:0 range:NSMakeRange(0, [((NSString*)value) length])];
        return match ? YES : NO;
    }];
    
    RACSignal *passwordSignal =[alertController.textFields.lastObject.rac_textSignal filter:^BOOL(id value) {
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:((NSString*)value) options:0 range:NSMakeRange(0, [((NSString*)value) length])];
        return match ? YES : NO;
    }
    ];
    
    [[RACSignal combineLatest:(@[emailSignal,passwordSignal])]subscribeNext:^(NSNumber* x) {
        okAction.enabled = YES;
    }];
}

- (void)initUserInterface{
    //top
    self.productTitle.text = [self.topDictionary valueForKey:@"title"];
    self.productPublisher.text = [self.topDictionary valueForKey:@"publisher"];
    
    for (NSInteger i = 0; i<[[self.topDictionary valueForKey:@"rating"]integerValue]; i++) {
        self.productRaiting.text = [self.productRaiting.text stringByAppendingString:@"⭐️"];
    };
    
    self.productInfo.text = [self.topDictionary valueForKey:@"info"];
    //description
    self.descriptionLabel.text = self.descr;
    //support
    self.supportLabel.text = self.support;
    //info
    self.publisher.text = [self.infoDictionary valueForKey:@"publisher"];
    self.category.text = [self.infoDictionary valueForKey:@"category"];
    self.capabilities.text = [self.infoDictionary valueForKey:@"Compability"];
    self.size.text = [self.infoDictionary valueForKey:@"Size"];
    self.updated.text = [self.infoDictionary valueForKey:@"Released"];
    self.languages.text = [self.infoDictionary valueForKey:@"Languages"];
    self.limitations.text = [self.infoDictionary valueForKey:@"Limitations"];
    self.version.text = [self.infoDictionary valueForKey:@"Version"];
    self.fanilySharing.text = [self.infoDictionary valueForKey:@"Family_Sharing"];
    //logo
    self.productLogo.image = self.logo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageCollection.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[self.imageCollection objectAtIndex:indexPath.row]];
    return cell;
}

@end
