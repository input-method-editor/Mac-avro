//
//  AppController.h
//  Bangla-onkur
//
//  Created by S. M. Raiyan Kabir on 08/04/2011.
//  Copyright 2011 City University London. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RKAboutPanel;
@interface AppController : NSObject {
@private
    
    RKAboutPanel *aboutPanel;
    
}

- (IBAction) showAboutPanel:(id) sender;

@end
