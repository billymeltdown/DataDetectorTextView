//
//  ViewController.h
//  Chuckles
//
//  Created by William Gray on 6/26/18.
//  Copyright © 2018 Zetetic, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (strong) IBOutlet NSTextView *textView;
@property (strong) IBOutlet NSButton *toggleButton;
@property (strong) IBOutlet NSButton *editButton;
@property (readonly, getter=isDataDetectorsEnabled) BOOL dataDetectorsEnabled;
@property BOOL editing;

- (IBAction)toggleDataHighlights:(id)sender;

@end

