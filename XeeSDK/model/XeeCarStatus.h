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

#import "XeeModel.h"

#import "XeeAccelerometer.h"
#import "XeeLocation.h"
#import "XeeSignal.h"

@interface XeeCarStatus : XeeModel

@property (nonatomic, strong) XeeAccelerometer *accelerometer;
@property (nonatomic, strong) XeeLocation *location;
@property (nonatomic, strong) NSArray<XeeSignal*> *signals;

@end