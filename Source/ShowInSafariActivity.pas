namespace Browse500;

interface

uses
  UIKit;

type
  ShowInSafariActivity = public class(UIActivity)
  private
    fPhotoInfo: NSDictionary;
  protected
  public
    method initWithPhotoInfo(aPhotoInfo: NSDictionary): id; 

    method activityType: String; override;
    method activityTitle: String; override;
    method activityImage: UIImage; override;

    //method activityViewController: UIViewController; override;

    method canPerformWithActivityItems(aActivityItems: NSArray): Boolean; override;
    method prepareWithActivityItems(aActivityItems: NSArray); override;
    method performActivity; override;
  end;

implementation

method ShowInSafariActivity.initWithPhotoInfo(aPhotoInfo: NSDictionary): id;
begin
  self := inherited init;
  if assigned(self) then begin
    fPhotoInfo := aPhotoInfo;
  end;
  result := self;
end;

method ShowInSafariActivity.activityType: String;
begin
  result := 'Safari';
end;

method ShowInSafariActivity.activityTitle: String;
begin
  result := 'Open in Safari'
end;

method ShowInSafariActivity.activityImage: UIImage;
begin
  result := UIImage.imageNamed('OpenInSafari');
end;

method ShowInSafariActivity.prepareWithActivityItems(aActivityItems: NSArray);
begin

end;

method ShowInSafariActivity.canPerformWithActivityItems(aActivityItems: NSArray): Boolean;
begin
  result := true; // in this case, becayse we're cheating and passing in the fPhotoInfo separately.
end;

method ShowInSafariActivity.performActivity;
begin
  UIApplication.sharedApplication.openURL(NSURL.URLWithString('http://www.500px.com/photo/'+fPhotoInfo['id'].stringValue));
end;

{method ShowInSafariActivity.activityViewController: UIViewController;
begin

end;}

end.
