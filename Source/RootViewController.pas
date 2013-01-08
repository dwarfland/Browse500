namespace Browse500;

interface

uses
  PXAPI,
  UIKit;

type
  RootViewController = public class(UITableViewController)
  private
    fUsers: NSMutableDictionary;
    fUserAvatars: NSMutableDictionary;
    class var fInstance: RootViewController;

    method toggleNSFW(aSender: id);
    method changed(aNotification: NSNotification);
  protected

    {$REGION Table view data source}
    method numberOfSectionsInTableView(tableView: UITableView): Integer;
    method tableView(tableView: UITableView) numberOfRowsInSection(section: Integer): Integer;
    method tableView(tableView: UITableView) titleForHeaderInSection(section: Integer): NSString;
    method tableView(tableView: UITableView) cellForRowAtIndexPath(indexPath: NSIndexPath): UITableViewCell;
    {$ENDREGION}

    {$REGION Table view delegate}
    method tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
    {$ENDREGION}

  public
    method init: id; override;

    method viewDidLoad; override;
    method didReceiveMemoryWarning; override;

    method addUser(aUserInfo: NSDictionary);
    method addUserWithID(aUserID: Int32);

    class property instance: RootViewController read fInstance;
  end;

implementation

method RootViewController.init: id;
begin
  self := inherited initWithStyle(UITableViewStyle.UITableViewStylePlain);
  if assigned(self) then begin

    title := '500px';
    fUsers := new NSMutableDictionary;
    fUserAvatars := new NSMutableDictionary;
    fInstance := self;

  end;
  result := self;
end;

method RootViewController.changed(aNotification: NSNotification);
begin
  // for either change, all we need to to is reload the tabkle view
  tableView.reloadData();
end;

method RootViewController.viewDidLoad;
begin
  inherited viewDidLoad;

  NSNotificationCenter.defaultCenter.addObserver(self) 
                                     &selector(selector(changed:)) 
                                     name(Preferences.NOTIFICATION_FAVORITES_CHANGED)
                                     object(Preferences.sharedInstance);
  NSNotificationCenter.defaultCenter.addObserver(self) 
                                     &selector(selector(changed:)) 
                                     name(Preferences.NOTIFICATION_SHOW_NSFW_CHANGED)
                                     object(Preferences.sharedInstance);

  //tableView.separatorColor := UIColor.colorWithRed(0.1) green(0.2) blue(0.2) alpha(1.0);
  //tableView.backgroundColor := UIColor.colorWithRed(0.1) green(0.1) blue(0.1) alpha(1.0);
end;

method RootViewController.didReceiveMemoryWarning;
begin
  inherited didReceiveMemoryWarning;

  // Dispose of any resources that can be recreated.
end;

method RootViewController.addUser(aUserInfo: NSDictionary);
begin
  var lUsername := aUserInfo['username'];
  fUsers[lUsername] := aUserInfo;
  tableView.reloadData;
end;

method RootViewController.addUserWithID(aUserID: Int32);
begin
  PXRequest.requestForUserWithID(aUserID) 
            completion(method (aResult: NSDictionary; aError: NSError) 
                        begin
                          if assigned(aResult) then
                            addUser(aResult['user']);
                        end);
end;

method RootViewController.toggleNSFW(aSender: id);
begin
  Preferences.sharedInstance.ShowNSFW := (aSender as UISwitch).on;
end;

{$REGION Table view data source}

method RootViewController.numberOfSectionsInTableView(tableView: UITableView): Integer;
begin
  result := 5;
end;

method RootViewController.tableView(tableView: UITableView) numberOfRowsInSection(section: Integer): Integer;
begin
  case section of
    0: result := 0; // Coming post 1.0
    1: result := if Preferences.sharedInstance.hasFavorites then 1 else 0;
    2: result := 6;
    3: result := fUsers.count;
    4: result := 1;
  end;
end;

method RootViewController.tableView(tableView: UITableView) titleForHeaderInSection(section: Integer): NSString;
begin
  case section of
    1: result := if Preferences.sharedInstance.hasFavorites then 'Explore' else nil;
    2: result := if Preferences.sharedInstance.hasFavorites then nil else 'Explore';
    3: result := 'Users';
    4: result := 'Settings';
  end;
