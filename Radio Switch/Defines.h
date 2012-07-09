//
//  Defines.h
//  Radio Switch
//
//  Created by Olga Dalton on 05/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#define DOCUMENTS_DIRECTORY [((AppDelegate *) [[UIApplication sharedApplication] delegate]) applicationDocumentsDirectory]

#define SHARED_DELEGATE ((AppDelegate *) [[UIApplication sharedApplication] delegate])

#define CACHE_PATH @"cache.dat"

// Data dictionary keys
#define LAST_MODIFIED @"last_modified"

#define EXPIRATION_TIME 60*60*24*10 // 10 days

#define RADIO_LIST_API_URL @"http://api.yes.com/1/stations?max=100000"
#define STATION_INFO @"http://api.yes.com/1/station?name=%@"

#define API_KEY @"220c973a3e9e2e7cce262afc1338eebb3b603d83"

#define CATEGORIES_LIST @"http://dirble.com/dirapi/categories/apikey/%@"
#define STATIONS_LIST @"http://dirble.com/dirapi/stations/apikey/%@/id/%@"