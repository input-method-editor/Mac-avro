//
//  OnkurController.m
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

#import "OnkurController.h"
#import "BanglaPhoneticEngine.h"
#import "RKCandidate.h"


@implementation OnkurController

#pragma mark Initialization and Deallocation

- (void) initEngine
{
	
	
	banglaEngine = [[BanglaPhoneticEngine alloc]init];
	rkCandidate = [[RKCandidate alloc]initWithClient:self];
	
	originalBuffer = [[NSMutableString alloc]init];
	cursorPositionRange = NSMakeRange(0, 0);
	
	hintArray = [[NSMutableArray alloc]init];
	hintPositionArray = [[NSMutableArray alloc]init];
	
	converting = NO;
	usingBangla = NO;

}

- (void) dealloc
{
	[banglaEngine release];
	[rkCandidate release];
	[originalBuffer release];
	[previousText release];
	[intermediateDisplayString release];
	[hintArray release];
	[hintPositionArray release];
	[alphaKeySet release];
	[super dealloc];
}

#pragma mark -
#pragma mark Event Handling

-(BOOL)handleEvent:(NSEvent*)event client:(id)sender {
	
	NSLog(@"Event Started");
	
	if ((sender == nil) || (![sender conformsToProtocol:@protocol(IMKTextInput)])) {
		NSLog(@"client does not conform to IMKTextInput Protocol");
		return NO;
	}
	
	if (client == nil) {
		client = sender;
	}
	
	if (banglaEngine == nil) {
		[self initEngine];
	}
	
	// Exit in a mouse even
	
	NSEventType eventType = [event type];
	
	if ((eventType == NSLeftMouseDown) || (eventType == NSRightMouseDown)) {
		
		if ([convertBufferArray count] > 0) {
			[client insertText:[convertBufferArray objectAtIndex:0] 
			  replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
		}
		
		[self reset];
		
		return NO;
	}
	
	NSUInteger modifier = [event modifierFlags];
	
	NSLog(@"Modifier: %lu", modifier);
	
	if (modifier & NSCommandKeyMask) {
		
		NSLog(@"Command Key Pressed");
		
		if (usingBangla) {
			if ([convertBufferArray count] > 0) {
				[client insertText:[convertBufferArray objectAtIndex:0] 
				  replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
			}
			usingBangla = NO;
		}
		
		[self reset];
		
		return NO;
		
	}
	
	RKCandidateDirection direction = 0;
	unsigned short kCode = [event keyCode];
	NSString *inputChar = [event characters];
	
	NSLog(@"input Char: %@", inputChar);
	
	if (modifier & NSAlphaShiftKeyMask) {
		
		if (usingBangla) {
			if ([convertBufferArray count] > 0) {
				[client insertText:[convertBufferArray objectAtIndex:0] 
				  replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
			}
			[self reset];
			usingBangla = NO;
		}
		
		if (modifier & NSShiftKeyMask) {
			
			if (([inputChar characterAtIndex:0] >= 0x41) && ([inputChar characterAtIndex:0] <= 0x5A)) {
				[client insertText:inputChar 
				  replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
				return YES;
			}
			
			return NO;
		}
		
		if (([inputChar characterAtIndex:0] >= 0x41) && ([inputChar characterAtIndex:0] <= 0x5A)) {
			
			[client insertText:[inputChar lowercaseString] 
			  replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
			
			NSLog(@"Char: %@",[inputChar lowercaseString]);
			
			return YES;
		}
		
		return NO;
		
	}
	
	
	if (kCode == 125) { //down arrow
		
		if (converting) {
			direction = RKDownward;
			[self changeSelectionInDirection:direction];
			return YES;
		}
		
	} else if (kCode == 126) { //up arrow
		
		if (converting) {
			direction = RKUpward;
			[self changeSelectionInDirection:direction];
			return YES;
		}
		
	} else if (kCode == 123) { //left arrow
		
		if (converting) {
			NSBeep();
			return YES;
		}
		
	} else if (kCode == 124) { //right arrow
		
		if (converting) {
			NSBeep();
			return YES;
		}
		
	} else if (kCode == 48) { // tab
		if ([convertBufferArray count] > 0) {
			[client insertText:[convertBufferArray objectAtIndex:0] 
			  replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
		}
		[self reset];
		return NO;
		
	} else if (kCode == 51) { // delete key
		
		NSInteger selectionLength = [client selectedRange].length;
		
		NSLog(@"selectionLength: %ld, location: %lu", selectionLength, [client selectedRange].location);
		
		if ([originalBuffer length] != 0) {
			[self deleteLast];
			[rkCandidate updateCandidate];
			[rkCandidate setCandidate];
			
			if ([originalBuffer length] == 0) {
				[rkCandidate hide];
			}
			
			return YES;
			
		} else {
			
			[self reset];			
		}
		
	} else if ((kCode == 49) || ((kCode == 36) || (kCode == 76))) { // space, enter and return keys
		
		[originalBuffer appendString:inputChar];
		
        NSLog(@"space, originalBuffer: %@", originalBuffer);
        
		[self convertText];
		[client insertText:[convertBufferArray objectAtIndex:0] 
		  replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
		
		usingBangla = NO;
		
		[self reset];
		
		return YES;
		
	} else {
		
		if (!usingBangla) {
			usingBangla = YES;
		}
		
		converting = YES;
		
		if ([self alphaKeyCode:kCode]) {
			
			[originalBuffer appendString:inputChar];
			
            NSLog(@"originalBuffer: %@", originalBuffer);
            
			[self convertText];
            NSLog(@"no of options in controller: %ld", [convertBufferArray count]);
			
			[rkCandidate updateCandidate];
			[rkCandidate setCandidate];
			
			[client setMarkedText:originalBuffer selectionRange:NSMakeRange(0, [originalBuffer length]) 
				 replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
			
			return YES;
			
		}
	}
	
	return NO;
	
}

#pragma mark -
#pragma mark Controller Methods

-(NSArray *) composedStringArray:(id)sender {
	
	return convertBufferArray;
}

- (NSString *) originalString:(id)sender {
	return originalBuffer;
}

- (void) convertText {
	NSAutoreleasePool *banglaPool = [[NSAutoreleasePool alloc]init];
	if (banglaEngine != nil) {
		
		if ([banglaEngine areAlternatives]) {
			[hintArray addObject:[NSNumber numberWithUnsignedInteger:[rkCandidate selectedCandidateIndex]]];
		}
		
		[banglaEngine reset];
		[rkCandidate reset];
		
        NSLog(@"before conversion originalBuffer: %@", originalBuffer);
        
		convertBufferArray = [banglaEngine convert:originalBuffer WithHint:hintArray];
		
        NSLog(@"options in ConvrtText: %ld", [convertBufferArray count]);
        
		if ([banglaEngine areAlternatives]) {
			[hintPositionArray addObject:[NSNumber numberWithUnsignedInteger:[originalBuffer length]]];
		}
		
	}
	
	[banglaPool drain];
}

- (void) changeSelectionInDirection:(RKCandidateDirection) direction {
	
	if (direction == RKUpward) {
		[rkCandidate moveSelectionUpward];
	} else {
		[rkCandidate moveSelectionDownward];
	}

}

- (void) deleteLast {
	
	NSLog(@"Deleteing Last Char");
	
	if ([[hintPositionArray lastObject] intValue] == [originalBuffer length]) {
		
		if ([hintPositionArray count] == [hintArray count]) {
			[hintPositionArray removeLastObject];
			[hintArray removeLastObject];
			[banglaEngine reset];
			[self convertText];
			[client setMarkedText:originalBuffer selectionRange:NSMakeRange(0, [originalBuffer length]) 
				 replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
			return;
		} else {
			[hintPositionArray removeLastObject];
			[banglaEngine reset];
		}
		
	}
	
	[originalBuffer deleteCharactersInRange:NSMakeRange([originalBuffer length] - 1, 1)];
	[self convertText];
	[client setMarkedText:originalBuffer selectionRange:NSMakeRange(0, [originalBuffer length]) 
		 replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
	
}

- (NSPoint) cursorPosition {
	NSRect cursorRect = [client firstRectForCharacterRange:cursorPositionRange];
	
	NSLog(@"Position of cursor x:%f, y:%f\n", cursorRect.origin.x, cursorRect.origin.y);
	
	return cursorRect.origin;
}

- (BOOL) alphaKeyCode:(NSInteger) keyCode {
	if (((keyCode >= 0) && (keyCode < 10)) || (((keyCode >= 11) && (keyCode < 49)) || (keyCode == 50))) {
		return YES;
	}
	
	return NO;
}

-(void)commitComposition:(id)sender {
	
	NSLog(@"commitComposition was called\n");
	NSLog(@"Re-initializing");
	
	if ([convertBufferArray count] > 0) {
		[client insertText:[convertBufferArray objectAtIndex:0] 
		  replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
	}
	
	client = nil;
	
	[self reset];
	
	NSLog(@"Exiting");
	
}

- (id) client {
	return client;
}


- (void) reset {
	
	[originalBuffer setString:@""];
	[convertBufferArray removeAllObjects];
	[hintPositionArray removeAllObjects];
	[hintArray removeAllObjects];
	[banglaEngine reset];
	[rkCandidate hide];
	converting = NO;
}
@end
