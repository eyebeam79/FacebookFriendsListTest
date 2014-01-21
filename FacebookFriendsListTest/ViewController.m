//
//  ViewController.m
//  FacebookFriendsListTest
//
//  Created by SDT1 on 2014. 1. 21..
//  Copyright (c) 2014년 T. All rights reserved.
//

#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "ViewController.h"


#define FACEBOOK_APPID @"247349788772308"

@interface ViewController () <UITableViewDataSource, UITabBarDelegate>

@property (strong, nonatomic) ACAccount *facebookAccount;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) IBOutlet UITableView *table;

@end

@implementation ViewController

- (void)showTimeline
{
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey:FACEBOOK_APPID, ACFacebookPermissionsKey:@[@"read_stream"],
                              ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    
    [store requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error){
        if (error)
        {
            NSLog(@"Error: %@", error);
        }
        
        if (granted)
        {
            NSLog(@"권한 승인 성공");
            NSArray *accountList = [store accountsWithAccountType:accountType];
            self.facebookAccount = [accountList lastObject];
            
            // 패드 정보를 요청한다.
            [self requestFriends];
        }
        else
        {
            NSLog(@"권한 승인 실폐");
        }
    }];
}

- (void)requestFriends
{
    NSString *urlStr = @"https://graph.facebook.com/me/friends";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *params = nil;
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url
                                               parameters:params];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
        if(error != nil)
        {
            NSLog(@"Error: %@", error);
            return;
        }
        
        __autoreleasing NSError *parseError;
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&parseError];
        
        self.data = result[@"data"];
        // 메인 쓰레드에서 화면 업데이트
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.table reloadData];
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FRIEND_CELL" forIndexPath:indexPath];
    NSDictionary *one = self.data[indexPath.row];
    
    NSString *contents;
    
    // Friend name
    if (one[@"name"])
    {
        contents = [NSString stringWithFormat:@"%@", one[@"name"]];
    }

    
    cell.textLabel.text = contents;
    
    return cell;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showTimeline];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

