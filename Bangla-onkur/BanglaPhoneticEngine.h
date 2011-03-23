//
//  BanglaPhoneticEngine.h
//  Input Method Tester
//
//  Created by S. M. Raiyan Kabir on 18/07/2010.
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

#import <Cocoa/Cocoa.h>


@interface BanglaPhoneticEngine : NSObject {

	NSDictionary		*banglaCharConvTree;
	NSMutableString		*workingBuffer;
	NSMutableString		*outputBuffer;
	NSMutableArray		*altOutputBufferArray;
	NSMutableArray		*outputBufferArray;
	
	BOOL				wasEndTerminator;
	
	NSUInteger          treeLevel;
	NSUInteger          replaceStartPosition;
	NSUInteger          replaceLength;
	
	BOOL				charBeforeReplaceWasEndTerminator;
	BOOL				hasantaInserted;
	
	NSString			*previousBanglaChar;
	NSUInteger          lengthBeforeInitAndKaarCheck;
	
	BOOL				firstSemiColon;
	BOOL				secondSemiColon;
	NSUInteger          hintPosition;
	BOOL				outputArraySet;
	BOOL				alternativeHandled;
	
	BOOL				initSemiColonHandled;
	
	NSMutableString		*previousBangCharForAlt;
	NSMutableString		*previousAltChar;
	
}

- (NSMutableArray *) convert:(NSMutableString*) string 
			 WithHint:(NSArray *) hintArray;
- (void) checkCharInTree:(NSDictionary *) tree 
				withHint:(NSArray *) hintArray;
- (BOOL) isBanglaChar:(NSString *)string;
- (BOOL) isBanglaKaar:(NSString *)string;
- (BOOL) isBanglaVowel: (NSString *)string;
- (NSString *) initAndAfterKaarForm:(NSString *)string;
- (NSString *) initAndAfterKaarShareOForm;
- (void) handleAlternativeOfTreeElement:(NSArray *) treeElement 
							  withHints:(NSArray *)hintArray;
- (void) checkTerminationOfSelection:(NSString *) selection;
- (void) reset;
- (BOOL) areAlternatives;

@end
