//
//  ChatViewController.m
//  ParseChat
//
//  Created by Julie Herrick on 7/6/20.
//  Copyright © 2020 Julie Herrick. All rights reserved.
//

#import "ChatViewController.h"
#import <Parse/Parse.h>
#import "ChatCell.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *chatMessageField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *messages;


@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:true];
}

- (void)onTimer {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Message_fbu2019"];
    [query orderByDescending:@"createdAt"];
    query.limit = 20;
    [query includeKey:@"user"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            // do something with the array of object returned by the call
            self.messages = posts;
            
            [self.tableView reloadData];
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (IBAction)onSend:(id)sender {
    PFObject *chatMessage = [PFObject objectWithClassName:@"Message_fbu2020"];
    
    // Use the name of your outlet to get the text the user typed
    chatMessage[@"text"] = self.chatMessageField.text;
    chatMessage[@"user"] = PFUser.currentUser;
    
    [chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The message was saved!");
            self.chatMessageField.text = @"";
        } else {
            NSLog(@"Problem saving message: %@", error.localizedDescription);
        }
    }];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    PFObject *post = [self.messages objectAtIndex:indexPath.row];
    cell.messageText.text = post[@"text"];
    
    PFUser *user = post[@"user"];
    if (user != nil) {
        cell.usernameLabel.text = user.username;
    } else {
        cell.usernameLabel.text = @"🤖";
    }
    
    cell.messageText.clipsToBounds = true;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
