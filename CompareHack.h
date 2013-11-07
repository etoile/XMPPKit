//
//  CompareHack.h
//  Jabber
//
//  Created by David Chisnall on 17/12/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.

/**
 * A hack required to avoid a bug in NSMutableArray's -sortUsingSelector: method
 * on OS X 10.4 on Intel.  This may be caused by an as-yet-undetermined bug in 
 * the XMPP code, and so the continued need for it should be tested 
 * periodically.
 */
NSComparisonResult compareTest(id a, id  b, void* none);
NSComparisonResult compareByPriority(id a, id  b, void* none);
