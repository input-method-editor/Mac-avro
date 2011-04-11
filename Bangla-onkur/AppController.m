//
//  AppController.m
//  Bangla-onkur
//
//  Created by S. M. Raiyan Kabir on 08/04/2011.
//  Copyright 2011 City University London. All rights reserved.
//

#import "AppController.h"
#import "RKAboutPanel.h"


@implementation AppController

- (id)init
{
    self = [super init];
    if (self) {
        
        aboutPanel = [[RKAboutPanel alloc]init];
        NSLog(@"Allocation AppController");
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [aboutPanel release];
    [super dealloc];
}

- (IBAction) showAboutPanel:(id) sender {
    
    NSLog(@"App controller");
    
    //[aboutPanel showAboutPanel:self];
    [aboutPanel showWindow:sender];
    
    
}

@end
