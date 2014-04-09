namespace Browse500;

interface

uses
  UIKit;

type
  SmoothRotationViewController = public class(UIViewController)
  private
    frameBeforeRotation, frameAfterRotation: CGRect;
    snapshotBeforeRotation, snapshotAfterRotation: UIImageView;
  protected
    property smoothView: UIView;
 
    method captureSnapshotOfView(targetView: UIView): UIImageView;
    method frame(frame: CGRect) withHeightFromFrame(heightFrame: CGRect): CGRect;

  public
    method willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation) duration(duration: NSTimeInterval); override;
    method willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation) duration(duration: NSTimeInterval); override;
    method didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation); override;
  end;
 
implementation

method SmoothRotationViewController.captureSnapshotOfView(targetView: UIView): UIImageView;
begin
  
  NSLog('captureSnapshotOfView');

  UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, YES, 0);
    
  CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -targetView.bounds.origin.x, -targetView.bounds.origin.y);
    
  //targetView.layer.renderInContext; // log: misleading error: Error	1	(E44) No member "renderInContext" on type "CALayer"
  targetView.layer.renderInContext(UIGraphicsGetCurrentContext());
  var image := UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
   
  NSLog('saving /Users/mh/temp%f.png', targetView.bounds.size.width);
  UIImagePNGRepresentation(image).writeToFile(NSString.stringWithFormat('/Users/mh/temp%f.png', targetView.bounds.size.width)) atomically(true);
    
  var snapshotView := new UIImageView withImage(image);
  NSLog('snapshotView frame is %f %f %f %f', snapshotView.frame.origin.x, snapshotView.frame.origin.y, snapshotView.frame.size.width, snapshotView.frame.size.height);
  //snapshotView.frame := targetView.frame;
  //NSLog('snapshotView frame to %f %f %f %f', snapshotView.frame.origin.x, snapshotView.frame.origin.y, snapshotView.frame.size.width, snapshotView.frame.size.height);
    
  result := snapshotView;
end;

method SmoothRotationViewController.frame(frame: CGRect) withHeightFromFrame(heightFrame: CGRect): CGRect;
begin
  frame.size.height := heightFrame.size.height;
  result := frame;
end;

method SmoothRotationViewController.willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation) duration(duration: NSTimeInterval);
begin
  NSLog('willRotateToInterfaceOrientation:duration:');
  frameBeforeRotation := smoothView.frame;
  NSLog('frameBeforeRotation %f %f %f %f', frameBeforeRotation.origin.x, frameBeforeRotation.origin.y, frameBeforeRotation.size.width, frameBeforeRotation.size.height);
  snapshotBeforeRotation := captureSnapshotOfView(smoothView);
  view.superview.insertSubview(snapshotBeforeRotation) aboveSubview(smoothView);
end;

{ (UIEdgeInsets)edgeInsetsForSmoothRotationWithWidth:(CGFloat)width
begin
    return UIEdgeInsetsMake(0, width/2, 0, width/2);
end;

(UIEdgeInsets)edgeInsetsForSmoothRotation
begin
    return[self edgeInsetsForSmoothRotationWithWidth:MIN(frameBeforeRotation.size.width, frameBeforeRotation.size.width)];
end;}

method SmoothRotationViewController.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation) duration(duration: NSTimeInterval);
begin
 // NSLog('willAnimateRotationToInterfaceOrientation:duration:');
  //ToDo: otiginal code didnt have to reverse width/height here, why do we?
  frameAfterRotation := smoothView.frame;
  if frameAfterRotation.size.width = 1024 then
    frameAfterRotation.size := CGSizeMake(768, 916)
  else
    frameAfterRotation.size := CGSizeMake(1024, 660);
  smoothView.setFrame(frameAfterRotation);


  NSLog('FIXED frameAfterRotation %f %f %f %f', frameAfterRotation.origin.x, frameAfterRotation.origin.y, frameAfterRotation.size.width, frameAfterRotation.size.height);

  UIView.setAnimationsEnabled(NO);

  // see above

  smoothView.setNeedsLayout();
  smoothView.setNeedsUpdateConstraints();
  smoothView.setNeedsDisplay();
    
  snapshotBeforeRotation.frame := frameBeforeRotation;
    
  snapshotAfterRotation := captureSnapshotOfView(smoothView);
  snapshotAfterRotation.frame := frame(frameBeforeRotation) withHeightFromFrame(snapshotAfterRotation.frame);
    
  smoothView.hidden := true;
    
  var imageBeforeRotation := snapshotBeforeRotation.image;
  var imageAfterRotation := snapshotAfterRotation.image;
    
 { if imageBeforeRotation.respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
  begin
      UIEdgeInsets unstretchedAea = [self edgeInsetsForSmoothRotation];
      imageBeforeRotation = [imageBeforeRotation resizableImageWithCapInsets:unstretchedAea resizingMode:UIImageResizingModeTile];
      imageAfterRotation = [imageAfterRotation resizableImageWithCapInsets:unstretchedAea resizingMode:UIImageResizingModeTile];
        
      [snapshotBeforeRotation setImage:imageBeforeRotation];
      [snapshotAfterRotation setImage:imageAfterRotation];
  end;}
    
  {[UIImagePNGRepresentation([snapshotBeforeRotation image]) writeToFile:@"/Users/mh/Library/Application Support/iPhone Simulator/6.0/Applications/F1024CF2-D77A-41C8-9FFB-EFE1409C449A/Library/Caches/RemObjects/OnyxCI/before" atomically:YES];
    [UIImagePNGRepresentation([snapshotAfterRotation image]) writeToFile:@"/Users/mh/Library/Application Support/iPhone Simulator/6.0/Applications/F1024CF2-D77A-41C8-9FFB-EFE1409C449A/Library/Caches/RemObjects/OnyxCI/after.png" atomically:YES];}
    
  UIView.setAnimationsEnabled(true);
    
  if imageAfterRotation.size.height < imageBeforeRotation.size.height then begin
      snapshotAfterRotation.alpha := 0.0;
      view.superview.insertSubview(snapshotAfterRotation) aboveSubview(snapshotBeforeRotation);
      snapshotAfterRotation.alpha := 1.0;
  end
  else begin
      view.superview.insertSubview(snapshotAfterRotation) belowSubview(snapshotBeforeRotation);
      snapshotBeforeRotation.alpha := 0.0;
  end;
    
  snapshotAfterRotation.frame := frameAfterRotation;
  snapshotBeforeRotation.frame := frame(frameAfterRotation) withHeightFromFrame(snapshotBeforeRotation.frame);
    
end;

method SmoothRotationViewController.didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation);
begin
  NSLog('didRotateFromInterfaceOrientation::');
  snapshotBeforeRotation:removeFromSuperview;
	snapshotAfterRotation:removeFromSuperview;
  snapshotBeforeRotation := nil;
  snapshotAfterRotation := nil;
    
  smoothView.hidden := false;
end;

 
end.
