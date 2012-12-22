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

method RootViewController.viewDidLoad;
begin
  inherited viewDidLoad;

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

{$REGION Table view data source}

method RootViewController.numberOfSectionsInTableView(tableView: UITableView): Integer;
begin
  result := 3;
end;

method RootViewController.tableView(tableView: UITableView) numberOfRowsInSection(section: Integer): Integer;
begin
  case section of
    0: result := 1;
    1: result := 6;
    2: result := fUsers.count;
  end;
end;

method RootViewController.tableView(tableView: UITableView) titleForHeaderInSection(section: Integer): NSString;
begin
  case section of
    1: result := 'Featured Photos';
    2: result := 'Users';
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
        result.textLabel.text := AlbumViewController.FEATURE_TITLES[indexPath.row];
        result.detailTextLabel.text := '';
        result.image := nil;
      end;
    2:begin

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
  end;
  
end;

{$ENDREGION}

{$REGION  Table view delegate}

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
        navigationController.pushViewController(new AlbumViewController withFeature(PXAPIHelperPhotoFeature(indexPath.row))) animated(true);
      end;
    2:begin
        var lUsername :=  fUsers.allKeys[indexPath.row];
        var lUser := fUsers[lUsername] as NSDictionary;

        navigationController.pushViewController(new AlbumViewController withUserInfo(lUser)) animated(true);
      end;
  end;

  tableView.deselectRowAtIndexPath(indexPath) animated(true);
end;

{$ENDREGION}

end.
