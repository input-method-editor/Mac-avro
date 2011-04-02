//
//  main.m
//  Bangla - Onkur
//
//  Created by S. M. Raiyan Kabir on 23/01/2011.
//

/*
 The MIT License
 
 Copyright (c) 2011 S. M. Raiyan Kabir
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

//Each input method needs a unique connection name. 
//Note that periods and spaces are not allowed in the connection name.
const NSString* kConnectionName = @"Onkur_Connection";

//let this be a global so our application controller delegate can access it easily
IMKServer*			server;

int main(int argc, char *argv[])
{
    
    NSString*       identifier;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//find the bundle identifier and then initialize the input method server
    identifier = [[NSBundle mainBundle] bundleIdentifier];
    server = [[IMKServer alloc] initWithName:(NSString*)kConnectionName bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
	
    //load the bundle explicitly because in this case the input method is a background only application 
	[NSBundle loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication]];
	
	//finally run everything
	[[NSApplication sharedApplication] run];
	
	[server release];
	
    [pool release];
    return 0;
}