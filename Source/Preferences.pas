namespace Browse500;

interface

uses
  Foundation;

type
  Preferences = public class
  private
    fShowNSFW : Boolean;
    fHasFavorites : Boolean;
    const SETTING_SHOW_NSFW = 'ShowNudeCategory';
    method set_ShowNSFW(aValue: Boolean);


    class var fSharedInstance: Preferences;
    class method get_sharedInstance: Preferences;

    method ubiquitousKVSChanged(aNotificartion: NSNotification);
    method queryDidReceiveNotification(aNotification: NSNotification);
    var fMetadataQuery: NSMetadataQuery;

  protected
  public
    method init: id; override;

    property ShowNSFW: Boolean read fShowNSFW write set_ShowNSFW;

    property DocumentsURL: NSURL := NSFileManager.defaultManager.URLForDirectory(NSSearchPathDirectory.NSDocumentDirectory) 
                               inDomain(NSSearchPathDomainMask.NSUserDomainMask) 
                               appropriateForURL(nil) create(true) error(nil);
    property UbiquitousURL: NSURL;
    property UbiquitousStorageSupported: Boolean read assigned(UbiquitousURL);

    property hasFavorites: Boolean read fHasFavorites;

    method getFavorites: NSArray;
    method triggerFavoritesChanged;

    const NOTIFICATION_SHOW_NSFW_CHANGED = 'com.dwarfland.Browse500.ShowNSFWChanged';
    const NOTIFICATION_FAVORITES_CHANGED = 'com.dwarfland.Browse500.FavoritesChanged';

    class property sharedInstance: Preferences read get_sharedInstance;
  end;

implementation

class method Preferences.get_sharedInstance: Preferences;
begin
  if not assigned(fSharedInstance) then
    fSharedInstance := new Preferences;
  result := fSharedInstance;
end;

//constructor Preferences;
method Preferences.init: id;
begin
  self := inherited init;
  if assigned(self) then begin

    fShowNSFW := NSUbiquitousKeyValueStore.defaultStore.boolForKey(SETTING_SHOW_NSFW);
    NSLog('start: NSWF %d', fShowNSFW);

    NSNotificationCenter.defaultCenter.addObserver(self) 
                                        &selector(selector(ubiquitousKVSChanged:)) 
                                        name(NSUbiquitousKeyValueStoreDidChangeExternallyNotification) 
                                        object(nil);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), 
                    method begin

                      NSUbiquitousKeyValueStore.defaultStore.synchronize();
                       NSLog('after sync: NSWF %d',  NSUbiquitousKeyValueStore.defaultStore.boolForKey(SETTING_SHOW_NSFW));
                      
                      UbiquitousURL := NSFileManager.defaultManager.URLForUbiquityContainerIdentifier(nil);
                      fHasFavorites := getFavorites.count > 0;

                      dispatch_async(@_dispatch_main_q, method begin
                          if fShowNSFW ≠ NSUbiquitousKeyValueStore.defaultStore.boolForKey(SETTING_SHOW_NSFW) then begin
                            fShowNSFW := not fShowNSFW;
                            NSLog('after sync changed NSWF %d', fShowNSFW);
                            NSNotificationCenter.defaultCenter.postNotificationName(NOTIFICATION_SHOW_NSFW_CHANGED) object(self);
                          end;
                          if fHasFavorites then
                            NSNotificationCenter.defaultCenter.postNotificationName(NOTIFICATION_FAVORITES_CHANGED) object(self);
                        end);

                  
                      if UbiquitousStorageSupported then begin
                        fMetadataQuery := new NSMetadataQuery;
                        fMetadataQuery.setPredicate(NSPredicate.predicateWithFormat("%K LIKE '*'", NSMetadataItemFSNameKey));

                        NSNotificationCenter.defaultCenter.addObserver(self) 
                                                            &selector(selector(queryDidReceiveNotification:))
                                                            name(NSMetadataQueryDidUpdateNotification) object(fMetadataQuery);
                        if not fMetadataQuery.startQuery() then
                          NSLog('Could not start metadata query.');
                      end;

                    end);

  end;
  result := self;
end;

method Preferences.queryDidReceiveNotification(aNotification: NSNotification);
begin
  triggerFavoritesChanged();
  NSLog('queryDidReceiveNotification');
end;

method Preferences.ubiquitousKVSChanged(aNotificartion: NSNotification);
begin
  fShowNSFW := NSUbiquitousKeyValueStore.defaultStore.boolForKey(SETTING_SHOW_NSFW);
  NSNotificationCenter.defaultCenter.postNotificationName(NOTIFICATION_SHOW_NSFW_CHANGED) object(self);
  NSLog('ubiquitousKVSChanged: NSWF %d', fShowNSFW);
end;

method Preferences.set_ShowNSFW(aValue: Boolean);
begin
  fShowNSFW := aValue;
  NSUbiquitousKeyValueStore.defaultStore.setBool(aValue) forKey(SETTING_SHOW_NSFW);
  NSUbiquitousKeyValueStore.defaultStore.synchronize;
  NSLog('set_ShowNSFW: NSWF %d', fShowNSFW);
end;

method Preferences.getFavorites: NSArray;
begin
  result := NSFileManager.defaultManager.contentsOfDirectoryAtURL(DocumentsURL)
                                                includingPropertiesForKeys(nil) 
                                                options(NSDirectoryEnumerationOptions(0))  // needing this cast sucks!
                                                error(nil);
  result := result:filteredArrayUsingPredicate(NSPredicate.predicateWithFormat("absoluteString ENDSWITH '.info'"));

  if UbiquitousStorageSupported then begin

    var lCloudFileNames := NSFileManager.defaultManager.contentsOfDirectoryAtURL(UbiquitousURL)
                                                includingPropertiesForKeys(nil) 
                                                options(NSDirectoryEnumerationOptions(0))  // needing this cast sucks!
                                                error(nil);
    lCloudFileNames := lCloudFileNames:filteredArrayUsingPredicate(NSPredicate.predicateWithFormat("absoluteString ENDSWITH '.info'"));
    //result := result.arrayByAddingObjectsFromArray(lCloudFileNames);
    result := lCloudFileNames;
  end;
  //NSLog('Favorites: %@', result);

end;

method Preferences.triggerFavoritesChanged;
begin
  NSNotificationCenter.defaultCenter.postNotificationName(NOTIFICATION_FAVORITES_CHANGED) object(self);
end;

end.
