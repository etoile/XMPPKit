//
//  TRXMLXHTML-IMParser.m
//  Jabber
//
//  Created by David Chisnall on 16/05/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TRXMLXHTML-IMParser.h"
#import "../Macros.h"

#define TRIM(x) [x stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]



inline NSColor * colourFromCSSColourString(NSString * aColour)
{
	const char * colourString = [aColour UTF8String];
	int r,g,b;
	if(sscanf(colourString, "#%2x%2x%2x", &r, &g, &b) == 3 || sscanf(colourString, "#%2X%2X%2X", &r, &g, &b) == 3)
	{
		return [NSColor colorWithCalibratedRed:((float)r)/255.0f
										 green:((float)g)/255.0f
										  blue:((float)b)/255.0f
										 alpha:1.0f];
	}
	if(sscanf(colourString, "#%1x%1x%1x", &r, &g, &b) == 3 || sscanf(colourString, "#%1X%1X%1X", &r, &g, &b) == 3)
	{
		return [NSColor colorWithCalibratedRed:((float)r)/15.0f
										 green:((float)g)/15.0f
										  blue:((float)b)/15.0f
										 alpha:1.0f];
	}
	if(sscanf(colourString, "rgb( %d%% , %d%% , %d%% )", &r, &g, &b))
	{
		return [NSColor colorWithCalibratedRed:((float)r)/100.0f
										 green:((float)g)/100.0f
										  blue:((float)b)/100.0f
										 alpha:1.0f];
	}
	if(sscanf(colourString, "rgb( %d , %d , %d )", &r, &g, &b))
	{
		return [NSColor colorWithCalibratedRed:((float)r)/255.0f
										 green:((float)g)/255.0f
										  blue:((float)b)/255.0f
										 alpha:1.0f];
	}
	if([aColour isEqualToString:@"aqua"])
	{
		return [NSColor cyanColor];
	}
	if([aColour isEqualToString:@"black"])
	{
		return [NSColor blackColor];
	}
	if([aColour isEqualToString:@"blue"])
	{
		return [NSColor blueColor];
	}
	if([aColour isEqualToString:@"fuchsia"])
	{
		return [NSColor magentaColor];
	}
	if([aColour isEqualToString:@"gray"])
	{
		return [NSColor grayColor];
	}
	if([aColour isEqualToString:@"green"])
	{
		return [NSColor greenColor];
	}
	if([aColour isEqualToString:@"lime"])
	{
		return [NSColor colorWithCalibratedRed:0.0f
										 green:1.0f
										  blue:0.0f
										 alpha:1.0f];
	}
	if([aColour isEqualToString:@"maroon"])
	{
		return [NSColor colorWithCalibratedRed:0.5f
										 green:0.0f
										  blue:0.0f
										 alpha:1.0f];
	}
	if([aColour isEqualToString:@"navy"])
	{
		return [NSColor colorWithCalibratedRed:0.0f
										 green:0.0f
										  blue:0.5f
										 alpha:1.0f];
	}
	if([aColour isEqualToString:@"olive"])
	{
		return [NSColor colorWithCalibratedRed:0.0f
										 green:0.5f
										  blue:0.0f
										 alpha:1.0f];
	}
	if([aColour isEqualToString:@"purple"])
	{
		return [NSColor purpleColor];
	}
	if([aColour isEqualToString:@"red"])
	{
		return [NSColor redColor];
	}
	if([aColour isEqualToString:@"silver"])
	{
		return [NSColor lightGrayColor];
	}
	if([aColour isEqualToString:@"teal"])
	{
		return [NSColor colorWithCalibratedRed:0.0f
										 green:0.5f
										  blue:0.5f
										 alpha:1.0f];
	}
	if([aColour isEqualToString:@"white"])
	{
		return [NSColor whiteColor];
	}
	if([aColour isEqualToString:@"yellow"])
	{
		return [NSColor yellowColor];
	}
	return [NSColor blackColor];
}

