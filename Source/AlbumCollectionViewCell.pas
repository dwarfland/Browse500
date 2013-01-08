namespace Browse500;

interface

uses
  Foundation, 
  UIKit;

type
  AlbumCollectionViewCell = public class(UIView)//UICollectionViewCell)
  private
    method set_image(aValue: UIImage);
    method set_Blocked(aValue: Boolean);
    method set_Highlighted(value: Boolean);
    fBlocked: Boolean;
    fHighlighted: Boolean;
    fImageView: UIImageView;
    fTempImageView: UIImageView;
    fHighlightView: UIView;
  protected
  public
    method initWithFrame(aFrame: CGRect): id; override;

 //   method viewDidLoad; override;

    property image: UIImage read fImageView:image write set_image;
    property blocked: Boolean read fBlocked write set_Blocked;

    property highlighted: Boolean read fHighlighted write set_Highlighted; 
  end;

implementation

method AlbumCollectionViewCell.initWithFrame(aFrame: CGRect): id;
begin
  self := inherited initWithFrame(aFrame);
  var f := frame;

  var lCloudImage := UIImage.imageNamed('234-cloud');
  fTempImageView := new UIImageView withImage(lCloudImage);
  fTempImageView.frame :=  CGRectMake((f.size.width-lCloudImage.size.width)/2, 
                                      (f.size.height-lCloudImage.size.height)/2, 
                                      lCloudImage.size.width, 
                                      lCloudImage.size.height);
  {contentView.}addSubview(fTempImageView);
  result := self;
end;

method AlbumCollectionViewCell.set_image(aValue: UIImage);
begin
  fTempImageView:removeFromSuperview();
  fTempImageView := nil;

  fImageView := new UIImageView withImage(aValue);
  fImageView.frame := frame;
  {contentView.}addSubview(fImageView);
  self.setNeedsDisplay;
end;

method AlbumCollectionViewCell.set_Blocked(aValue: Boolean);
begin
  if not assigned(fTempImageView) then exit;

  fBlocked := aValue;
  // we rely on both image shaving the same size, so the frame set above is good.
  fTempImageView:image := if aValue then UIImage.imageNamed('298-circlex') else UIImage.imageNamed('234-cloud');

  //fBackgroundView := new UIView withFrame(frame);
  //fBackgroundView.backgroundColor :=;
  self.backgroundColor := UIColor.colorWithRed(0.15) green(0.15) blue(0.15) alpha(1.0);

  self.setNeedsDisplay;
end;

method AlbumCollectionViewCell.set_Highlighted(value: Boolean);
begin
  fHighlightView := new UIImageView withImage(UIImage.imageNamed('OpenInSafari'));
  addSubview(fHighlightView);
end;

end.
