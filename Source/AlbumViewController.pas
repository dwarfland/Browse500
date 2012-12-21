namespace Browse500;

interface

uses
  PXAPI,
  UIKit;

type
  AlbumViewController = public class(UITableViewController)
  private
    fUserID: Int32;
    fFeature: PXAPIHelperPhotoFeature;
    fCurrentPage: Int32;
    fPhotoInfo: NSArray;
    fPhotosSmall: NSMutableDictionary;// := new NSMutableDictionary;  << THIS throws an exception
    fCategories: NSDictionary;
    fUserInfo: NSDictionary;
    
    fReloading: Boolean;
    fDone: Boolean;
    method photosChanged;

    method showUserInfo(aSender: id);

    method loadNextPage();
  protected

    {$REGION Table view data source & delegate}
    method tableView(tableView: UITableView) numberOfRowsInSection(section: Integer): Integer;
    method tableView(tableView: UITableView) cellForRowAtIndexPath(indexPath: NSIndexPath): UITableViewCell;
    method tableView(tableView: UITableView) willDisplayCell(cell: UITableViewCell) forRowAtIndexPath(indexPath: NSIndexPath);
    method tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
    {$ENDREGION}

  public
    method init: id; override;
    method initWithUserID(aUserID: Int32): id;
    method initWithUserInfo(aUserInfo: NSDictionary): id;
    method initWithFeature(aFeature: PXAPIHelperPhotoFeature): id;

    method viewDidLoad; override;
    method didReceiveMemoryWarning; override;

    const PHOTOS_PER_PAGE = 20;
    const FEATURE_TITLES: array of String = ['Popular', 'Upcoming', 'Editors', 'Fresh Today', 'Fresh Yesterday', 'Fresh This Week'];
  end;

implementation

method AlbumViewController.init: id;
begin
  self := inherited initWithStyle(UITableViewStyle.UITableViewStylePlain);
  if assigned(self) then begin

    // Custom initialization

  end;
  result := self;

end;

method AlbumViewController.initWithUserID(aUserID: Int32): id;
begin
  self := init;
  if assigned(self) then begin

    fFeature := PXAPIHelperPhotoFeature(-1);
    fUserID := aUserID;

  end;
  result := self;
end;

method AlbumViewController.initWithUserInfo(aUserInfo: NSDictionary): id;
begin
  self := init;
  if assigned(self) then begin

    fFeature := PXAPIHelperPhotoFeature(-1);
    fUserID := aUserInfo['id'].integerValue;
    fUserInfo := aUserInfo;

  end;
  result := self;
end;

method AlbumViewController.initWithFeature(aFeature: PXAPIHelperPhotoFeature): id;
begin
  self := init;
  if assigned(self) then begin

    fFeature := aFeature;
    fUserID := -1;

  end;
  result := self;
end;

method AlbumViewController.viewDidLoad;
begin
  inherited viewDidLoad;

  {PXRequest.requestForUserWithUserName('dwarfland') completion(method (aResult: NSDictionary; aError: NSError) 
                                                               begin
                                                                 NSLog('done! %@', aResult);
                                                               end);}
  
  tableView.separatorColor := UIColor.colorWithRed(0.1) green(0.2) blue(0.2) alpha(1.0);
  tableView.backgroundColor := UIColor.colorWithRed(0.1) green(0.1) blue(0.1) alpha(1.0);

  if fFeature <> -1 then begin
    title := FEATURE_TITLES[fFeature];
  end
  else if not assigned(fUserInfo) then begin
    title := '∞';
    PXRequest.requestForUserWithID(fUserID) 
              completion(method (aResult: NSDictionary; aError: NSError) 
                         begin
                           NSLog('user info %@', aResult);
                           if assigned(aResult) then begin
                             fUserInfo := aResult['user'];
                             title := fUserInfo['username'];
                                                         
                             RootViewController.instance.addUser(fUserInfo);
                             navigationController.navigationBar.topItem.rightBarButtonItem := new UIBarButtonItem withBarButtonSystemItem(UIBarButtonSystemItem.UIBarButtonSystemItemCamera) target(self) action(selector(showUserInfo:));
                           end;
                         end);
  end
  else begin
    title := fUserInfo['username'];
  end;
  
  fCategories := NSDictionary.dictionaryWithContentsOfFile(NSBundle.mainBundle.pathForResource('Categories') ofType('plist'));
  fPhotosSmall := new NSMutableDictionary;
  
  loadNextPage();
end;

method AlbumViewController.didReceiveMemoryWarning;
begin
  inherited didReceiveMemoryWarning;

  // Dispose of any resources that can be recreated.
end;

method AlbumViewController.photosChanged;
begin
  tableView.reloadData;
end;

method AlbumViewController.showUserInfo(aSender: id);
begin

end;

