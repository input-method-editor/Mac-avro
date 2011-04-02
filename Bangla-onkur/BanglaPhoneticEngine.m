//
//  BanglaPhoneticEngine.m
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

#import "BanglaPhoneticEngine.h"


@implementation BanglaPhoneticEngine

- (id) init
{
	self = [super init];
	if (self != nil) {
		NSString *plistPath = [[[NSBundle mainBundle]pathForResource:@"Bangla_Language_Resources" ofType:@"plist"]retain];
		NSDictionary *plistData = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
		
		if (plistData != nil) {
			banglaCharConvTree = [[plistData objectForKey:@"Bangla Character Tree"] retain];
			
			if (banglaCharConvTree == nil) {
				return nil;
			}
			
			workingBuffer = [[NSMutableString alloc]init];
			outputBuffer = [[NSMutableString alloc]init];
			altOutputBufferArray = [[NSMutableArray alloc]init];
			outputBufferArray = [[NSMutableArray alloc]init];
			
			wasEndTerminator = YES;
			
			treeLevel = 0;
			replaceStartPosition = 0;
			replaceLength = 0;
			
			hasantaInserted = NO;
			
			previousBanglaChar = nil;
			lengthBeforeInitAndKaarCheck = 0;
			firstSemiColon = NO;
			secondSemiColon = NO;
			hintPosition = 0;
			outputArraySet = NO;
			alternativeHandled = NO;
			
			previousBangCharForAlt = [[NSMutableString alloc]init];
			previousAltChar = [[NSMutableString alloc]init];
			
			initSemiColonHandled = NO;
			
		}
		
		[plistData release];
		[plistPath release];
	}
	return self;
}

- (void) dealloc
{
	[banglaCharConvTree release];
	[workingBuffer release];
	[outputBuffer release];
	[altOutputBufferArray release];
	[outputBufferArray release];
	[previousBanglaChar release];
	
	[previousBangCharForAlt release];
	[previousAltChar release];
	
	[super dealloc];
}

- (NSMutableArray *) convert:(NSMutableString*) string WithHint:(NSArray *) hintArray {
	
	[workingBuffer setString:string];
	
	while ([workingBuffer length] != 0) {
		[self checkCharInTree:banglaCharConvTree withHint:hintArray];
		replaceStartPosition = 0;
		replaceLength = 0;
		hasantaInserted = NO;
		lengthBeforeInitAndKaarCheck = 0;
		alternativeHandled = NO;
	}
	
	if (outputArraySet) {
		return altOutputBufferArray;
	}
	
	[outputBufferArray addObject:outputBuffer];
	
	return outputBufferArray;
}

