namespace Browse500;

interface

uses
  Foundation;

type
  FavoritesAlbumViewController = public class(AlbumViewController)
  private
    fFileNames: NSArray;
    fLoadedCount: Int32;

    const PAGE_SIZE = 200;
  protected
    method doLoadNextPage(aPage: Int32; aBlock: NewPhotosBlock); override;
  public
    method init: id; override;
    method viewDidLoad; override;
  end;

implementation

method FavoritesAlbumViewController.init: id;
begin
  self := inherited init;//WithStyle(UITableViewStyle.UITableViewStylePlain);
  if assigned(self) then begin

    fFileNames := Preferences.sharedInstance.getFavorites();

    albumType := albumType.Favorites;

  end;
  result := self;
end;

method FavoritesAlbumViewController.doLoadNextPage(aPage: Int32; aBlock: NewPhotosBlock);
begin

  //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin
    var lTempArray := NSMutableArray.arrayWithCapacity(PAGE_SIZE);
    for i: UInt32 := fLoadedCount to fLoadedCount+PAGE_SIZE do begin

      if i ≥ fFileNames.count then break;
      var lPhotoInfo := NSDictionary.dictionaryWithContentsOfURL(fFileNames[i]);
      if assigned(lPhotoInfo) then begin
        lTempArray.addObject(lPhotoInfo)
      end
      else begin
        NSFileManager.defaultManager.startDownloadingUbiquitousItemAtURL(fFileNames[i]) error(nil);
        NSLog('requested download of item %@', fFileNames[i].absoluteString);
        lTempArray.addObject(fFileNames[i]);

        {dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin

            var lCoordinator := new NSFileCoordinator withFilePresenter(nil);
            lCoordinator.coordinateReadingItemAtURL(fFileNames[i]) 
                         options(NSFileCoordinatorReadingOptions(0)) 
                         error(nil) byAccessor(method (aURL: NSURL) begin
                                                 NSLog('item downloaded? %@', aURL.absoluteString);
                                               end);
        end);}

        //ToDo: need to handle this so the image will show once its downloaded
      end;
      inc(fLoadedCount);

    end;
    aBlock(lTempArray);

// end);
end;

method FavoritesAlbumViewController.viewDidLoad;
begin
  inherited viewDidLoad();

  NSNotificationCenter.defaultCenter.addObserver(self) 
                                  &selector(selector(photosChanged:)) 
                                  name(Preferences.NOTIFICATION_FAVORITES_CHANGED)
                                  object(Preferences.sharedInstance);

end;

end.