method AlbumViewController.loadNextPage();
begin

  var lBlock := method (aResult: NSDictionary; aError: NSError) 
                         begin
                           AppDelegate.decreaseNetworkActivityIndicator();
                           if assigned(aResult) then begin
                             fReloading := false;
                             var lNewPhotos := aResult['photos'];
                             if lNewPhotos.count > 0 then begin
                               if assigned(fPhotoInfo) then
                                 fPhotoInfo := fPhotoInfo.arrayByAddingObjectsFromArray(lNewPhotos)
                               else
                                 fPhotoInfo := aResult['photos'] as NSArray;
                               inc(fCurrentPage);
                               fDone := lNewPhotos.count < PHOTOS_PER_PAGE; 
                               photosChanged();
                             end
                             else begin
                               fDone := true;                          
                               photosChanged();
                             end;
                           end
                           else if assigned(aError) then begin
                             var a := new UIAlertView withTitle('Error') 
                                                          message(aError.description) 
                                                          &delegate(nil) 
                                                          cancelButtonTitle('Ok') 
                                                          otherButtonTitles(nil);
                             a.show();
                           end;
                         end;
 
  if fFeature <> -1 then begin 
    AppDelegate.increaseNetworkActivityIndicator();
    PXRequest.requestForPhotoFeature(fFeature) 
              resultsPerPage(PHOTOS_PER_PAGE) 
              page(fCurrentPage+1)
              completion(lBlock);
  end
  else begin
    AppDelegate.increaseNetworkActivityIndicator();
    PXRequest.requestForPhotosOfUserID(fUserID) 
              userFeature(PXAPIHelperUserPhotoFeature.PXAPIHelperUserPhotoFeaturePhotos)
              resultsPerPage(PHOTOS_PER_PAGE)
              page(fCurrentPage+1) 
              completion(lBlock);
  end;
end;

{$REGION Table view data source}

method AlbumViewController.tableView(tableView: UITableView) numberOfRowsInSection(section: Integer): Integer;
begin
  result := if assigned(fPhotoInfo) then (fPhotoInfo.count + if not fDone then 1 else 0) else 0;
end;

method AlbumViewController.tableView(tableView: UITableView) cellForRowAtIndexPath(indexPath: NSIndexPath): UITableViewCell;
begin
  var CellIdentifier := "Cell";

  result := tableView.dequeueReusableCellWithIdentifier(CellIdentifier);
  if not assigned(result) then begin
    result := new UITableViewCell withStyle(UITableViewCellStyle.UITableViewCellStyleSubtitle) reuseIdentifier(CellIdentifier);

    result.textLabel.font := UIFont.systemFontOfSize(18);
    result.textLabel.textColor := UIColor.lightGrayColor;
    result.detailTextLabel.textColor := UIColor.darkGrayColor;
    result.textAlignment := NSTextAlignment.NSTextAlignmentLeft;
  end;

  var lTempCell := result; //59851: Nougat: two block issues with var capturing (cant capture "result" yet)

  if (indexPath.row = fPhotoInfo.count) then begin
    result.image := nil;
    result.detailTextLabel.text := nil;
    result.textAlignment := NSTextAlignment.NSTextAlignmentCenter;
    if fReloading then begin
      result.textLabel.text := 'there''s more...';
    end
    else begin
      result.textLabel.text := 'loading more photos...';
      result.image := UIImage.imageNamed('234-cloud');
    end;

    
    if not fReloading then
      dispatch_async(@_dispatch_main_q, method begin
          loadNextPage();
          fReloading := true;
          //self.tableView(tableView) didSelectRowAtIndexPath(indexPath); // force load of next batch.
        end);

    exit; 
  end;

  var lPhoto := fPhotoInfo[indexPath.row] as NSDictionary;
  var lPhotoID := lPhoto['id'];

  result.textLabel.text := lPhoto['name']:stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet);
  result.detailTextLabel.text := fCategories[lPhoto['category'].stringValue]; // dictionary wants strings, not NSNumbers as key

  var lUIImage: UIImage; // log this!

  var lImage := fPhotosSmall[lPhotoID];
  if assigned(lImage) then begin
    result.image := lImage;
  end
  else begin
    result.image := UIImage.imageNamed('234-cloud');
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin

        AppDelegate.increaseNetworkActivityIndicator();
        var lData := NSData.dataWithContentsOfURL(NSURL.URLWithString(lPhoto['image_url'].objectAtIndex(0)));
        AppDelegate.decreaseNetworkActivityIndicator();

        {var }lUIImage := UIImage.imageWithData(lData);
        fPhotosSmall[lPhotoID] := lUIImage;
        
        dispatch_async(@_dispatch_main_q, method begin
            lTempCell.image := lUIImage;
            lTempCell.setNeedsLayout();
          end);

    end);
  end;

end;

method AlbumViewController.tableView(tableView: UITableView) willDisplayCell(cell: UITableViewCell) forRowAtIndexPath(indexPath: NSIndexPath);
begin
  cell.backgroundColor := tableView.backgroundColor;
end;

method AlbumViewController.tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
begin

  if (indexPath.row = fPhotoInfo.count) then begin 
    fReloading := true;
    //tableView.deleteRowsAtIndexPaths(NSArray.arrayWithObject(indexPath)) withRowAnimation(UITableViewRowAnimation.UITableViewRowAnimationBottom);
    loadNextPage();
    exit;
  end;

  var lPhoto := fPhotoInfo[indexPath.row] as NSDictionary;
  var lViewController := new PhotoViewController withPhotoInfo(lPhoto);
  navigationController.pushViewController(lViewController) animated(true);
  
  tableView.deselectRowAtIndexPath(indexPath) animated(true);
end;
{$ENDREGION}

end.
