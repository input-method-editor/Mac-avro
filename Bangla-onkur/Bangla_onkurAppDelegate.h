//
//  Bangla_onkurAppDelegate.h
//  Bangla-onkur
//
//  Created by S. M. Raiyan Kabir on 23/03/2011.
//  Copyright 2011 City University London. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Bangla_onkurAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
