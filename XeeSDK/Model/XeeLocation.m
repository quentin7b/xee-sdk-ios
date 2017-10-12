/*
 * Copyright 2016 Eliocity
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "XeeLocation.h"

@implementation XeeLocation

-(instancetype)initWithJSON:(NSDictionary *)JSON {
    self = [super initWithJSON:JSON];
    if(self) {
        if ([JSON isKindOfClass:[NSDictionary class]]) {
            _latitude = [JSON objectForKey:@"latitude"];
            _longitude = [JSON objectForKey:@"longitude"];
            
            _altitude = [JSON objectForKey:@"altitude"];
            _heading = [JSON objectForKey:@"heading"];
            
            _satellites = [JSON objectForKey:@"satellites"];
            
            _date = [NSDateFormatter xeeDateFromString:[JSON objectForKey:@"date"]];
        }
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"\
            latitude: %@\r\
            longitude: %@\r\
            altitude: %@\r\
            heading: %@\r\
            satellites: %@\r\
            date: %@",
            _latitude, _longitude, _altitude, _heading, _satellites, _date];
}

@end