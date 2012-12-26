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
  end;

implementation

method FavoritesAlbumViewController.init: id;
begin
  self := inherited init;//WithStyle(UITableViewStyle.UITableViewStylePlain);
  if assigned(self) then begin

    fFileNames := Preferences.getFavorites();

    albumType := albumType.Favorites;

  end;
  result := self;
end;

method FavoritesAlbumViewController.doLoadNextPage(aPage: Int32; aBlock: NewPhotosBlock);
begin

  var lTempArray := NSMutableArray.arrayWithCapacity(PAGE_SIZE);
  for i: UInt32 := fLoadedCount to fLoadedCount+PAGE_SIZE do begin

    if i ≥ fFileNames.count then break;
    var lPhotoInfo := NSDictionary.dictionaryWithContentsOfURL(fFileNames[i]);
    if assigned(lPhotoInfo) then begin
      lTempArray.addObject(lPhotoInfo)
    end
    else begin
      NSFileManager.defaultManager.startDownloadingUbiquitousItemAtURL(fFileNames[i]) error(nil);
      NSLog('requested download of item '+fFileNames[i].absoluteString);
      //ToDo: need to handle this so the image will show once its downloaded
    end;
    inc(fLoadedCount);

  end;
  aBlock(lTempArray);
end;

end.