- (void) checkCharInTree:(NSDictionary *) tree withHint:(NSArray *) hintArray {
	
	NSRange charRange = NSMakeRange(treeLevel, 1), deleteRange, replaceRange, banglaCharRange;
	NSArray *treeElement;
	NSString *banglaChar;
	NSUInteger insertionPosition = 0;
	NSString *workingChar;
	
	
	
	if (([workingBuffer characterAtIndex:0] == ';') && (!initSemiColonHandled)) {
		[outputBuffer appendString:@";"];
		deleteRange = NSMakeRange(0, 1);
		[workingBuffer deleteCharactersInRange:deleteRange];
		return;
	} else {
		initSemiColonHandled = YES;
	}

	
	
	if (treeLevel < [workingBuffer length]) {
		workingChar = [[workingBuffer substringWithRange:charRange] retain];
		
		if (([workingChar isEqual:@";"]) && (!firstSemiColon)) {
			deleteRange = NSMakeRange(0, treeLevel + 1);
			[workingBuffer deleteCharactersInRange:deleteRange];
			firstSemiColon = YES;
			return;
		} else if (([workingChar isEqual:@";"]) && (firstSemiColon)) {
			secondSemiColon = YES;
			firstSemiColon = NO;
			initSemiColonHandled = NO;
				
			if ([outputBuffer characterAtIndex:[outputBuffer length] - 1] != ';') {
				replaceRange = NSMakeRange([outputBuffer length] - [previousAltChar length] - 1, [previousAltChar length]);
				[outputBuffer replaceCharactersInRange:replaceRange withString:previousBangCharForAlt];
			}
				
			[outputBuffer appendString:@";"];
			
			deleteRange = NSMakeRange(treeLevel, 1);
			[workingBuffer deleteCharactersInRange:deleteRange];
				
			
			return;
		} else {
			firstSemiColon = NO;
		}

		
		treeElement = [[tree objectForKey:workingChar] retain];
		
	} else {
		deleteRange = NSMakeRange(0, [workingBuffer length]);
		
		[workingBuffer deleteCharactersInRange:deleteRange];
		
		return;
	}
	
	
	if (treeElement != nil) {
		
		banglaChar = [[treeElement objectAtIndex:1]retain];
		
		BOOL isFrontTerminator = [[treeElement objectAtIndex:2]boolValue];
		BOOL isEndTerminator = [[treeElement objectAtIndex:3]boolValue];
		
		insertionPosition = [outputBuffer length];
		
		if (treeLevel == 0) {
			
			if (!wasEndTerminator && !isFrontTerminator) {
				
				[outputBuffer appendString:@"্"];
				hasantaInserted = YES;
			}
			
			lengthBeforeInitAndKaarCheck = [outputBuffer length];
			
			banglaCharRange = NSMakeRange([outputBuffer length] - 1, 1);
			
			if (lengthBeforeInitAndKaarCheck == 0) {
				
				if ([self isBanglaKaar:banglaChar]) {
					[outputBuffer appendString:[self initAndAfterKaarForm:banglaChar]];
				} else if (([banglaChar length] == 0) && ([workingChar isEqual:@"o"])) {
					[outputBuffer appendString:[self initAndAfterKaarShareOForm]];
				} else {
					[outputBuffer appendString:banglaChar];
				}
				
			} else {
				
				[previousBanglaChar release];
				previousBanglaChar = [[outputBuffer substringWithRange:banglaCharRange] retain];
				
				if ([previousBanglaChar isEqual:@"্"]) {
					banglaCharRange.location--;
					[previousBanglaChar release];
					previousBanglaChar = [[outputBuffer substringWithRange:banglaCharRange] retain];
				}
				
				if ([self isBanglaKaar:banglaChar]) {
					
					if (([self isBanglaKaar:previousBanglaChar]) || ((![self isBanglaChar:previousBanglaChar]) || ([self isBanglaVowel:previousBanglaChar]))) {
						[outputBuffer appendString:[self initAndAfterKaarForm:banglaChar]];
					} else {
						[outputBuffer appendString:banglaChar];
					}
					
					
				} else if (([banglaChar length] == 0) && ([workingChar isEqual:@"o"])) {
					
					if (([self isBanglaKaar:previousBanglaChar]) || ((![self isBanglaChar:previousBanglaChar]) || ([self isBanglaVowel:previousBanglaChar]))) {
						[outputBuffer appendString:[self initAndAfterKaarShareOForm]];
					} else {
						[outputBuffer appendString:banglaChar];
					}
					
				} else {
					[outputBuffer appendString:banglaChar];
				}
				
			}
			
			charBeforeReplaceWasEndTerminator = wasEndTerminator;
			
		}
		
		wasEndTerminator = isEndTerminator;
		
		NSDictionary *subTree = [[treeElement objectAtIndex:0]retain];
		
		if ([subTree count] == 0) {
			
			deleteRange = NSMakeRange(0,treeLevel + 1);
			[workingBuffer deleteCharactersInRange:deleteRange];
			
			if (treeLevel != 0) {
				
				replaceRange = NSMakeRange(replaceStartPosition, replaceLength);
				
				if (!isFrontTerminator && !charBeforeReplaceWasEndTerminator) {
					[outputBuffer insertString:@"্" atIndex:replaceStartPosition];
					replaceRange.location++;
					hasantaInserted = YES;
				} else {
					hasantaInserted = NO;
				}
				
				if (lengthBeforeInitAndKaarCheck == 0) {
					
					if ([self isBanglaKaar:banglaChar]) {
						[outputBuffer replaceCharactersInRange:replaceRange withString:[self initAndAfterKaarForm:banglaChar]];
					} else if (([banglaChar length] == 0) && ([workingChar isEqual:@"o"])) {
						[outputBuffer replaceCharactersInRange:replaceRange withString:[self initAndAfterKaarShareOForm]];
					} else {
						[outputBuffer replaceCharactersInRange:replaceRange withString:banglaChar];
					}
					
				} else {
					
					if ([self isBanglaKaar:banglaChar]) {
						
						if (([self isBanglaKaar:previousBanglaChar]) || ((![self isBanglaChar:previousBanglaChar]) || ([self isBanglaVowel:previousBanglaChar]))) {
							[outputBuffer replaceCharactersInRange:replaceRange withString:[self initAndAfterKaarForm:banglaChar]];
						} else {
							[outputBuffer replaceCharactersInRange:replaceRange withString:banglaChar];
						}

						
					} else if (([banglaChar length] == 0) && ([workingChar isEqual:@"o"])) {
						
						if (([self isBanglaKaar:previousBanglaChar]) || ((![self isBanglaChar:previousBanglaChar]) || ([self isBanglaVowel:previousBanglaChar]))) {
							[outputBuffer replaceCharactersInRange:replaceRange withString:[self initAndAfterKaarShareOForm]];
						} else {
							[outputBuffer replaceCharactersInRange:replaceRange withString:banglaChar];
						}
						
					} else {
						[outputBuffer replaceCharactersInRange:replaceRange withString:banglaChar];
					}
					
				}
				
			}
			
			if ([workingBuffer length] > 0) {
				charRange = NSMakeRange(0, 1);
				[workingChar release];
				workingChar = [[workingBuffer substringWithRange:charRange]retain];
				
				if (([workingChar isEqual:@";"]) && (!firstSemiColon)) {
					
					deleteRange = NSMakeRange(0, 1);
					[workingBuffer deleteCharactersInRange:deleteRange];
					firstSemiColon = YES;
					[self handleAlternativeOfTreeElement:treeElement withHints:hintArray];
					alternativeHandled = YES;
					
				} else if (([workingChar isEqual:@";"]) && (firstSemiColon)) {
					secondSemiColon = YES;
					firstSemiColon = NO;
					initSemiColonHandled = NO;
					
					if ([outputBuffer characterAtIndex:[outputBuffer length] - 1] != ';') {
						replaceRange = NSMakeRange([outputBuffer length] - [previousAltChar length], [previousAltChar length]);
						[outputBuffer replaceCharactersInRange:replaceRange withString:previousBangCharForAlt];
					}
					
					[outputBuffer appendString:@";"];
					
					deleteRange = NSMakeRange(treeLevel, 1);
					[workingBuffer deleteCharactersInRange:deleteRange];
					
				} else {
					firstSemiColon = NO;
				}
			}
			
		} else {
			
			if (treeLevel == 0) {
				
				replaceStartPosition = insertionPosition;
				
			} else {
				
				replaceRange = NSMakeRange(replaceStartPosition, replaceLength);
				
				if (!isFrontTerminator && !charBeforeReplaceWasEndTerminator) {
					[outputBuffer insertString:@"্" atIndex:replaceStartPosition];
					replaceRange.location++;
					hasantaInserted = YES;
				} else {
					hasantaInserted = NO;
				}
				
				if (lengthBeforeInitAndKaarCheck == 0) {
					
					if ([self isBanglaKaar:banglaChar]) {
						[outputBuffer replaceCharactersInRange:replaceRange withString:[self initAndAfterKaarForm:banglaChar]];
					} else if (([banglaChar length] == 0) && ([workingChar isEqual:@"o"])) {
						[outputBuffer replaceCharactersInRange:replaceRange withString:[self initAndAfterKaarShareOForm]];
					} else {
						[outputBuffer replaceCharactersInRange:replaceRange withString:banglaChar];
					}
					
				} else {
					
					if ([self isBanglaKaar:banglaChar]) {
						
						if (([self isBanglaKaar:previousBanglaChar]) || ((![self isBanglaChar:previousBanglaChar]) || ([self isBanglaVowel:previousBanglaChar]))) {
							[outputBuffer replaceCharactersInRange:replaceRange withString:[self initAndAfterKaarForm:banglaChar]];
						} else {
							[outputBuffer replaceCharactersInRange:replaceRange withString:banglaChar];
						}
						
						
					} else if (([banglaChar length] == 0) && ([workingChar isEqual:@"o"])) {
						
						if (([self isBanglaKaar:previousBanglaChar]) || ((![self isBanglaChar:previousBanglaChar]) || ([self isBanglaVowel:previousBanglaChar]))) {
							[outputBuffer replaceCharactersInRange:replaceRange withString:[self initAndAfterKaarShareOForm]];
						} else {
							[outputBuffer replaceCharactersInRange:replaceRange withString:banglaChar];
						}
						
					} else {
						[outputBuffer replaceCharactersInRange:replaceRange withString:banglaChar];
					}
					
				}
				
			}
			
			treeLevel++;
			
			if (lengthBeforeInitAndKaarCheck == 0) {
				
				if ([self isBanglaKaar:banglaChar]) {
					replaceLength = [[self initAndAfterKaarForm:banglaChar] length];
				} else if (([banglaChar length] == 0) && ([workingChar isEqual:@"o"])) {
					replaceLength = [[self initAndAfterKaarShareOForm] length];
				} else {
					replaceLength = [banglaChar length];
				}
				
			} else {
				
				if ([self isBanglaKaar:banglaChar]) {
					
					if (([self isBanglaKaar:previousBanglaChar]) || ((![self isBanglaChar:previousBanglaChar]) || ([self isBanglaVowel:previousBanglaChar]))) {
						replaceLength = [[self initAndAfterKaarForm:banglaChar] length];
					} else {
						replaceLength = [banglaChar length];
					}
					
					
				} else if (([banglaChar length] == 0) && ([workingChar isEqual:@"o"])) {
					
					if (([self isBanglaKaar:previousBanglaChar]) || ((![self isBanglaChar:previousBanglaChar]) || ([self isBanglaVowel:previousBanglaChar]))) {
						replaceLength = [[self initAndAfterKaarShareOForm] length];
					} else {
						replaceLength = [banglaChar length];
					}
					
				} else {
					replaceLength = [banglaChar length];
				}
			}
			
			if (hasantaInserted) {
				replaceLength++;
			}
			
			if ([workingBuffer length] > 1) {
				
				[self checkCharInTree:subTree withHint:hintArray];
				
				if ((firstSemiColon) && (!alternativeHandled)) {
					[self handleAlternativeOfTreeElement:treeElement withHints:hintArray];
					alternativeHandled = YES;
					
				}

			} else {
				deleteRange = NSMakeRange(0,1);
				[workingBuffer deleteCharactersInRange:deleteRange];
			}
			
			
			treeLevel--;
			
		}
		
		
		[subTree release];
		[banglaChar release];
		
	} else if (treeLevel == 0) {
		
		deleteRange = charRange;
		
		[outputBuffer appendString:workingChar];
		
		insertionPosition++;
		
		[workingBuffer deleteCharactersInRange:deleteRange];
		
		wasEndTerminator = YES;
		
	} else {
		
		deleteRange = NSMakeRange(0, treeLevel);
		
		[workingBuffer deleteCharactersInRange:deleteRange];
		
	}
	
	[workingChar release];
	[treeElement release];
	
}

