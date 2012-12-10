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
    method photosChanged;
  protected

    {$REGION Table view data source}
    method tableView(tableView: UITableView) numberOfRowsInSection(section: Integer): Integer;
    method tableView(tableView: UITableView) cellForRowAtIndexPath(indexPath: NSIndexPath): UITableViewCell;
    method tableView(tableView: UITableView) willDisplayCell(cell: UITableViewCell) forRowAtIndexPath(indexPath: NSIndexPath);
    {$ENDREGION}

    {$REGION Table view delegate}
    method tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
    {$ENDREGION}

  public
    method init: id; override;
    method initWithUserID(aUserID: Int32): id;
    method initWithUserInfo(aUserInfo: NSDictionary): id;
    method initWithFeature(aFeature: PXAPIHelperPhotoFeature): id;

    method viewDidLoad; override;
    method didReceiveMemoryWarning; override;

    method showUserInfo(aSender: id);

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
  
  //tableView.separatorStyle := UITableViewCellSeparatorStyle.UITableViewCellSeparatorStyleNone;
  tableView.separatorColor := UIColor.colorWithRed(0.1) green(0.2) blue(0.2) alpha(1.0);
  tableView.backgroundColor := UIColor.colorWithRed(0.1) green(0.1) blue(0.1) alpha(1.0);

  if fFeature <> -1 then begin
    title := FEATURE_TITLES[fFeature];
  end
  else if not assigned(fUserInfo) then begin
    title := '∞';
    PXRequest.requestForUserWithID(fUserID) completion(method (aResult: NSDictionary; aError: NSError) 
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
  
  if fFeature <> -1 then begin
    PXRequest.requestForPhotoFeature(fFeature) 
              resultsPerPage(PHOTOS_PER_PAGE) 
              completion(method (aResult: NSDictionary; aError: NSError) 
                         begin
                           NSLog('done! %@', aResult);
                           if assigned(aResult) then begin
                             fPhotoInfo := aResult['photos'] as NSArray;
                             photosChanged;
                             fCurrentPage := 1;
                           end
                           else if assigned(aError) then begin
                             var a := new UIAlertView withTitle('Error') message(aError.description) &delegate(nil) cancelButtonTitle('Ok') otherButtonTitles(nil);
                             a.show();
                           end;
                         end);
  end
  else begin
    PXRequest.requestForPhotosOfUserID(fUserID) completion(method (aResult: NSDictionary; aError: NSError) 
                                                              begin
                                                                NSLog('done! %@', aResult);
                                                                if assigned(aResult) then begin
                                                                  fPhotoInfo := aResult['photos'] as NSArray;
                                                                  photosChanged;
                                                                  fCurrentPage := 1;
                                                                end
                                                                else if assigned(aError) then begin
                                                                  var a := new UIAlertView withTitle('Error') message(aError.description) &delegate(nil) cancelButtonTitle('Ok') otherButtonTitles(nil);
                                                                  a.show();
                                                                end;
                                                              end);
  end;

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

{$REGION Table view data source}

method AlbumViewController.tableView(tableView: UITableView) numberOfRowsInSection(section: Integer): Integer;
begin
  result := if assigned(fPhotoInfo) then (fPhotoInfo.count + if not fReloading then 1 else 0) else 0;
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

  if (indexPath.row = fPhotoInfo.count) then begin
    result.image := nil;
    result.detailTextLabel.text := nil;
    result.textLabel.text := 'more...';
    result.textAlignment := NSTextAlignment.NSTextAlignmentCenter;
    //exit; RETEST AFTER BLOCKS ARE FIXED
  end
  else begin

    var lPhoto := fPhotoInfo[indexPath.row] as NSDictionary;
    var lPhotoID := lPhoto['id'];

    result.textLabel.text := lPhoto['name'];
    result.detailTextLabel.text := fCategories[lPhoto['category'].stringValue]; // dictionary wants strings, not NSNumbers as key

    var lImage := fPhotosSmall[lPhotoID];
    if assigned(lImage) then begin
      result.image := lImage;
    end
    else begin
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin

          var lData := NSData.dataWithContentsOfURL(NSURL.URLWithString(lPhoto['image_url'].objectAtIndex(0)));
          var lUIImage := UIImage.imageWithData(lData);
          fPhotosSmall[lPhotoID] := lUIImage;

          //dispatch_async(dispatch_get_main_queue(), method begin

          //  photosChanged;
            result.image := lUIImage;

          //  end);

        end);
    
      {PXRequest.requestForPhotoID(lID.intValue) 
                photoSizes(PXPhotoModelSize.PXPhotoModelSizeSmallThumbnail) 
                commentsPage(0) 
                completion(method (aResult: NSDictionary; aError: NSError) 
                           begin
                             NSLog('dphoto detail: %@', aResult);
                             //NSLog('done! %d photos', aResult['photos'].count);
                             // fPhotoSmall := aResult['photos'] as NSArray;
                             //photosChanged;
                           end);}
    end;

  end; // gtem,p
  // Configure the individual cell...
end;

method AlbumViewController.tableView(tableView: UITableView) willDisplayCell(cell: UITableViewCell) forRowAtIndexPath(indexPath: NSIndexPath);
begin
  cell.backgroundColor := tableView.backgroundColor;
end;


{$ENDREGION}

{$REGION  Table view delegate}

method AlbumViewController.tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
begin

  if (indexPath.row = fPhotoInfo.count) then begin 
    fReloading := true;
    tableView.deleteRowsAtIndexPaths(NSArray.arrayWithObject(indexPath)) withRowAnimation(UITableViewRowAnimation.UITableViewRowAnimationBottom);

  PXRequest.requestForPhotosOfUserID(fUserID) 
            userFeature(PXAPIHelperUserPhotoFeature.PXAPIHelperUserPhotoFeaturePhotos)
            resultsPerPage(PHOTOS_PER_PAGE) page(fCurrentPage+1) 
            completion(method (aResult: NSDictionary; aError: NSError) 
                       begin
                         NSLog('more %@', aResult);
                         if assigned(aResult) then begin
                           var lNewPhotos := aResult['photos'];
                           if lNewPhotos.count > 0 then begin
                             fPhotoInfo := fPhotoInfo.arrayByAddingObjectsFromArray(lNewPhotos);
                             fReloading := false;
                             inc(fCurrentPage);
                             photosChanged();
                           end
                           else begin

                           end;
                         end;
                       end);
  end;
  
  tableView.deselectRowAtIndexPath(indexPath) animated(true);
end;


{$ENDREGION}

end.
