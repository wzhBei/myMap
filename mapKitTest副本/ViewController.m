//
//  ViewController.m
//  mapKitTest
//
//  Created by wangzh on 15/10/19.
//  Copyright © 2015年 wangzh. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coordinator;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic, strong) NSMutableArray *routes;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UIButton *drawBtn;
@property (nonatomic, strong) UIButton *startBtn;

@property (nonatomic, assign) NSInteger addValue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位不可用");
        
    }else {
        //设置代理
//        [self.locationManager setDelegate:self];
        //设置精准度，
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [self.locationManager requestAlwaysAuthorization];
        
        CLLocationDistance distance = 10.0f;
        [self.locationManager setDistanceFilter:distance];
        
        [self.locationManager startUpdatingLocation];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(a) userInfo:nil repeats:YES];
    [self.timer fire];
    
    self.stopBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    self.stopBtn.backgroundColor = [UIColor grayColor];
    [self.stopBtn setTitle:@"stopLocation" forState:UIControlStateNormal];
    [self.stopBtn addTarget:self action:@selector(b) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.stopBtn];
    
    
    self.drawBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.drawBtn.frame) + 30, 10, 100, 100)];
    self.drawBtn.backgroundColor = [UIColor grayColor];
    [self.drawBtn setTitle:@"beginDraw" forState:UIControlStateNormal];
    [self.drawBtn addTarget:self action:@selector(updateRouteView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.drawBtn];
    
    self.startBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.drawBtn.frame) + 30, 10, 100, 100)];
    self.startBtn.backgroundColor = [UIColor grayColor];
    [self.startBtn setTitle:@"startLocation" forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(startLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startBtn];
    
    [self.view addSubview:self.mapView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKMapView *)mapView
{
    if (_mapView == nil) {
        CGRect rect = CGRectMake(0, CGRectGetMaxY(self.stopBtn.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.stopBtn.frame));
        _mapView = [[MKMapView alloc] initWithFrame:rect];
        _mapView.delegate = self;
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = YES;
    }
    return _mapView;
}

- (CLLocationManager *)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
    return _locationManager;
}



- (void)a
{
    NSLog(@"is starting LocationManager");
    [self.locationManager startUpdatingLocation];
}


- (void)b
{
    NSLog(@"is closing LocationManager");
    [self.timer invalidate];
}

- (void)startLocation
{
    [self.routes removeAllObjects];
    [self.locationManager startUpdatingHeading];
}
#pragma mark - 
#pragma delegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
//    NSLog(@"%s",__func__);
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    NSLog(@"%s",__func__);
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
//    NSLog(@"%s",__func__);
}
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
//    NSLog(@"%s",__func__);
}
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
//    NSLog(@"%s",__func__);
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D center = userLocation.location.coordinate;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, 100.0, 100.0);
    
    [self.mapView setRegion:region animated:YES];
}
#pragma mark-
#pragma locationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
  
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"位置变化： %@", locations[0]);
    // 根据经纬度查找（去苹果后台查找准确的位置，必须联网才能用）
    [self.geoCoder reverseGeocodeLocation:locations[0] completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"%@", placemarks[0]);
    }];
    
    [self.routes addObject:locations[0]];
    
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    //定位失败
    
}

- (void)updateRouteView{
    [self.mapView removeOverlays:self.mapView.overlays];
    CLLocationCoordinate2D *pointsToUse = malloc(sizeof(CLLocationCoordinate2D) * self.routes.count);
    self.addValue = 0.01;
    for (int i = 0; i < [self.routes count]; i++) {
        self.addValue += 0.01;
        
        CLLocationCoordinate2D coords;
        CLLocation *loc = [self.routes objectAtIndex:i];
        coords.latitude = loc.coordinate.latitude + self.addValue;
        coords.longitude = loc.coordinate.longitude + self.addValue;
        pointsToUse[i] = coords;
    }
    MKPolyline *lineOne = [MKPolyline polylineWithCoordinates:pointsToUse count:[self.routes count]];
    
    [self.mapView addOverlay:lineOne];
}

//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
//{
//    return nil;
//}

//-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
//{
//    if ([overlay isKindOfClass:[MKPolyline class]])
//    {
//        MKOverlayRenderer *render = [[MKOverlayRenderer alloc] initWithOverlay:overlay];
//        return render;
//    }
//    return nil;
//}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    
    renderer.strokeColor = [UIColor redColor];
    renderer.fillColor = [UIColor redColor];
    renderer.lineWidth = 4.0;
    
    return  renderer;
}

- (NSMutableArray *)routes
{
    if (_routes == nil) {
        _routes = [NSMutableArray array];
    }
    
    return _routes;
}
@end
