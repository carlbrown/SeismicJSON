//
//  NotificationOrParentContext.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/22/12.
//  Copyright (c) 2012 PDAgent. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#ifndef SeismicJSON_NotificationOrParentContext_h
#define SeismicJSON_NotificationOrParentContext_h

//Make this a 1 to show notifications, and a 0 to show parent contexts
#define kUSE_NSNOTIFICATIONS_FOR_CONTEXT_MERGE 0
#define kUSE_PARENT_CONTEXTS_FOR_CONTEXT_MERGE !kUSE_NSNOTIFICATIONS_FOR_CONTEXT_MERGE

#endif
