//
//  ViewController.m
//  Chuckles
//
//  Created by William Gray on 6/26/18.
//  Copyright © 2018 Zetetic, LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSTextViewDelegate>

@property (getter=isInterceptingSelection) BOOL interceptingSelection;
- (void)_applyDataDetection;
- (void)_removeDataDetection;
@end

@implementation ViewController

@synthesize textView = _textView;
@synthesize toggleButton = _toggleButton;
@synthesize editing = _editing;
@synthesize interceptingSelection = _interceptingSelection;

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self != nil) {
        _editing = NO;
        _interceptingSelection = YES;
    }
    return self;
}

- (void)textViewDidChangeSelection:(NSNotification *)notification {
//    BOOL previouslyEditing = self.editing;
    NSRect frameClicked;
    [[[[[NSApplication sharedApplication] mainWindow] firstResponder] valueForKey:@"frame"] getValue:&frameClicked];
    // If the first responder is a text view, the frameclicked is at x=0, and we haven't already intercepted selection...
    if ([[[[NSApplication sharedApplication] mainWindow] firstResponder] isKindOfClass:[NSTextView class]]
        && frameClicked.origin.x == 0
        && self.isInterceptingSelection == NO) {
        // ... then the user has clicked in the TextView, begin editing (if ... not already?)
        self.interceptingSelection = YES;
        self.editing = YES;
    }
    // Responding to state change...
}

- (void)setEditing:(BOOL)editing {
    // Update tracking var
    _editing = editing;
    // Adjust the textView accordingly (ensure main thread)
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.textView.editable = self->_editing;
        // Data detectors are not permitted on an editable textView
        if (self->_editing) {
            [self _removeDataDetection];
        } else {
            if (self.isDataDetectorsEnabled) {
                [self _applyDataDetection];
            }
        }
        self.interceptingSelection = self->_editing;
    }];
}

- (BOOL)editing {
    return _editing;
}

- (void)_applyDataDetection {
    [self.textView setAutomaticDataDetectionEnabled:YES];
    [self.textView setAutomaticLinkDetectionEnabled:YES];
    [self.textView setEditable:YES];
    [self.textView checkTextInDocument:nil];
    [self.textView setEditable:NO];
}

- (void)_removeDataDetection {
    [self.textView setAutomaticDataDetectionEnabled:NO];
    [self.textView setAutomaticLinkDetectionEnabled:NO];
    // Ideally, we'd call the reverse of `checkTextInDocument:` but the following seems our only option
    [[self.textView textStorage] removeAttribute:NSLinkAttributeName
                                           range:NSMakeRange(0, [[self.textView string] length])];
    // Reset the foreground color for all text by removing the attr...
    [[self.textView textStorage] removeAttribute:NSForegroundColorAttributeName
                                           range:NSMakeRange(0, [[self.textView string] length])];
    // ...and setting it back to the textColor for the effective appearance
    [self.textView.textStorage addAttribute:NSForegroundColorAttributeName
                                      value:[NSColor textColor]
                                      range:NSMakeRange(0, [[self.textView string] length])];
}

- (IBAction)toggleDataHighlights:(id)sender {
    if ([(NSButton*)sender state] == NSControlStateValueOn) {
        [self _applyDataDetection];
    } else {
        [self _removeDataDetection];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear {
    [super viewDidAppear];
    if (self.isDataDetectorsEnabled) {
        [self _applyDataDetection];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (BOOL)isDataDetectorsEnabled {
    return ([self.toggleButton state] == NSControlStateValueOn);
}

@end
