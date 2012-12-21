namespace Browse500;

interface

uses
  UIKit;

type
  PhotoView = public class(UIView)
  private
    method set_image(aValue: UIImage);
    fimage : UIImage;
  public
    method initWithFrame(aFrame: CGRect): id; override;
    method drawRect(aRect: CGRect); override;

    property image: UIImage read fimage write set_image;
  end;

implementation

method PhotoView.initWithFrame(aFrame: CGRect): id;
begin
  self := inherited initWithFrame(aFrame);
  if assigned(self) then begin

    // Custom initialization

  end;
  result := self;
end;

method PhotoView.drawRect(aRect: CGRect);
begin

  var f := frame;
  UIColor.colorWithRed(0.1) green(0.1) blue(0.1) alpha(1.0).setFill;
  UIRectFill(f);


  if not assigned(image) then begin

    var lCloudImage := UIImage.imageNamed('234-cloud');

    var s := lCloudImage.size;

    lCloudImage.drawInRect(CGRectMake( (f.size.width-s.width)/2.0, (f.size.height-s.height)/2.0, s.width, s.height));
    exit;
  end;



  var s := image.size;

  var lHeight := s.height * f.size.width/s.width;
  if lHeight < f.size.height then begin

    image.drawInRect(CGRectMake( 0.0, (f.size.height-lHeight)/2.0, f.size.width, lHeight));
    NSLog('a: %f,%f,%f,%f', (f.size.height-lHeight)/2.0, 0, f.size.width, lHeight);

  end
  else begin
    var lWidth := s.width * f.size.height/s.height;

    image.drawInRect(CGRectMake( (f.size.width-lWidth)/2.0, 0.0, lWidth, f.size.height));
    NSLog('b: %f,%f,%f,%f', 0.0, (f.size.width-lWidth)/2.0, lWidth, f.size.height);

  end;

end;

method PhotoView.set_image(aValue: UIImage);
begin
  fimage := aValue;
  setNeedsDisplay();
end;

end.
