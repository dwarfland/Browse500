namespace Browse500;

interface

uses
  UIKit;

type
  PhotoViewController = public class(UIViewController)
  private
    fPhotoInfo: NSDictionary;
  public
    method initWithPhotoInfo(aPhotoInfo: NSDictionary): id;

    method viewDidLoad; override;
    method didReceiveMemoryWarning; override;

    property shouldAutorotate: Boolean read true; override;
 
    property toolbar: UIToolbar; {IBOutlet}
    method actionTabbed(aSender: id); {IBAction}
    method userTabbed(aSender: id); {IBAction}
  end;
 
implementation
 
method PhotoViewController.initWithPhotoInfo(aPhotoInfo: NSDictionary): id;
begin
  if UIDevice.currentDevice.userInterfaceIdiom = UIUserInterfaceIdiom.UIUserInterfaceIdiomPad then
    self := inherited initWithNibName('PhotoViewController~iPad') bundle(nil)
  else
    self := inherited initWithNibName('PhotoViewController~iPhone') bundle(nil);

  if assigned(self) then begin
    
    fPhotoInfo := aPhotoInfo;
    NSLog('Photo: %@', fPhotoInfo);
 
  end;
  result := self;
end;
 
method PhotoViewController.viewDidLoad;
begin
  inherited viewDidLoad;

  toolbar:tintColor := navigationController.navigationBar.tintColor;
  title := fPhotoInfo['name'];

  //var lScrollView := new UIScrollView withFrame(view.bounds);
  //view.addSubview(lScrollView);

  var lImageView := new PhotoView withFrame(view.bounds);

  //lScrollView.addSubview(lImageView);
  //lScrollView.contentSize := lImageView.bounds.size;
 
  view.addSubview(lImageView);
  lImageView.contentMode :=  UIViewContentMode.UIViewContentModeCenter;

  var lUIImage: UIImage; // bug, log

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin

      AppDelegate.increaseNetworkActivityIndicator();
      var lData := NSData.dataWithContentsOfURL(NSURL.URLWithString(fPhotoInfo['image_url'].lastObject));
      AppDelegate.decreaseNetworkActivityIndicator();

      {var }lUIImage := UIImage.imageWithData(lData);
        
      dispatch_async(@_dispatch_main_q, method begin
          lImageView.image := lUIImage;
          //lImageView.contentMode :=  UIViewContentMode.UIViewContentModeScaleAspectFit;
          //lImageView.setFrame(CGRectMake(0, 0, lUIImage.size.width, lUIImage.size.height)); // NRE
          //lScrollView.contentSize := lImageView.bounds.size;
        end);

  end);  
  // Do any additional setup after loading the view.
end;
 
method PhotoViewController.didReceiveMemoryWarning;
begin
  inherited didReceiveMemoryWarning;
 
  // Dispose of any resources that can be recreated.
end;

method PhotoViewController.actionTabbed(aSender: id);
begin

end;

method PhotoViewController.userTabbed(aSender: id);
begin

end;
 
end.
