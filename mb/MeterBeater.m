//
//  MeterBeater.m
//  meterbeater
//
//  Created by Kevin Branigan on 12-05-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MeterBeater.h"
#import "ViewController.h"
@implementation MeterBeater

@synthesize connection;
@synthesize receivedData;
@synthesize viewController;
@synthesize data;
@synthesize infractions;

- (id)initWithDelegate:(ViewController*)vc
{
  infractions = [[NSMutableDictionary alloc] init];
  [infractions setObject:@"PARK-HWY PROHIB TIMES/DAYS" forKey:@"5"];
  [infractions setObject:@"PARK PROHIBITED TIME NO PERMIT" forKey:@"29"];
  [infractions setObject:@"PARK/LEAVE ON PRIVATE PROPERTY" forKey:@"3"];
  [infractions setObject:@"PARK FAIL TO DISPLAY RECEIPT" forKey:@"210"];
  [infractions setObject:@"PARK FAIL TO DEP. FEE MACHINE" forKey:@"207"];
  [infractions setObject:@"STOP HWY PROHIBITED TIME/DAY" forKey:@"9"];
  [infractions setObject:@"PARK LONGER THAN 3 HOURS" forKey:@"2"];
  [infractions setObject:@"STAND VEH-HWY-PROH TIME/DAYS" forKey:@"8"];
  [infractions setObject:@"PARK HWY IN EXCESS PRMTD TIME" forKey:@"6"];
  [infractions setObject:@"PARK-3M OF FIRE HYDRANT" forKey:@"15"];
  [infractions setObject:@"PARK ON   2AM-6AM DEC 1-MAR 31" forKey:@"28"];
  [infractions setObject:@"PARK IN A FIRE ROUTE" forKey:@"347"];
  [infractions setObject:@"STOP ON/OVER SIDEWALK/FOOTPATH" forKey:@"30"];
  [infractions setObject:@"PARKING MACH-NOT USED/NO FEE" forKey:@"312"];
  [infractions setObject:@"PARK IN PUBLIC LANE" forKey:@"134"];
  [infractions setObject:@"STAND SIGNED TRANSIT STOP" forKey:@"192"];
  [infractions setObject:@"PARK 9M OF INTERSCTING HIGHWAY" forKey:@"16"];
  [infractions setObject:@"PARK-PASSENGER/FREIGHT LOADING" forKey:@"82"];
  [infractions setObject:@"PARK - ON BOULEVARD" forKey:@"337"];
  [infractions setObject:@"PARK-FAIL TO DEPOSIT FEE METER" forKey:@"1"];
  [infractions setObject:@"PARK/LEAVE ON MUNICIPAL PRPTY" forKey:@"4"];
  [infractions setObject:@"PARK-FAIL TO DISPLAY PERMIT" forKey:@"336"];
  [infractions setObject:@"PARK - NOT WITHIN PERIOD" forKey:@"314"];
  [infractions setObject:@"FAIL TO PARK/STOP PAR TO CURB" forKey:@"48"];
  [infractions setObject:@"PARK IN PARK NOT IN DESIG AREA" forKey:@"250"];
  [infractions setObject:@"STAND SIGNED TAXICAB STAND" forKey:@"25"];
  [infractions setObject:@"PARK OBSTRUCT DRIVEWAY/LANEWAY" forKey:@"14"];
  [infractions setObject:@"FAIL PARK/STOP PAR RT HAND LTD" forKey:@"49"];
  [infractions setObject:@"PARK IN DISABLED NO PERMIT" forKey:@"355"];
  [infractions setObject:@"STOP RDSDE STOPPED/PARKED VEH" forKey:@"31"];
  [infractions setObject:@"PARK ON-STRT DISABLD NO PERMIT" forKey:@"363"];
  [infractions setObject:@"PARK CONTRARY POSTED CONDITION" forKey:@"257"];
  [infractions setObject:@"STOP - WITHIN 9.0M OF XWALK" forKey:@"58"];
  [infractions setObject:@"STAND ON-ST DISABL LDG NO PRMT" forKey:@"367"];
  [infractions setObject:@"PARK - BETWEEN ROAD & SIDEWALK" forKey:@"338"];
  [infractions setObject:@"PARK HEAVY TRUCK-SIGNED HIGHWA" forKey:@"37"];
  [infractions setObject:@"PARK VEHICLE OUTSIDE OF SPACE" forKey:@"307"];
  [infractions setObject:@"PARK ON HWY UNDER 6M WIDE" forKey:@"79"];
  [infractions setObject:@"PARK NOT WITHIN PERMITTED TIME" forKey:@"209"];
  [infractions setObject:@"STAND STR DISABL LDG NO DROPOF" forKey:@"369"];
  [infractions setObject:@"PARK 60CM OF DRIVEWAY/LANEWAY" forKey:@"77"];
  [infractions setObject:@"STAND IN DISABLED NOT DROP OFF" forKey:@"358"];
  [infractions setObject:@"PARK/STOP MORE THAN 30 CM CURB" forKey:@"11"];
  [infractions setObject:@"PARK/LEAVE CONTRARY TO SIGN" forKey:@"317"];
  [infractions setObject:@"STAND ON-STRT DISABL NO PERMIT" forKey:@"364"];
  [infractions setObject:@"PARK VEHICLE-FOR SALE" forKey:@"12"];
  [infractions setObject:@"PARK VEHICLE IN CAR-SHARE AREA" forKey:@"370"];
  [infractions setObject:@"PARK IN DESIGNATED FIRE ROUTE" forKey:@"7"];
  [infractions setObject:@"PARK IN DISABLED NOT DROP OFF" forKey:@"357"];
  [infractions setObject:@"STAND IN DISABLED NO PERMIT" forKey:@"356"];
  [infractions setObject:@"PARK HWY 15M OF INTERSECTION" forKey:@"17"];
  [infractions setObject:@"STOP ADJ TO CENTRE BOULEVARD" forKey:@"71"];
  [infractions setObject:@"PARK - ON BOULEVARD" forKey:@"26"];
  [infractions setObject:@"PARK VEHICLE ON ROADWAY" forKey:@"265"];
  [infractions setObject:@"PARK - ON FRONT YARD" forKey:@"340"];
  [infractions setObject:@"PARK MORE THAN 7DAYS NO PERMIT" forKey:@"335"];
  [infractions setObject:@"PARK VEH TO WASH GREASE REPAIR" forKey:@"13"];
  [infractions setObject:@"STAND VEHICLE WHERE PROHIBITED" forKey:@"262"];
  [infractions setObject:@"STOP WITHIN INTERSECTION/XWALK" forKey:@"57"];
  [infractions setObject:@"PARK-HWY-WITHIN T-TYPE INTERSC" forKey:@"86"];
  [infractions setObject:@"STAND DISABL LOADING NO PERMIT" forKey:@"360"];
  [infractions setObject:@"PARK-ISSUED CARD NOT DISPLAYED" forKey:@"315"];
  [infractions setObject:@"STOP IN UNDERPASS" forKey:@"68"];
  [infractions setObject:@"PARK OTHER THAN METERED SPACE" forKey:@"38"];
  [infractions setObject:@"PARK UNAUTH VEH IN HDCPD SPACE" forKey:@"10"];
  [infractions setObject:@"STOP/STAND/PARK VEND CONT ZONE" forKey:@"148"];
  [infractions setObject:@"PARK OVERNIGHT NO PERMIT" forKey:@"255"];
  [infractions setObject:@"PARK ON-ST DISABLD LDG NO PRMT" forKey:@"366"];
  [infractions setObject:@"STAND DISABLD LDG NOT DROP OFF" forKey:@"362"];
  [infractions setObject:@"PARK-SIGNED HWY WITHN TURN BAS" forKey:@"83"];
  [infractions setObject:@"STOP ON CENTRE BOULEVARD" forKey:@"69"];
  [infractions setObject:@"STOP - ON CENTRE STRIP" forKey:@"70"];
  [infractions setObject:@"PARK HWY 15M END OF D-END ST" forKey:@"85"];
  [infractions setObject:@"STOP IN SCHOOL LOADING ZONE" forKey:@"99"];
  [infractions setObject:@"PARK-HWY-30.5M SGNLZD INTRSCTN" forKey:@"18"];
  [infractions setObject:@"PARK VEHICLE WHILE NOT IN PARK" forKey:@"248"];
  [infractions setObject:@"STOP/PARK/LEAVE/STAND CLSD ST" forKey:@"140"];
  [infractions setObject:@"PARK DISABLD LOADING NO PERMIT" forKey:@"359"];
  [infractions setObject:@"STOP ON-STRT DISABLD NO PERMIT" forKey:@"365"];
  [infractions setObject:@"PARK IN DISABLED NO PERMIT" forKey:@"348"];
  [infractions setObject:@"STOP BSD OBSTR RDWY-IMPEDE TRF" forKey:@"63"];
  [infractions setObject:@"STOP - ON BRIDGE" forKey:@"65"];
  [infractions setObject:@"PARK STR DISABLD LDG NO DROPOF" forKey:@"368"];
  [infractions setObject:@"FAIL TO PARK/STOP PARALLEL TO" forKey:@"53"];
  [infractions setObject:@"ANGLE PARK-METERED SPACE-FRONT" forKey:@"45"];
  [infractions setObject:@"PARK HWY 30.5 FIREHALL OPP SDE" forKey:@"21"];
  [infractions setObject:@"PARK TAXI FOR HIRE UNATH LOCAT" forKey:@"24"];
  [infractions setObject:@"STOP/PARK DIS SPACE NO PERMIT" forKey:@"259"];
  [infractions setObject:@"STOP BY EXCAV IN RD IMPEDE TRA" forKey:@"61"];
  [infractions setObject:@"PARALLEL PARK-METERED SPACE-FR" forKey:@"44"];
  [infractions setObject:@"STOP-ACROS EXCAV RDWY-IMPEDE T" forKey:@"62"];
  [infractions setObject:@"PARK VEHICLE PROHIBITED TIME" forKey:@"266"];
  [infractions setObject:@"PARK OTHER THAN METERED SPACE" forKey:@"211"];
  [infractions setObject:@"PARK 30.5M XWALK OPPOSITE SIDE" forKey:@"23"];
  [infractions setObject:@"FAIL PARK/STOP RH LIMIT OF HWY" forKey:@"50"];
  [infractions setObject:@"PARK - 2 SPACES - NO FEE" forKey:@"308"];
  [infractions setObject:@"PARK HWY 7.5M FIREHALL SIDE" forKey:@"20"];
  [infractions setObject:@"PARK-MTRD SPC BYD MAX PARK PER" forKey:@"39"];
  [infractions setObject:@"PARK DISABLD LDG NOT DROP OFF" forKey:@"361"];
  [infractions setObject:@"STAND VEH - PROHIBITED TIME" forKey:@"264"];
  
  self.viewController = vc;
  
  connection = nil;
  
  return self;
}

