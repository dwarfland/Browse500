namespace Browse500;

interface

uses
  UIKit;

type
  PhotoView = public class(UIView)
  private
    method set_image(aValue: UIImage);
    method set_zoomToFit(aValue: Boolean);
    method setImageViewFrameAnimated(aAnimated: Boolean);
    fImage : UIImage;
    fZoomToFit : Boolean;
    fImageView: UIImageView;
  public
    method initWithFrame(aFrame: CGRect): id; override;

    method drawRect(aRect: CGRect); override;
    method layoutSubviews; override;

    property image: UIImage read fImage write set_image;
    property zoomToFit: Boolean read fZoomToFit write set_zoomToFit;
  end;

  //ToDo: add smoother rotation animation

implementation

method PhotoView.initWithFrame(aFrame: CGRect): id;
begin
  self := inherited initWithFrame(aFrame);
  if assigned(self) then begin
    contentMode := UIViewContentMode.UIViewContentModeRedraw;
    //backgroundColor := UIColor.colorWithRed(0.1) green(0.1) blue(0.1) alpha(1.0);
    backgroundColor := UIColor.redColor;
    opaque := true;
  end;
  result := self;
end;


method PhotoView.layoutSubviews;
begin
  inherited;
  setImageViewFrameAnimated(true);
end;

method PhotoView.drawRect(aRect: CGRect);
begin
  inherited;

  var f := bounds;
  UIColor.colorWithRed(0.1) green(0.1) blue(0.1) alpha(1.0).setFill;
  UIRectFill(f);

  if not assigned(image) then begin
    var lCloudImage := UIImage.imageNamed('234-cloud');
    var s := lCloudImage.size;
    lCloudImage.drawInRect(CGRectMake( (f.size.width-s.width)/2.0, (f.size.height-s.height)/2.0, s.width, s.height));
    exit;
  end;

  {var s := image.size;

  // both same just the < is reversed
  if fZoomToFit then begin

    var lHeight := s.height * f.size.width/s.width;
    if lHeight > f.size.height then begin
      image.drawInRect(CGRectMake( 0.0, (f.size.height-lHeight)/2.0, f.size.width, lHeight));
    end
    else begin
      var lWidth := s.width * f.size.height/s.height;
      image.drawInRect(CGRectMake( (f.size.width-lWidth)/2.0, 0.0, lWidth, f.size.height));
    end;

  end
  else begin

    var lHeight := s.height * f.size.width/s.width;
    if lHeight < f.size.height then begin
      image.drawInRect(CGRectMake( 0.0, (f.size.height-lHeight)/2.0, f.size.width, lHeight));
    end
    else begin
      var lWidth := s.width * f.size.height/s.height;
      image.drawInRect(CGRectMake( (f.size.width-lWidth)/2.0, 0.0, lWidth, f.size.height));
    end;

  end;}

end;

method PhotoView.setImageViewFrameAnimated(aAnimated: Boolean);
begin
  if not assigned(fImageView) then exit;

  var b := method begin

      var f := bounds;
      var s := image.size;

      if fZoomToFit then begin

        var lHeight := s.height * f.size.width/s.width;
        if lHeight > f.size.height then begin
          fImageView:frame := CGRectMake( 0.0, (f.size.height-lHeight)/2.0, f.size.width, lHeight);
        end
        else begin
          var lWidth := s.width * f.size.height/s.height;
           fImageView:frame := CGRectMake( (f.size.width-lWidth)/2.0, 0.0, lWidth, f.size.height);
        end;

      end
      else begin

        var lHeight := s.height * f.size.width/s.width;
        if lHeight < f.size.height then begin
           fImageView:frame := CGRectMake( 0.0, (f.size.height-lHeight)/2.0, f.size.width, lHeight);
        end
        else begin
          var lWidth := s.width * f.size.height/s.height;
           fImageView:frame := CGRectMake( (f.size.width-lWidth)/2.0, 0.0, lWidth, f.size.height);
        end;

      end;

    end; // b

  if aAnimated then
    UIView.animateWithDuration(0.15) animations(b)
  else
    b();

end;

method PhotoView.set_image(aValue: UIImage);
begin
  fImage := aValue;
  fImageView:removeFromSuperview();
  fImageView := new UIImageView withImage(fImage);
  fImageView.autoresizingMask := UIViewAutoresizing.UIViewAutoresizingFlexibleWidth or UIViewAutoresizing.UIViewAutoresizingFlexibleHeight;
  setImageViewFrameAnimated(false);
  addSubview(fImageView); 
  //setNeedsDisplay();
end;

method PhotoView.set_zoomToFit(aValue: Boolean);
begin
  if aValue <> fZoomToFit then begin
    fZoomToFit := aValue;
    //setNeedsDisplay();
    setImageViewFrameAnimated(true);
  end;
end;

end.