inline NSMutableDictionary * attributesFromStyles(NSDictionary * oldAttributes, NSString * style)
{
	NSFontManager * fontManager = [NSFontManager sharedFontManager];
	NSMutableDictionary * attributes = [[NSMutableDictionary alloc] initWithDictionary:oldAttributes];
	NSFont * font = [attributes objectForKey:NSFontAttributeName];
	if(font == nil)
	{
		font = [NSFont userFontOfSize:12.0f];
	}
	
	NSArray * styles = [style componentsSeparatedByString:@";"];
	//Parse each CSS property
	FOREACH(styles, theStyle, NSString*)
	{
		NSArray * styleComponents = [theStyle componentsSeparatedByString:@":"];
		if([styleComponents count] == 2)
		{
			NSString * key = TRIM([styleComponents objectAtIndex:0]);
			NSString * value = TRIM([styleComponents objectAtIndex:1]);
			if([key isEqualToString:@"color"])
			{
				[attributes setObject:colourFromCSSColourString(value)
							   forKey:NSForegroundColorAttributeName];
			}
			else if([key isEqualToString:@"background-color"])
			{
				[attributes setObject:colourFromCSSColourString(value)
							   forKey:NSBackgroundColorAttributeName];
			}
			else if([key isEqualToString:@"font-family"])
			{
				NSFont * oldFont = font;
				NSArray * families = [value componentsSeparatedByString:@","];
				unsigned int numberOfFamilies = [families count];
				
				for(unsigned int i=0 ; i<numberOfFamilies ; i++)
				{
					//Try setting the new font family
					font = [fontManager convertFont:font
										   toFamily:TRIM([families objectAtIndex:i])];
					//If it worked, then use it
					if(font != oldFont)
					{
						break;
					}
				}
				
			}
			else if([key isEqualToString:@"font-size"])
			{
				font = [fontManager convertFont:font toSize:[value floatValue]];
			}
			else if([key isEqualToString:@"font-style"])
			{
				if([value isEqualToString:@"italic"] 
				   ||
				   [value isEqualToString:@"oblique"])
				{
					font = [fontManager convertFont:font toHaveTrait:NSItalicFontMask];
				}
				else if([value isEqualToString:@"normal"])
				{
					font = [fontManager convertFont:font toNotHaveTrait:NSItalicFontMask];
				}
			}
			else if([key isEqualToString:@"font-weight"])
			{
				//TODO: make this handle numeric weights
				if([value isEqualToString:@"bold"])
				{
					font = [fontManager convertFont:font toHaveTrait:NSBoldFontMask];
				}
				else if([value isEqualToString:@"normal"])
				{
					font = [fontManager convertFont:font toNotHaveTrait:NSBoldFontMask];
				}
			}
			else if([key isEqualToString:@"text-decoration"])
			{
				if([value isEqualToString:@"underline"])
				{
					[attributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle]
								   forKey:NSUnderlineStyleAttributeName];
				}
				else if([value isEqualToString:@"line-through"])
				{
					[attributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle]
								   forKey:NSStrikethroughStyleAttributeName];
				}
				else if([value isEqualToString:@"normal"])
				{
					[attributes setObject:nil
								   forKey:NSUnderlineStyleAttributeName];
					[attributes setObject:nil
								   forKey:NSStrikethroughStyleAttributeName];					
				}
			}
		}
	}
	return attributes;
}

NSMutableDictionary * stylesForTags;

@implementation TRXMLXHTML_IMParser
+ (void) loadStyles:(id)unused
{
	stylesForTags = [[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"XHTML-IM HTML Styles"]] retain];
	if(nil == stylesForTags)
	{
		stylesForTags = [[NSMutableDictionary alloc] init];
	}	
}

+ (void) initialize 
{
	//Load stored tag to style mappings
	[self loadStyles:nil];
	//Request notification if these change
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadStyles:)
												 name:NSUserDefaultsDidChangeNotification
											   object:nil];
}

- (void)characters:(NSString *)_chars
{
	NSAttributedString * newSection = [[NSAttributedString alloc] initWithString:_chars attributes:currentAttributes];
	[string appendAttributedString:newSection];
	[newSection release];
}

- (void)startElement:(NSString *)_Name
		  attributes:(NSDictionary*)_attributes;
{
	NSLog(@"Parsing HTML tag: %@", _Name);
	if(depth == 0)
	{
		//Ignore any elements that are not <body>
		if(![_Name isEqualToString:@"body"])
		{
			[[[TRXMLNullHandler alloc] initWithXMLParser:parser
												  parent:self
													 key:nil] startElement:_Name
																attributes:_attributes];
		}
	}
	else
	{
		//Push the current style onto the stack
		[attributeStack addObject:currentAttributes];
		//Get the new attributes
		NSDictionary * defaultStyle = [stylesForTags objectForKey:_Name];
		currentAttributes = [NSMutableDictionary dictionaryWithDictionary:currentAttributes];
		if(defaultStyle != nil)
		{
			[currentAttributes addEntriesFromDictionary:defaultStyle];
		}
		//Special case for hyperlinks
		if([_Name isEqualToString:@"a"])
		{
			//Set the link target
			[currentAttributes setObject:[_attributes objectForKey:@"href"]
								  forKey:NSLinkAttributeName];
		}
		//Display alt tags for images
		//TODO:  Make it optional to get the real image
		if([_Name isEqualToString:@"img"])
		{
			[self characters:[_attributes objectForKey:@"alt"]];
		}
		//Get an explicit style
		NSString * style = [_attributes objectForKey:@"style"];
		if(style != nil)
		{
			currentAttributes = attributesFromStyles(currentAttributes,style);
		}
		[currentAttributes retain];
		//And some line breaks...
		if([_Name isEqualToString:@"br"]
		   ||
		   [_Name isEqualToString:@"p"])
		{
			[self characters:@"\n"];
		}
		//Increment the depth counter.  This should always be equal to [attributeStack count] + 1, and it might be worth using this for validation
	}
	depth++;
}
- (void)endElement:(NSString *)_Name
{
	if(depth == 0)
	{
		[parser setContentHandler:parent];
		[self notifyParent];
		[self release];
	}
	else
	{
		depth--;
		[currentAttributes release];
		currentAttributes = [attributeStack lastObject];
		[attributeStack removeLastObject];
	}
}
- (void) notifyParent
{
	[(id)parent setValue:string forKey:key];
}
- (void) dealloc
{
	[currentAttributes release];
	[attributeStack release];
	[string release];
	[super dealloc];
}
@end