- (BOOL) isBanglaChar:(NSString *)string {
	
	NSUInteger charLength = [string length];
	
	unichar character = [string characterAtIndex:charLength - 1];
	
	if (character >= 0x980 && character <= 0x9BD) {
		return YES;
	} else if (character == 0x9CE) {
		return YES;
	} else if (character >= 0x9DC && character <= 0x9DF) {
		return YES;
	}
	
	return NO;
}

- (BOOL) isBanglaKaar:(NSString *)string {
	
	NSUInteger charLength = [string length];
	
	if (charLength != 0) {
		
		unichar character = [string characterAtIndex:0];
		
		if (character >= 0x9BE && character <= 0x9C4) {
			return YES;
		} else if (character >= 0x9C7 && character <= 0x9C8) {
			return YES;
		} else if (character >= 0x9CB && character <= 0x9CC) {
			return YES;
		} else if (character == 0x9D7) {
			return YES;
		}
		
	}
	
	return NO;
}

- (BOOL) isBanglaVowel: (NSString *)string {
	
	NSUInteger charLength = [string length];
	
	if (charLength != 0) {
		
		unichar character = [string characterAtIndex:0];
		
		if (character >= 0x985 && character <= 0x98C) {
			return YES;
		} else if (character >= 0x98F && character <= 0x990) {
			return YES;
		} else if (character >= 0x993 && character <= 0x994) {
			return YES;
		}
		
	}
	
	return NO;
}

