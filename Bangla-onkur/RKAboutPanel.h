//
//  RKAboutPanel.h
//  Bangla-onkur
//
//  Created by S. M. Raiyan Kabir on 06/04/2011.
//  Copyright 2011 City University London. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RKAboutPanel : NSWindowController {
@private
    
    IBOutlet NSImageView        *appIcon;
    IBOutlet NSTextField        *appName;
    IBOutlet NSTextField        *appVersion;
    IBOutlet NSTextView         *appCredits;
    IBOutlet NSTextField        *appCopyRight;
    
}

- (IBAction) showAboutPanel:(id) sender;

@end
