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

#import "XeeRoute.h"

@interface XeeUserRoute : XeeRoute

-(void)me:(void (^)(XeeUser *user, NSArray<XeeError*> *errors))completionHandler;
-(void)meCars:(void (^)(NSArray<XeeCar*> *cars, NSArray<XeeError*> *errors))completionHandler;
-(void)meDevices:(void (^)(NSArray<XeeDevice*> *devices, NSArray<XeeError*> *errors))completionHandler;

@end
