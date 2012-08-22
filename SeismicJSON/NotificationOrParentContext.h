//
//  NotificationOrParentContext.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/22/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#ifndef SeismicJSON_NotificationOrParentContext_h
#define SeismicJSON_NotificationOrParentContext_h

//Make this a 1 to show notifications, and a 0 to show parent contexts
#define kUSE_NSNOTIFICATIONS_FOR_CONTEXT_MERGE 0
//if using notifications, set this to 1 to have them in the App Delegate
#define kNSNOTIFICATIONS_HANDLED_IN_APPDELEGATE 0

//Don't mess with these
#define kUSE_PARENT_CONTEXTS_FOR_CONTEXT_MERGE !kUSE_NSNOTIFICATIONS_FOR_CONTEXT_MERGE
#define kNSNOTIFICATIONS_HANDLED_IN_VIEWCONTROLLER !kNSNOTIFICATIONS_HANDLED_IN_APPDELEGATE

#endif