- (void)requestUpdateAtLat:(float)lat andLng:(float)lng
{
  if (connection)
  {
    [connection cancel];
    connection = nil;
  }
  
  float range = 8;
  
  //NSString * ip = [NSString stringWithString:@"184.175.22.221"];
  NSString * ip = [NSString stringWithString:@"localhost"];
  
  //lat = 43.64692;  lng = -79.39717;
  //lat = 43.663746; lng = -79.389122;
  //lat = 43.665073;   lng = -79.380997;
  
  //lat = 43.651116673020375; lng = -79.39706767215192;
  //NSLog(@"%f %f\n", lat, lng);
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:3333/search?range=%f&lat=%f&lng=%f", ip, range, lat, lng]];
  NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data
{
	[receivedData appendData:_data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (receivedData)
	{
    NSError * error;
    data = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:&error];
    if (error)
    {
      NSLog(@"json is bad: %@", error.localizedDescription);
      [viewController setNavigationText:error.localizedDescription];
    }
    else
      [viewController meterBeaterDidUpdate];
    
    //_data = [json objectForKey:@"streets"];
    
    //[_masterView clearStreets];
    //for (NSString * street in [[data objectForKey:@"streets"] allKeys])
    //{
    //  NSDictionary * street_data = [[data objectForKey:@"streets"] objectForKey:street];
    //  for (NSString * numeric_side in [street_data allKeys])
    //  {
    //    if ([numeric_side compare:@"odd"]==0 || [numeric_side compare:@"even"]==0)
    //      [_masterView addStreet:street withSide:numeric_side];
    //    
    //    {
    //      NSString * side = [[street_data objectForKey:numeric_side] objectForKey:@"side"];
    //      [_masterView addStreet:street withSide:side];
    //    }
    //  }
    //}
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  NSLog(@"connection failed: %@", error.localizedDescription);
  [viewController setNavigationText:error.localizedDescription];
}

//- (NSDictionary*)getStreet:(NSString*)street withSide:(NSString*)side
//{
//  return [[[_data objectForKey:@"streets"] objectForKey:street] objectForKey:side];
//}



@end
