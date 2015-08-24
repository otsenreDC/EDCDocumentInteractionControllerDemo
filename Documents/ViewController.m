//
//  ViewController.m
//  Documents
//
//  Created by Ernesto De los Santos Cordero on 8/24/15.
//  Copyright (c) 2015 Bananalabs. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (strong, nonatomic) NSMutableData *data;
@property (nonatomic) long long expectedContentSize;

@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UIButton *openButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadAndPreviewButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)previewDocument:(UIButton *)sender
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"avatar" withExtension:@"jpg"];
    
    if (url) {
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.documentInteractionController.delegate = self;
        [self.documentInteractionController presentPreviewAnimated:YES];
    }
}

- (IBAction)openDocument:(UIButton *)sender
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"document" withExtension:@"pdf"];
    if (url) {
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.documentInteractionController.delegate = self;
        [self.documentInteractionController presentOpenInMenuFromRect:sender.frame inView:self.view animated:YES];
    }
}

- (IBAction)downloadAndPreviewDocument:(UIButton *)sender
{
    [self setButtonsEnable:NO];
    [self download];
}

#pragma mark - Download
- (void)download
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/iPhoneAppProgrammingGuide.pdf"]];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    [connection start];
}

#pragma mark - URL Connection Data Delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error : %@", error.localizedDescription);
    [self setButtonsEnable:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
    if (self.expectedContentSize == self.data.length) {
        NSLog(@"Done");
        NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];        // get /tmp folder path
        NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"temp_pdf"] URLByAppendingPathExtension:@"pdf"];
        [self.data writeToURL:fileURL atomically:YES];
        
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        self.documentInteractionController.delegate = self;
        [self.documentInteractionController presentPreviewAnimated:YES];
        
        
        /*
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         NSString *file = [documentsDirectory stringByAppendingPathComponent:@"temp.pdf"];
         
         NSError *error = nil;
         if ([self.data writeToFile:file options:NSDataWritingAtomic error:&error]) {
         // file saved
         NSLog(@"%@", file);
         self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:file]];
         self.documentInteractionController.delegate = self;
         [self.documentInteractionController presentPreviewAnimated:YES];
         } else {
         // error writing file
         NSLog(@"Unable to write PDF to %@. Error: %@", file, error);
         }
         */
        
        [self setButtonsEnable:YES];
        
    } else {
        NSLog(@"Waiting");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data = [NSMutableData new];
    self.expectedContentSize = response.expectedContentLength;
}

#pragma mark - Document Intersaction Controller Delegate

-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

#pragma mark - Helpers
- (void)setButtonsEnable:(BOOL)enable
{
    self.previewButton.enabled = enable;
    self.openButton.enabled = enable;
    self.downloadAndPreviewButton.enabled = enable;
}

@end
