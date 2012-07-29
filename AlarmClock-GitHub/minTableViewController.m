//
//  minTableViewController.m
//  alarm1
//
//  Created by Philip Montalvo on 2012-02-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "AlarmCell.h"
#import "Alarm.h"
#import "minTableViewController.h"
#import "AddAlarmViewController.h"
#import "EditAlarmViewController.h"
#import "Singleton.h"




@implementation minTableViewController
@synthesize alarms;
@synthesize delegate;
@synthesize delegate2;


- (IBAction)done:(id)sender
{
    
    [[[Singleton sharedSingleton] sharedPrefs] synchronize];
	[self.delegate minTableViewControllerDidDone:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddAlarm"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		AddAlarmViewController *addAlarmViewController = [[navigationController viewControllers] objectAtIndex:0];
		addAlarmViewController.delegate = self;
        
	} else if ([segue.identifier isEqualToString:@"EditAlarm"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
		EditAlarmViewController *editAlarmViewController = [[navigationController viewControllers] objectAtIndex:0];
		editAlarmViewController.delegate2 = self;
        
    }
}


- (void)addAlarmViewControllerDidCancel:(AddAlarmViewController *)controller
{
    
	[self dismissViewControllerAnimated:YES completion:nil];

}



- (void)editAlarmViewControllerDidCancel:(EditAlarmViewController *)controller2
{
    //Canslar
	[self dismissViewControllerAnimated:YES completion:nil];
}





- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    //Antalet singletonvariabler
    counter = [[[Singleton sharedSingleton] sharedPrefs] integerForKey:@"Counter"];
    
    //Läser in alla sharedprefs i en sharedAlarmsArray
    if ([[[Singleton sharedSingleton] sharedAlarmsArray] count] < counter) {
    
        for (int i = 0; i < counter ; i++) {
        
            [self.tableView reloadData];
        
            Alarm *alarm = [[Alarm alloc] init];
            alarm.name = [[[Singleton sharedSingleton] sharedPrefs] valueForKey:[NSString stringWithFormat:@"name%i",i]];
            alarm.fireDate = [[[Singleton sharedSingleton] sharedPrefs] valueForKey:[NSString stringWithFormat:@"firedate%i",i]];
            alarm.alarmState = [[[Singleton sharedSingleton] sharedPrefs] integerForKey:[NSString stringWithFormat:@"CurrentSwitchState%i",i]];
            alarm.repeat = [[[Singleton sharedSingleton] sharedPrefs] objectForKey:[NSString stringWithFormat:@"repeat%i",i]];
        
            [[[Singleton sharedSingleton] sharedAlarmsArray] addObject:alarm];
            
            NSLog(@"%@", alarm.repeat);
            
        }
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    [self.tableView reloadData];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{   
    
    int y = [[Singleton sharedSingleton] sharedCounter];
    
    [[[Singleton sharedSingleton] sharedPrefs] setInteger:y forKey:@"Counter"];
    [[[Singleton sharedSingleton] sharedPrefs] setValue:[[Singleton sharedSingleton]sharedAlarmsArray] forKey:@"AlarmArraySave"];
    [[[Singleton sharedSingleton] sharedPrefs] synchronize];
    
    [super viewDidUnload];

}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self.tableView reloadData];
    
    if ([[[Singleton sharedSingleton] sharedAlarmsArray] count] < counter) {
        
        for (int i = 0; i < counter ; i++) {
            
            [self.tableView reloadData];
            
            Alarm *alarm = [[Alarm alloc] init];
            alarm.name = [[[Singleton sharedSingleton] sharedPrefs] valueForKey:[NSString stringWithFormat:@"name%i",i]];
            alarm.fireDate = [[[Singleton sharedSingleton] sharedPrefs] valueForKey:[NSString stringWithFormat:@"firedate%i",i]];
            alarm.alarmState = [[[Singleton sharedSingleton] sharedPrefs] integerForKey:[NSString stringWithFormat:@"CurrentSwitchState%i",i]];
            
            [[[Singleton sharedSingleton] sharedAlarmsArray] addObject:alarm];
            
        }
        
        [self.tableView reloadData];
        
    }

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{   

    [self.tableView reloadData];
    
        
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [[[Singleton sharedSingleton] sharedAlarmsArray]count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	cell = (AlarmCell *)[tableView dequeueReusableCellWithIdentifier:@"AlarmCell"];
    
	Alarm *alarm = [[[Singleton sharedSingleton] sharedAlarmsArray] objectAtIndex:indexPath.row];
	cell.nameLabel.text = alarm.name;
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    NSString *dateString = [outputFormatter stringFromDate:alarm.fireDate];
    
    cell.timeLabel.text = dateString;
	
    //kollar om staten är on eller off, och skriver ut det
    if ([[[[Singleton sharedSingleton] sharedAlarmsArray] objectAtIndex:indexPath.row] alarmState] == 1) {
        cell.onOffLabel.text = @"On";
    } else {
        cell.onOffLabel.text = @"Off";
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        int y = [[[Singleton sharedSingleton] sharedPrefs] integerForKey:@"Counter"];
        Alarm *oldAlarm = [[[Singleton sharedSingleton] sharedAlarmsArray] objectAtIndex:indexPath.row];
        
		        
        [[[Singleton sharedSingleton] sharedPrefs] setInteger:y forKey:@"Counter"];        
        [[[Singleton sharedSingleton] sharedPrefs] synchronize];
        
        if ([oldAlarm.fireDate timeIntervalSinceNow] > 0) {
            //Då borde det också finnas en notification
            
            [oldAlarm unRegisterAlarm];
            
            
        }
        
        [[[Singleton sharedSingleton] sharedAlarmsArray] removeObjectAtIndex:indexPath.row];
		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        y = y - 1;

	}   
}



- (void)addAlarmViewController:(AddAlarmViewController *)controller didAddAlarm:(Alarm *)alarm
{
	[[[Singleton sharedSingleton] sharedAlarmsArray]addObject:alarm];
    
    
    //int y = [[Singleton sharedSingleton] sharedPrefs];
    //y = y + 1;
    //[[[Singleton sharedSingleton] sharedPrefs] setInteger:y forKey:@"Counter"];
    //[[[Singleton sharedSingleton] sharedPrefs] synchronize];
    
    
    
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[[[Singleton sharedSingleton] sharedAlarmsArray] count] - 1 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editAlarmViewController:(EditAlarmViewController *)controller didEditAlarm:(Alarm *)alarm
{
   
    int q = [[[Singleton sharedSingleton] sharedPrefs] integerForKey:@"TheRowISelected"];
    
    if ([[[Singleton sharedSingleton] sharedPrefs] integerForKey:[NSString stringWithFormat:@"CurrentSwitchState%i",q]] == 1) {
        cell.onOffLabel.text = @"On";
    } else {
        
        cell.onOffLabel.text = @"Off";
        
    }
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshDisplay:(UITableView *)tableView {
    [tableView reloadData]; 
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int y = indexPath.row;
   [[[Singleton sharedSingleton] sharedPrefs] setInteger:y forKey:@"TheRowISelected"];
    NSLog(@"Rad: %i",y);
  
    
    
   
}

@end