end;

method RootViewController.tableView(tableView: UITableView) cellForRowAtIndexPath(indexPath: NSIndexPath): UITableViewCell;
begin
  var CellIdentifier := "Cell";

  result := tableView.dequeueReusableCellWithIdentifier(CellIdentifier);
  if not assigned(result) then begin
    result := new UITableViewCell withStyle(UITableViewCellStyle.UITableViewCellStyleSubtitle) reuseIdentifier(CellIdentifier);

    result.textLabel.font := UIFont.systemFontOfSize(18);
    //result.textLabel.textColor := UIColor.whiteColor;
    result.textAlignment := NSTextAlignment.NSTextAlignmentLeft;
  end;

  result.accessoryView := nil;

  case indexPath.section of
    0:begin
        result.textAlignment := NSTextAlignment.NSTextAlignmentCenter;
        case indexPath.row of
          0:result.textLabel.text := 'Find user...';
        end;
        result.detailTextLabel.text := '';
        result.image := nil;
      end;
    1:begin
        result.textAlignment := NSTextAlignment.NSTextAlignmentCenter;
        result.textLabel.text := 'Favorites';
        result.detailTextLabel.text := '';
        result.image := nil;
      end;
    2:begin
        var lIndex := indexPath.row;
        result.textAlignment := NSTextAlignment.NSTextAlignmentCenter;
        result.textLabel.text := AlbumViewController.FEATURE_TITLES[lIndex];
        result.detailTextLabel.text := '';
        result.image := nil;
      end;
    3:begin

        var lUsername :=  fUsers.allKeys[indexPath.row];
        var lUser := fUsers[lUsername] as NSDictionary;
        var lUserID := lUser['id'];

        result.textAlignment := NSTextAlignment.NSTextAlignmentLeft;
        result.textLabel.text := lUsername;
        result.detailTextLabel.text := lUser['fullname'];

        var lImage := fUserAvatars[lUserID];
        if assigned(lImage) then begin
          result.image := lImage;
        end
        else begin
          //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin

              var lData := NSData.dataWithContentsOfURL(NSURL.URLWithString(lUser['userpic_url']));
              var lUIImage := UIImage.imageWithData(lData);
              fUserAvatars[lUserID] := lUIImage;

              //dispatch_async(dispatch_get_main_queue(), method begin

              //  photosChanged;
                result.image := lUIImage;

              //  end);

            // end);
        end;
       end;
    4:begin
        result.textAlignment := NSTextAlignment.NSTextAlignmentCenter;
        case indexPath.row of
          0:result.textLabel.text := 'Show NSFW Photos...';
        end;
        result.detailTextLabel.text := '';
        result.image := nil;
        var lSwitch := new UISwitch;
        lSwitch.on := Preferences.sharedInstance.ShowNSFW;
        lSwitch.addTarget(self) action(selector(toggleNSFW:)) forControlEvents(UIControlEvents.UIControlEventValueChanged);
        result.accessoryView := lSwitch;
      end;
  end;
  
end;

method RootViewController.tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
begin
  case indexPath.section of
    0:begin
        case indexPath.row of
          0:;
          else navigationController.pushViewController(new AlbumViewController withFeature(PXAPIHelperPhotoFeature(indexPath.row))) animated(true);
        end;
      end;
    1:begin
        navigationController.pushViewController(new FavoritesAlbumViewController) animated(true);
      end;
    2:begin
        navigationController.pushViewController(new AlbumViewController withFeature(PXAPIHelperPhotoFeature(indexPath.row))) animated(true);
      end;
    3:begin
        var lUsername :=  fUsers.allKeys[indexPath.row];
        var lUser := fUsers[lUsername] as NSDictionary;

        navigationController.pushViewController(new AlbumViewController withUserInfo(lUser)) animated(true);
      end;
  end;

  tableView.deselectRowAtIndexPath(indexPath) animated(true);
end;

{$ENDREGION}

end.
