//
//  Polyline.m
//  SimpleMap
//
//  Created by masashi on 11/14/13.
//
//

#import "PluginPolyline.h"

@implementation PluginPolyline

-(void)setGoogleMapsViewController:(GoogleMapsViewController *)viewCtrl
{
  self.mapCtrl = viewCtrl;
}
- (void)pluginUnload
{
}

-(void)create:(CDVInvokedUrlCommand *)command
{
  // Initialize this plugin
  if (self.mapCtrl == nil) {
    CDVViewController *cdvViewController = (CDVViewController*)self.viewController;
    CordovaGoogleMaps *googlemaps = [cdvViewController getCommandInstance:@"CordovaGoogleMaps"];
    //self.mapCtrl = googlemaps.mapCtrl;
    [self.mapCtrl.plugins setObject:self forKey:@"Polyline"];
  }

  NSDictionary *json = [command.arguments objectAtIndex:0];
  GMSMutablePath *path = [GMSMutablePath path];

  NSArray *points = [json objectForKey:@"points"];
  int i = 0;
  NSDictionary *latLng;
  for (i = 0; i < points.count; i++) {
    latLng = [points objectAtIndex:i];
    [path addCoordinate:CLLocationCoordinate2DMake([[latLng objectForKey:@"lat"] floatValue], [[latLng objectForKey:@"lng"] floatValue])];
  }


  dispatch_queue_t gueue = dispatch_queue_create("createPolyline", NULL);
  dispatch_async(gueue, ^{

      dispatch_sync(dispatch_get_main_queue(), ^{

          // Create the Polyline, and assign it to the map.
          GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];

          if ([[json valueForKey:@"visible"] boolValue]) {
            //polyline.map = self.mapCtrl.map;
          }
          if ([[json valueForKey:@"geodesic"] boolValue]) {
            polyline.geodesic = YES;
          }
          NSArray *rgbColor = [json valueForKey:@"color"];
          polyline.strokeColor = [rgbColor parsePluginColor];

          polyline.strokeWidth = [[json valueForKey:@"width"] floatValue];
          polyline.zIndex = [[json valueForKey:@"zIndex"] floatValue];

          polyline.tappable = YES;

          NSString *id = [NSString stringWithFormat:@"polyline_%lu", (unsigned long)polyline.hash];
          [self.mapCtrl.overlayManager setObject:polyline forKey: id];
          polyline.title = id;


          dispatch_async(gueue, ^{

              NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
              [result setObject:id forKey:@"id"];
              [result setObject:[NSString stringWithFormat:@"%lu", (unsigned long)polyline.hash] forKey:@"hashCode"];

              CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
              [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
          });
      });
  });
}



/**
 * Set points
 * @params key
 */
-(void)setPoints:(CDVInvokedUrlCommand *)command
{
  NSString *polylineKey = [command.arguments objectAtIndex:0];
  GMSPolyline *polyline = [self.mapCtrl getPolylineByKey: polylineKey];
  GMSMutablePath *path = [GMSMutablePath path];

  NSArray *points = [command.arguments objectAtIndex:1];
  int i = 0;
  NSDictionary *latLng;
  for (i = 0; i < points.count; i++) {
    latLng = [points objectAtIndex:i];
    [path addCoordinate:CLLocationCoordinate2DMake([[latLng objectForKey:@"lat"] floatValue], [[latLng objectForKey:@"lng"] floatValue])];
  }
  [polyline setPath:path];


  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Set color
 * @params key
 */
-(void)setColor:(CDVInvokedUrlCommand *)command
{
  NSString *polylineKey = [command.arguments objectAtIndex:0];
  GMSPolyline *polyline = [self.mapCtrl getPolylineByKey: polylineKey];

  NSArray *rgbColor = [command.arguments objectAtIndex:1];
  [polyline setStrokeColor:[rgbColor parsePluginColor]];

  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Set width
 * @params key
 */
-(void)setWidth:(CDVInvokedUrlCommand *)command
{
  NSString *polylineKey = [command.arguments objectAtIndex:0];
  GMSPolyline *polyline = [self.mapCtrl getPolylineByKey: polylineKey];
  float width = [[command.arguments objectAtIndex:1] floatValue];
  [polyline setStrokeWidth:width];

  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Set z-index
 * @params key
 */
-(void)setZIndex:(CDVInvokedUrlCommand *)command
{
  NSString *polylineKey = [command.arguments objectAtIndex:0];
  GMSPolyline *polyline = [self.mapCtrl getPolylineByKey: polylineKey];
  NSInteger zIndex = [[command.arguments objectAtIndex:1] integerValue];
  [polyline setZIndex:(int)zIndex];

  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Set visibility
 * @params key
 */
-(void)setVisible:(CDVInvokedUrlCommand *)command
{
  NSString *polylineKey = [command.arguments objectAtIndex:0];
  GMSPolyline *polyline = [self.mapCtrl getPolylineByKey: polylineKey];
  Boolean isVisible = [[command.arguments objectAtIndex:1] boolValue];
  if (isVisible) {
    //polyline.map = self.mapCtrl.map;
  } else {
    polyline.map = nil;
  }

  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
/**
 * Set geodesic
 * @params key
 */
-(void)setGeodesic:(CDVInvokedUrlCommand *)command
{
  NSString *polylineKey = [command.arguments objectAtIndex:0];
  GMSPolyline *polyline = [self.mapCtrl getPolylineByKey: polylineKey];
  Boolean isGeodisic = [[command.arguments objectAtIndex:1] boolValue];
  [polyline setGeodesic:isGeodisic];

  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Remove the polyline
 * @params key
 */
-(void)remove:(CDVInvokedUrlCommand *)command
{
  NSString *polylineKey = [command.arguments objectAtIndex:0];
  GMSPolyline *polyline = [self.mapCtrl getPolylineByKey: polylineKey];
  polyline.map = nil;
  [self.mapCtrl removeObjectForKey:polylineKey];
  polyline = nil;

  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
