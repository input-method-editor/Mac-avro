//
//  RKAboutPanel.m
//  Bangla-onkur
//
//  Created by S. M. Raiyan Kabir on 06/04/2011.
//  Copyright 2011 City University London. All rights reserved.
//

#import "RKAboutPanel.h"


@implementation RKAboutPanel

- (id)init
{
    
    self = [super initWithWindowNibName:@"RKAboutPanel"];
    
    if (!self) {
        
        NSLog(@"Couldn't initialize the About Panel");
        
        return nil;
    }
    
    NSLog(@"Initialized About Panel");
    
    //[self loadWindow];
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSLog(@"Loading the About Panel");
    
    [appIcon setImage:[NSApp applicationIconImage]];
    [appName setStringValue:@"Bangla-অঙ্কুর"];
    [appVersion setStringValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [appCopyRight setStringValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"NSHumanReadableCopyright"]];
    [appCredits readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"rtf"]]; 
}

- (IBAction) showAboutPanel:(id) sender {
    
    NSLog(@"About panel");
    
    [[self window] orderFrontRegardless];
    
}

@end
