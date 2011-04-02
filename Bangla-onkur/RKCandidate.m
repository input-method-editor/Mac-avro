//
//  RKCandidate.m
//  Input Method Tester
//
//  Created by S. M. Raiyan Kabir on 05/11/2010.
//

/*
 The MIT License
 
 Copyright (c) 2010 S. M. Raiyan Kabir
 
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

#import "RKCandidate.h"
#import "OnkurController.h"


@implementation RKCandidate

#pragma mark -
#pragma mark Initialization and Deallocation

- (id) initWithClient:(id) client
{
	self = [super initWithWindowNibName:@"RKCandidate"];
	if (self != nil) {
		_client = client;
		selectionIndex = [[NSMutableIndexSet alloc] initWithIndex:0];
		
		//shouldSetFont = NO;
		
		//if ([self isWindowLoaded]) {
			
			NSArray *operatingSystemVersionStringComponents = [[[NSProcessInfo processInfo] operatingSystemVersionString] componentsSeparatedByString:@" "];
			
			NSArray *operatingSystemVersionComponents = [[operatingSystemVersionStringComponents objectAtIndex:1] componentsSeparatedByString:@"."];
			
			NSInteger operatingSystemMajorVersion = [[operatingSystemVersionComponents objectAtIndex:1] intValue];
			
			if (operatingSystemMajorVersion > 6) {
				candidateFont = [NSFont fontWithName:@"Bangla Sangam MN" size:18];
			} else {
                candidateFont = [NSFont fontWithName:@"Ekushey Lohit Normal" size:18];
            }
			
			NSLog(@"System Major Version: %ld", operatingSystemMajorVersion);
			//NSLog(@"Should Set Font: %i", shouldSetFont);
		//}
		
	}
	
	return self;
}

- (void) dealloc
{
	[selectionIndex release];
	[super dealloc];
}

- (void) reset {
	
	[selectionIndex removeAllIndexes];
	[selectionIndex addIndex:0];
}


#pragma mark -
#pragma mark Candidate Window Methods


- (void) hide {
	[candidatePanel orderOut:self];
}

- (void) updateCandidate {
	
	optionsArray = [_client composedStringArray:self];
	[candidateOptions selectRowIndexes:selectionIndex byExtendingSelection:NO];
	
}

- (void) updateCandidatePosition {
	NSPoint candidatePosition = [_client cursorPosition];
	candidatePosition.y -= 5;
	[candidatePanel setFrameTopLeftPoint:candidatePosition];
	
}

- (void) setCandidate {
	
	if (![self isWindowLoaded]) {
		[self loadWindow];
		[candidatePanel setBecomesKeyOnlyIfNeeded:YES];
		[candidatePanel setLevel:NSPopUpMenuWindowLevel];
		[candidateOptions setAllowsColumnSelection:NO];
		[candidateOptions selectRowIndexes:selectionIndex byExtendingSelection:NO];
		
	}
	
	NSTableColumn *column = [[candidateOptions tableColumns] objectAtIndex:0];
	
	float width = 0.0, height = 0.0;
    
    NSLog(@"no of options: %lu", [optionsArray count]);
	
	for (int i = 0; i < [optionsArray count]; i++) {
		NSCell *option = [column dataCellForRow:i];
		
		[option setStringValue:[optionsArray objectAtIndex:i]];
		
        [option setFont:candidateFont]; 
		
		float optionWidth = [option cellSize].width;
		
		width = (optionWidth > width)? optionWidth : width;
		height = [option cellSize].height + 2;
		
	}
	
	NSLog(@"Width = %f, Height = %f\n", width, height);
	
	[column setMinWidth:width];
	[column setWidth:width];
	
	[candidateOptions setRowHeight:height];
	
	NSRect candidateFrame = [candidatePanel frame];
	candidateFrame.size.width = width;
	candidateFrame.size.height = [optionsArray count]*(height + 2);
	
	NSLog(@"candidateFrame height: %f", candidateFrame.size.height);
	
	[candidateOptions reloadData];
	[candidatePanel setFrame:candidateFrame display:YES];
	[self updateCandidatePosition];
	
	if (![candidatePanel isVisible]) {
		[candidatePanel orderFrontRegardless];
	}
	
}

- (NSInteger) selectedCandidateIndex {
	
	return [selectionIndex firstIndex];
	
}


#pragma mark -
#pragma mark TableView Data Source Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	
	return [optionsArray count];
}

- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex {
	
	return [optionsArray objectAtIndex:rowIndex];
}

- (void) moveSelectionUpward {
	
	NSInteger currentSelection = [selectionIndex firstIndex];
	
	if (currentSelection > 0) {
		currentSelection--;
		NSLog(@"currentSelection is: %ld", currentSelection);
		[selectionIndex removeAllIndexes];
		[selectionIndex addIndex:currentSelection];
		[candidateOptions selectRowIndexes:selectionIndex byExtendingSelection:NO];
	}
}

- (void) moveSelectionDownward {
	
	NSInteger currentSelection = [selectionIndex firstIndex];
	
	if (currentSelection < [optionsArray count] - 1) {
		currentSelection++;
		NSLog(@"currentSelection is: %ld", currentSelection);
		[selectionIndex removeAllIndexes];
		[selectionIndex addIndex:currentSelection];
		[candidateOptions selectRowIndexes:selectionIndex byExtendingSelection:NO];
	}
	
}

@end
