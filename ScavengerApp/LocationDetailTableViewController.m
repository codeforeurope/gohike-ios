//
//  LocationDetailTableViewController.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 9/1/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "LocationDetailTableViewController.h"
#import "CompassViewController.h"
#import "QuartzCore/CALayer.h"
#import "CustomBarButtonViewLeft.h"
#import "CustomBarButtonViewRight.h"
#import "MapViewController.h"


#import "LocationDetailTitleCell.h"
#import "LocationDetailPictureCell.h"
#import "LocationDetailBodyCell.h"

static NSString *PictureCellIdentifier = @"PictureCell";
static NSString *TitleCellIdentifier = @"TitleCell";
static NSString *BodyCellIdentifier = @"BodyCell";

@interface LocationDetailTableViewController ()
{
    double TextViewHeight;
}

@end

@implementation LocationDetailTableViewController

static CGFloat WindowHeight = 200.0;
static CGFloat ImageHeight  = 300.0;

- (id)initWithImage:(UIImage *)image {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _imageScroller  = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _imageScroller.backgroundColor                  = [UIColor clearColor];
        _imageScroller.showsHorizontalScrollIndicator   = NO;
        _imageScroller.showsVerticalScrollIndicator     = NO;
        
        _imageView = [[UIImageView alloc] initWithImage:image];
        [_imageScroller addSubview:_imageView];
        
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor              = [UIColor clearColor];
        _tableView.dataSource                   = self;
        _tableView.delegate                     = self;
        _tableView.separatorStyle               = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        
        [self.view addSubview:_imageScroller];
        [self.view addSubview:_tableView];
    }
    return self;
}

#pragma mark - Parallax effect

- (void)updateOffsets {
    CGFloat yOffset   = _tableView.contentOffset.y;
    CGFloat threshold = ImageHeight - WindowHeight;
    
    if (yOffset > -threshold && yOffset < 0) {
        _imageScroller.contentOffset = CGPointMake(0.0, floorf(yOffset / 2.0));
    } else if (yOffset < 0) {
        _imageScroller.contentOffset = CGPointMake(0.0, yOffset + floorf(threshold / 2.0));
    } else {
        _imageScroller.contentOffset = CGPointMake(0.0, yOffset);
    }
}

#pragma mark - View Layout
- (void)layoutImage {
    CGFloat imageWidth   = _imageScroller.frame.size.width;
    CGFloat imageYOffset = floorf((WindowHeight  - ImageHeight) / 2.0);
    CGFloat imageXOffset = 0.0;
    
    _imageView.frame             = CGRectMake(imageXOffset, imageYOffset, imageWidth, ImageHeight);
    _imageScroller.contentSize   = CGSizeMake(imageWidth, self.view.bounds.size.height);
    _imageScroller.contentOffset = CGPointMake(0.0, 0.0);
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect bounds = self.view.bounds;
    
    _imageScroller.frame        = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    _tableView.backgroundView   = nil;
    _tableView.frame            = bounds;
    
    [self layoutImage];
    [self updateOffsets];
}


#pragma mark - original 



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customizeButtons];
    
    //set the background
    UIView *tablebgView = [[[NSBundle mainBundle] loadNibNamed:@"TableBackground" owner:self options:nil] objectAtIndex:0];
    [self.view addSubview:tablebgView];
    [self.view sendSubviewToBack:tablebgView];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    //TextView Height
    TextViewHeight = 200.0;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    [self.tableView registerClass:[LocationDetailPictureCell class] forCellReuseIdentifier:PictureCellIdentifier];
//    [self.tableView registerClass:[LocationDetailTitleCell class] forCellReuseIdentifier:TitleCellIdentifier];
//    [self.tableView registerClass:[LocationDetailBodyCell class] forCellReuseIdentifier:BodyCellIdentifier];
    
    [_tableView registerNib:[UINib nibWithNibName:@"LocationDetailPictureCell" bundle:nil] forCellReuseIdentifier:PictureCellIdentifier];
    [_tableView registerNib:[UINib nibWithNibName:@"LocationDetailTitleCell" bundle:nil] forCellReuseIdentifier:TitleCellIdentifier];
    [_tableView registerNib:[UINib nibWithNibName:@"LocationDetailBodyCell" bundle:nil] forCellReuseIdentifier:BodyCellIdentifier];
    
}

