namespace Browse500;

interface

uses
  UIKit;

type
  PhotoViewController = public class(UIViewController)
  private
    fPhotoInfo: NSDictionary;
    fViaUser: Boolean;
  public
    method initWithPhotoInfo(aPhotoInfo: NSDictionary) viaUser(aViaUser: Boolean): id;

    method viewDidLoad; override;
    method viewDidAppear(aAnimated: Boolean); override;
    method didReceiveMemoryWarning; override;

    property shouldAutorotate: Boolean read true; override;
 
    property toolbar: UIToolbar; {IBOutlet}
    property photoView: PhotoView; {IBOutlet}
    method onAction(aSender: id); {IBAction}
    method onUser(aSender: id); {IBAction}
    method onFavorite(aSender: id); {IBAction}
  end;
 
implementation
 
method PhotoViewController.initWithPhotoInfo(aPhotoInfo: NSDictionary) viaUser(aViaUser: Boolean): id;
begin
  if UIDevice.currentDevice.userInterfaceIdiom = UIUserInterfaceIdiom.UIUserInterfaceIdiomPad then
    self := inherited initWithNibName('PhotoViewController~iPad') bundle(nil)
  else
    self := inherited initWithNibName('PhotoViewController~iPhone') bundle(nil);

  if assigned(self) then begin
    
    fPhotoInfo := aPhotoInfo;
    fViaUser := aViaUser;
    NSLog('Photo: %@', fPhotoInfo);
 
  end;
  result := self;
end;
 
method PhotoViewController.viewDidLoad;
begin
  inherited viewDidLoad;

  toolbar:tintColor := navigationController.navigationBar.tintColor;
  title := fPhotoInfo['name'];

  var lUIImage: UIImage; // bug, log

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin

      AppDelegate.increaseNetworkActivityIndicator();
      var lData := NSData.dataWithContentsOfURL(NSURL.URLWithString(fPhotoInfo['image_url'].lastObject));
      AppDelegate.decreaseNetworkActivityIndicator();

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
  if not fViaUser then begin
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
  var lActionsheet := new UIActivityViewController withActivityItems(NSArray.arrayWithObject(photoView.image)) applicationActivities(nil);
  presentViewController(lActionsheet) animated(true) completion(nil);
end;

method PhotoViewController.onUser(aSender: id);
begin
  var lUserID := fPhotoInfo['user']['id'].intValue;
  navigationController.pushViewController(new AlbumViewController withUserID(lUserID)) animated(true);
end;

method PhotoViewController.onFavorite(aSender: id);
begin

end;

end.
