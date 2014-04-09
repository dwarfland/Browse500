namespace Browse500;

interface

uses
  Foundation, 
  UIKit;

type
  AlbumCollectionViewCell = public class(UICollectionViewCell)
  private
    method set_Photo(aValue: UIImage);
    method set_Blocked(aValue: Boolean);
    method set_Highlighted(value: Boolean);
    fBlocked: Boolean;
    fHighlighted: Boolean;
    fImageView: UIImageView;
    fCloudImageView, fBlockedImageView: UIImageView;
    fHighlightView: UIView;
  protected
  public
    method initWithFrame(aFrame: CGRect): id; override;

 //   method viewDidLoad; override;

    property photo: UIImage read fImageView:image write set_Photo;
    property blocked: Boolean read fBlocked write set_Blocked;

    property highlighted: Boolean read fHighlighted write set_Highlighted; override;

    method prepareForReuse; override;
  end;

implementation

method AlbumCollectionViewCell.prepareForReuse;
begin
  NSLog('cell prepareForReuse: %d', self);
  photo := nil;
  self.setNeedsLayout;
  self.setNeedsDisplay;
end;

method AlbumCollectionViewCell.initWithFrame(aFrame: CGRect): id;
begin
  self := inherited initWithFrame(aFrame);
  if assigned(self) then begin

    var f := frame;
    var lImage := UIImage.imageNamed('234-cloud');
    f := CGRectMake((f.size.width-lImage.size.width)/2, 
                    (f.size.height-lImage.size.height)/2, 
                    lImage.size.width, 
                    lImage.size.height);

    fCloudImageView := new UIImageView withImage(lImage);
    fCloudImageView.frame := f;
    
    lImage := UIImage.imageNamed('298-circlex');
    fBlockedImageView := new UIImageView withImage(lImage);
    fBlockedImageView.frame :=f;

    fImageView := new UIImageView;
    fImageView.frame := bounds;
    contentView.addSubview(fImageView);
  end;
  result := self;
end;

method AlbumCollectionViewCell.set_Photo(aValue: UIImage);
begin
  if assigned(fImageView.image) and assigned(aValue) then begin
    NSLog('cell HAS photo: %ld, %ld, %ld', self, fImageView, fImageView.image);
  end;

  fImageView.image := aValue;
  if assigned(aValue) then begin
    fCloudImageView:removeFromSuperview();
    fBlockedImageView:removeFromSuperview();
    //NSLog('cell GOT photo: %d', self);
  end 
  else begin
    set_Blocked(fBlocked);
    NSLog('cell CLEARED: %ld, %ld, %ld', self, fImageView, fImageView.image);
  end;

  self.setNeedsLayout;
  self.setNeedsDisplay;
end;

method AlbumCollectionViewCell.set_Blocked(aValue: Boolean);
begin
  fImageView.image := nil;

  fBlocked := aValue;

  if fBlocked then begin
    fCloudImageView.removeFromSuperview();
    contentView.addSubview(fBlockedImageView);
  end
  else begin
    fBlockedImageView.removeFromSuperview();
    contentView.addSubview(fCloudImageView);
  end;

  self.backgroundColor := UIColor.colorWithRed(0.15) green(0.15) blue(0.15) alpha(1.0);

  self.setNeedsDisplay;
  self.setNeedsLayout;
end;

method AlbumCollectionViewCell.set_Highlighted(value: Boolean);
begin
  //fHighlightView := new UIImageView withImage(UIImage.imageNamed('OpenInSafari'));
  //addSubview(fHighlightView);
end;

end.
