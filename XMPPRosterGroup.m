//
//  XMPPRosterGroup.m
//  Jabber
//
//  Created by David Chisnall on Sun Jul 25 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "XMPPRosterGroup.h"
#import "XMPPPresence.h"
#import "CompareHack.h"
#import <EtoileFoundation/EtoileFoundation.h>

@implementation XMPPRosterGroup
+ (id) groupWithRoster:(id)_roster
{
	return [[XMPPRosterGroup alloc] initWithRoster:_roster];
}

- (id) initWithRoster:(id)_roster
{
	if (!(self = [self init])) return nil;
	roster = _roster;
	return self;
}

- (id) init
{
	roster = nil;
	peopleByName = [[NSMutableDictionary alloc] init];
	people = [[NSMutableArray alloc] init];
	return [super init];
}

- (NSString*) groupName
{
	return name;
}

- (void) groupName:(NSString*)_name
{
	name = _name;
}

- (void) addIdentity:(XMPPIdentity*)_identity
{
	XMPPPerson * person = [peopleByName objectForKey:[_identity name]];
	if(person == nil)
	{
		person = [XMPPPerson personWithIdentity:_identity forRoster:roster];
		[peopleByName setObject:person forKey:[person name]];
#ifndef DNDEBUG
		ETLog(@"Adding new person %@", [person name]);
#endif
		[people addObject:person];
		[people sortUsingFunction:compareTest context:nil];
	}
	else
	{
		[person addIdentity:_identity];
	}
}

- (void) removeIdentity:(XMPPIdentity*)_identity
{
	XMPPPerson * person = [peopleByName objectForKey:[_identity name]];
	[person removeIdentity:_identity];
	if([person identities] == 0)
	{
#ifndef DNDEBUG
		ETLog(@"Removing person %@", [person name]);
#endif
		[people removeObject:person];
		[peopleByName removeObjectForKey:[person name]];
	}
}

- (XMPPPerson*) personNamed:(NSString*)_name
{
	return [peopleByName objectForKey:_name];
}

- (unsigned int) numberOfPeopleInGroupMoreOnlineThan:(unsigned int)hide
{
	//Sort every time a UI tries to inspect us to make sure we are in a consistent order.

	if ([people count] > 1)
	{
//		[people sortUsingSelector:@selector(compare:)];
		//Ugly hack.  No idea why this works and the other version doesn't...
		[people sortUsingFunction:compareTest context:nil];
	}
		
	/*	if(hide > PRESENCE_UNKNOWN)
	{
		return [people count];
	}*/
	int count = 0;
	for(unsigned int i=0 ; i<[people count] ; i++)
	{
		XMPPPerson* person = [people objectAtIndex:i];
		//ETLog(@"Person in group %@[%d]: %@ (%d)", name, i, [person name], (int)[[[person defaultIdentity] presence] show]); I tried to decomment putting it in a preprocessor statement, but it takes forever in the executon; FIXME
		if([[[person defaultIdentity] presence] show] < hide)
		{
			count++;
		}
	}

	
	return count;
}

- (NSComparisonResult) compare:(XMPPRosterGroup*)otherGroup
{
	return [name caseInsensitiveCompare:[otherGroup groupName]];
}

- (XMPPPerson*) personAtIndex:(unsigned int)_index
{
	if (_index < [people count])
		return [people objectAtIndex:_index];
	return nil;
}
@end
