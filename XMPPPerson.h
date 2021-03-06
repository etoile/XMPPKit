//
//  XMPPPerson.h
//  Jabber
//
//  Created by David Chisnall on Sun Apr 25 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <AddressBook/AddressBook.h>
#import "JID.h"
#import <EtoileXML/ETXMLNode.h>
#import "XMPPPresence.h"
#import "XMPPIdentity.h"

/**
 * A XMPPPerson is an abstract interface to a person on the Jabber network.
 * A Jabber person has at least one client (JID) associated with them, in the 
 * form of an identity.
 *
 * The concept of a person is fairly fuzzy, but should roughly correspond to 
 * real-world people.  Other unique actors in the Jabber network might also be
 * modeled as people, for example a groupchat room could be a person and all
 * members of it identities of that person.
 */
@interface XMPPPerson : NSObject <PresenceHandler, XMPPInfoQueryStanzaHandler> {
	NSMutableDictionary * identities;
	NSMutableArray * identityList;
	NSUInteger identityCount;
	NSString * name;
	NSString * group;
	id roster;
	NSUInteger hash;
	ABPerson * vCard;
	NSMutableDictionary * photoHashes;
	NSString * currentHash;
	NSImage * avatar;
}
/**
 * Instantiate a new person from an identity and associate them with a roster.
 * Note that the XMPPIdentity class is used to parse roster items, and so it
 * will duplicate the name and group for the person.  
 */
+ (id) personWithIdentity:(XMPPIdentity*)_identity forRoster:(id)_roster;
/**
 * Initialise a new person with a specified identity and roster.
 */
- (id) initWithIdentity:(XMPPIdentity*)_identity forRoster:(id)_roster;
/**
 * Add a new identity to an existing person.
 */
- (void) addIdentity:(XMPPIdentity*)anIdentity;
/**
 * Remove an identity from an existing person.
 */
- (void) removeIdentity:(XMPPIdentity*)_identity;
/**
 * Returns the name of the roster group containing the person.
 */
- (NSString*) group;
/**
 * Set the name of the roster group containing the person.
 */
- (void) group:(NSString*)_group;
/**
 * Returns the name of the person.
 */
- (NSString*) name;
/**
 * Returns the number of identities.  Deprecated (use the array directly).
 */
- (NSUInteger) identities;
/**
 * Returns the most identity that should be used to communicate with this person
 * when none is specified by the user.
 */
- (XMPPIdentity*) defaultIdentity;
/**
 * Returns all identities associated with this person.
 */
- (NSArray*) identityList;
/**
 * Returns the identity for a specified Jabber ID.
 */
- (XMPPIdentity*) identityForJID:(JID*)jid;
/**
 * Sets the name of the person.
 */
- (void) name:(NSString*)_name;
//- (ETXMLNode*) rosterNodeForJID:(JID*)_jid;
/**
 * Compares two people by their name.
 */
- (NSComparisonResult) compare:(XMPPPerson*)otherPerson;
/**
 * Returns the user's avatar.
 */
- (NSImage*) avatar;
@end