- (void)customizeButtons
{
    //custom back button
    CustomBarButtonViewLeft *backButton = [[CustomBarButtonViewLeft alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                               imageName:@"icon-back"
                                                                                    text:NSLocalizedString(@"Back", nil)
                                                                                  target:self
                                                                                  action:@selector(onBackButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    //custom map button
    CustomBarButtonViewRight *mapButton = [[CustomBarButtonViewRight alloc] initWithFrame:CGRectMake(0, 0, 120, 32)
                                                                                imageName:@"icon-map"
                                                                                     text:NSLocalizedString(@"View Map", nil)
                                                                                   target:self
                                                                                   action:@selector(onMapButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mapButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)replayLocation
{
    NSArray *waypoints = [[[AppState sharedInstance] currentRoute] GHwaypoints];
    GHWaypoint *thisWayPoint;
    
    NSUInteger index = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj GHlocation_id] == [_location GHlocation_id];
    }];
    if (index == NSNotFound) {
        
    }
    else {
        thisWayPoint = [waypoints objectAtIndex:index];
    }
    
    if([waypoints count] > 0)
    {
        [[AppState sharedInstance] setActiveRouteId: [_location GHroute_id]];
        [[AppState sharedInstance] setActiveTargetId: [_location GHlocation_id]];
        [[AppState sharedInstance] save];
        
        CompassViewController *compass = [[CompassViewController alloc] init];
        [self.navigationController pushViewController:compass animated:YES];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { return 1;  }
    else              { return 2; }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *windowReuseIdentifier = @"RBParallaxTableViewWindow";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:windowReuseIdentifier];
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:windowReuseIdentifier];
            cell.backgroundColor             = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle              = UITableViewCellSelectionStyleNone;
        }
    } else {
        switch (indexPath.row) {
//            case 0:
//            {
//                LocationDetailPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:PictureCellIdentifier forIndexPath:indexPath];
////                cell.imageView.image = [UIImage imageWithData:[FileUtilities imageDataForWaypoint:_location]];
////                cell.backgroundColor = [UIColor clearColor];
//                return cell;
//                
//            }
//                break;
            case 0:
            {
                LocationDetailTitleCell *cell = (LocationDetailTitleCell*)[tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier forIndexPath:indexPath];
                cell.contentView.backgroundColor = [UIColor whiteColor];
                cell.titleLabel.text = [_location GHname];
                cell.selectionStyle              = UITableViewCellSelectionStyleNone;

                return cell;
            }
                break;
            case 1:
            {
                LocationDetailBodyCell *cell = [tableView dequeueReusableCellWithIdentifier:BodyCellIdentifier forIndexPath:indexPath];
                if(cell==nil)
                {
                    cell =[[LocationDetailBodyCell alloc] init];
                }
                
                cell.textView.text = [_location GHdescription];
                [cell.textView sizeToFit];
                //set frame height
                CGRect frame = cell.textView.frame;
                TextViewHeight = cell.textView.contentSize.height;
                frame.size.height = TextViewHeight;
                
                cell.textView.frame = frame;
                cell.selectionStyle              = UITableViewCellSelectionStyleNone;

                
                return cell;
            }
                break;
                
                
            default:
                break;
        }
        

    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { return WindowHeight; }
    else                        { switch (indexPath.row) {
//        case 0:
//        {
//            return 0;
//        }
//            break;
        case 0:
        {
            return 60;
        }
            break;
        case 1:
        {
            NSString *label =  [_location GHdescription];
            CGSize stringSize = [label sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0]
                                  constrainedToSize:CGSizeMake(280, 9999) lineBreakMode:NSLineBreakByWordWrapping];
            return stringSize.height; 
        }
            break;
        default:
            break;
    }
        return 0;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Table View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateOffsets];
}

#pragma mark - Actions

- (void)onMapButton
{
    MapViewController *mvc = [[MapViewController alloc] init];
    mvc.waypoints = [NSArray arrayWithObject:self.location];
    mvc.singleLocation = YES;
    mvc.title = [_location GHname];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:TRUE];
}




@end
