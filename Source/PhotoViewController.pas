namespace Browse500;

interface

uses
  UIKit;

type
  PhotoViewController = public class(UIViewController)
  private
    fPhotoInfo: NSDictionary;
    fAlbumType: AlbumType;
  public
    method initWithPhotoInfo(aPhotoInfo: NSDictionary) viaAlbumType(aAlbumType: AlbumType): id;

    method viewDidLoad; override;
    method viewDidAppear(aAnimated: Boolean); override;
    method didReceiveMemoryWarning; override;

    property shouldAutorotate: Boolean read true; override;
 
    property toolbar: weak UIToolbar; {IBOutlet}
    property photoView: weak PhotoView; {IBOutlet}
    property favoriteButton: UIBarButtonItem; {IBOutlet}
    method onAction(aSender: id); {IBAction}
    method onUser(aSender: id); {IBAction}
    method onFavorite(aSender: id); {IBAction}
  end;

  AlbumType = public enum(Featured, User, Favorites);
 
implementation
 
method PhotoViewController.initWithPhotoInfo(aPhotoInfo: NSDictionary) viaAlbumType(aAlbumType: AlbumType): id;
begin
  if UIDevice.currentDevice.userInterfaceIdiom = UIUserInterfaceIdiom.UIUserInterfaceIdiomPad then
    self := inherited initWithNibName('PhotoViewController~iPad') bundle(nil)
  else
    self := inherited initWithNibName('PhotoViewController~iPhone') bundle(nil);

  if assigned(self) then begin
    
    fPhotoInfo := aPhotoInfo;
    fAlbumType := aAlbumType;
    NSLog('Photo: %@', fPhotoInfo);
 
  end;
  result := self;
end;
 
method PhotoViewController.viewDidLoad;
begin
  inherited viewDidLoad;

  toolbar:tintColor := navigationController.navigationBar.tintColor;
  title := fPhotoInfo['name'];

  // favrites feature is disabled for 1.0; hide the button unless the user already has favorites (ie is a beta tester)
  {$IF NOT TARGET_IPHONE_SIMULATOR}
  if not Preferences.sharedInstance.hasFavorites then begin
    var lButtons := toolbar.items.mutableCopy;
    lButtons.removeObject(favoriteButton);
    toolbar.items := lButtons;
  end;
  {$ENDIF}

  var lUIImage: UIImage; // bug, log

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin

      AppDelegate.increaseNetworkActivityIndicator();
      var lData := NSData.dataWithContentsOfURL(NSURL.URLWithString(fPhotoInfo['image_url'].lastObject));
      AppDelegate.decreaseNetworkActivityIndicator();

      if not assigned(lData) then exit;

      {var }lUIImage := UIImage.imageWithData(lData);
        
      dispatch_async(@_dispatch_main_q, method begin
          photoView.image := lUIImage;
        end);

  end);  
  // Do any additional setup after loading the view.
end;

method PhotoViewController.viewDidAppear(aAnimated: Boolean);
begin
  //if for fViaUser then NRE!
  if  fAlbumType ≠ AlbumType.User then begin
    if UIDevice.currentDevice.userInterfaceIdiom = UIUserInterfaceIdiom.UIUserInterfaceIdiomPad then
      navigationController.navigationBar.topItem.rightBarButtonItem := new UIBarButtonItem withTitle(fPhotoInfo['user']['username'])
                                                                                               style(UIBarButtonItemStyle.UIBarButtonItemStyleBordered) 
                                                                                               target(self) action(selector(onUser:))
    else
      navigationController.navigationBar.topItem.rightBarButtonItem := new UIBarButtonItem withImage(UIImage.imageNamed('24-person'))
                                                                                               style(UIBarButtonItemStyle.UIBarButtonItemStyleBordered) 
                                                                                               target(self) action(selector(onUser:));
  end
  else begin
    //navigationController.navigationBar.topItem.backBarButtonItem.image := UIImage.imageNamed('24-person');
  end;

end;
 

 
method PhotoViewController.didReceiveMemoryWarning;
begin
  inherited didReceiveMemoryWarning;
 
  // Dispose of any resources that can be recreated.
end;

method PhotoViewController.onAction(aSender: id);
begin
  if assigned(photoView.image) then begin
    var lActionsheet := new UIActivityViewController withActivityItems(NSArray.arrayWithObject(photoView.image)) 
                                                         applicationActivities(NSArray.arrayWithObject(new ShowInSafariActivity withPhotoInfo(fPhotoInfo)));
    presentViewController(lActionsheet) animated(true) completion(nil);
  end;
end;

method PhotoViewController.onUser(aSender: id);
begin
  var lUserID := fPhotoInfo['user']['id'].intValue;
  navigationController.pushViewController(new AlbumViewController withUserID(lUserID)) animated(true);
end;

method PhotoViewController.onFavorite(aSender: id);
begin
  var lFilename := fPhotoInfo['id'].stringValue+'.info';
  var lLocalFile := Preferences.sharedInstance.DocumentsURL.URLByAppendingPathComponent(lFilename);
  
  fPhotoInfo.writeToURL(lLocalFile) atomically(true);
  NSLog('Saved locally to %@', lLocalFile);

  if assigned(photoView.image) then begin
    var lLocalImageFile := Preferences.sharedInstance.DocumentsURL.URLByAppendingPathComponent(lFilename.stringByDeletingPathExtension.stringByAppendingPathExtension('jpeg'));
    UIImageJPEGRepresentation(photoView.image, 10).writeToURL(lLocalImageFile) atomically(true);
    NSLog('Saved cached image to %@', lLocalImageFile);
  end;

  if Preferences.sharedInstance.UbiquitousStorageSupported then begin

    var lCloudFile := Preferences.sharedInstance.UbiquitousURL.URLByAppendingPathComponent(lFilename);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin
                                                                                    //var lError: NSError;
        NSFileManager.defaultManager.setUbiquitous(true) itemAtURL(lLocalFile) destinationURL(lCloudFile) error({@lError}nil); 
        NSLog('Saved to iCloud at to %@', lCloudFile);
        //NSLog('Saved to iCloud at to %@, Error: %@', lCloudFile, lError);
      end);

  end;

  Preferences.sharedInstance.triggerFavoritesChanged();
end;

end.