- (NSString *) initAndAfterKaarForm:(NSString *) string {
	
	unichar characters[20];
    [string getCharacters:characters];
	
	if (characters[0] >= 0x9BE && characters[0] <= 0x9CC) {
		characters[0] -= 0x38;
	}
    
    NSString *returnString = [NSString stringWithCharacters:characters length:[string length]];
    
	return returnString;
}

- (NSString *) initAndAfterKaarShareOForm {
	return [NSString stringWithString:@"অ"];
}

- (void) reset {
	[workingBuffer setString:@""];
	[outputBuffer setString:@""];
	
	wasEndTerminator = YES;
	
	treeLevel = 0;
	replaceStartPosition = 0;
	replaceLength = 0;
	
	hasantaInserted = NO;
	
	[previousBanglaChar release];
	previousBanglaChar = nil;
	lengthBeforeInitAndKaarCheck = 0;
	
	firstSemiColon = NO;
	hintPosition = 0;
	outputArraySet = NO;
	alternativeHandled = NO;
	
	[outputBufferArray removeAllObjects];
	[altOutputBufferArray removeAllObjects];
	
	initSemiColonHandled = NO;
	
}

- (void) handleAlternativeOfTreeElement:(NSArray *) treeElement 
							  withHints:(NSArray *)hintArray {
	
	NSRange replaceRange;
	
	NSString *banglaChar = [[treeElement objectAtIndex:1]retain];
	NSArray *alternatives = [[treeElement objectAtIndex:4]retain];
	
	if ([hintArray count] > hintPosition) {
		unsigned int selection = [[hintArray objectAtIndex:hintPosition]intValue];
		
		if ([alternatives count] > 0) {
			
			replaceRange = NSMakeRange([outputBuffer length] - [banglaChar length], [banglaChar length]);
			
			NSString *alternativeChar = [[alternatives objectAtIndex:selection] retain];
			
			[outputBuffer replaceCharactersInRange:replaceRange withString:alternativeChar];
			
			//This method will not be needed in the next version when the ligatures will checked for hasanta
			
			[self checkTerminationOfSelection:alternativeChar];
			
			[previousBangCharForAlt setString:banglaChar];
			[previousAltChar setString:alternativeChar];
			hintPosition++;
			[alternativeChar release];
			
			
		} else {
			[outputBuffer appendString:@";"];
			
			[previousBangCharForAlt setString:@""];
			[previousAltChar setString:@";"];
			
		}
		
	} else {
		
		if ([alternatives count] == 1) {
			
			replaceRange = NSMakeRange([outputBuffer length] - [banglaChar length], [banglaChar length]);
			
			NSString *alternativeChar = [alternatives objectAtIndex:0];
			
			[outputBuffer replaceCharactersInRange:replaceRange withString:alternativeChar];
			
			[previousBangCharForAlt setString:banglaChar];
			[previousAltChar setString:alternativeChar];
			
		} else if ([alternatives count] > 1) {
			
			NSRange tempBufferRange = NSMakeRange(0, [outputBuffer length] - [banglaChar length]);
			NSString *tempBuffer = [outputBuffer substringWithRange:tempBufferRange];
			
			[altOutputBufferArray removeAllObjects];
			
			for (unsigned int alter_counter = 0; alter_counter < [alternatives count]; alter_counter++) {
				
				NSMutableString *alterString = [tempBuffer mutableCopy];
				
				[alterString appendString:[alternatives objectAtIndex:alter_counter]];
				
				[altOutputBufferArray addObject:alterString];
				
				[alterString release];
			}
			
			outputArraySet = YES;
			
		} else {
			
			[outputBuffer appendString:@";"];
			
			[previousBangCharForAlt setString:@""];
			[previousAltChar setString:@";"];
			
		}
		
		
	}
	
	[alternatives release];
	[banglaChar release];
	
}

- (BOOL) areAlternatives {
	return outputArraySet;
}

- (void) checkTerminationOfSelection:(NSString *) selection {
	
	if ([selection isEqualToString:@"ষ"]) {
		wasEndTerminator = NO;
		return;
	}
	
	wasEndTerminator = YES;
	return;
	
}

@end
