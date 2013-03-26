namespace Browse500;

interface

uses
  Foundation, 
  PXAPI, 
  UIKit;

type
  Preferences = public class(IUIPopoverControllerDelegate)
  private
    fShowNSFW : Boolean;
    fHasFavorites : Boolean;
    fIsAuthentciated: Boolean;
    fUsername: String;

    const SETTING_SHOW_NSFW = 'ShowNudeCategory';
    const SETTING_USERNAME = 'Username';
    const SETTING_PASSWORD = 'Password';
    method set_ShowNSFW(aValue: Boolean);

    class var fSharedInstance: Preferences;
    class method get_sharedInstance: Preferences;

    method ubiquitousKVSChanged(aNotificartion: NSNotification);
    method queryDidReceiveNotification(aNotification: NSNotification);
    var fMetadataQuery: NSMetadataQuery;
    var fLoginPopup: UIPopoverController;

  protected
    {$REGION IUIPopoverControllerDelegate}
    method popoverControllerDidDismissPopover(popoverController: UIKit.UIPopoverController);
    {$ENDREGION}
  public
    method init: id; override;

    property ShowNSFW: Boolean read fShowNSFW write set_ShowNSFW;

    property CacheURL: NSURL := NSFileManager.defaultManager.URLForDirectory(NSSearchPathDirectory.NSCachesDirectory) 
                                                             inDomain(NSSearchPathDomainMask.NSUserDomainMask) 
                                                             appropriateForURL(nil) create(true) error(nil);
    property DocumentsURL: NSURL := NSFileManager.defaultManager.URLForDirectory(NSSearchPathDirectory.NSDocumentDirectory) 
                                                                 inDomain(NSSearchPathDomainMask.NSUserDomainMask) 
                                                                 appropriateForURL(nil) create(true) error(nil);
    property UbiquitousURL: NSURL;
    property UbiquitousStorageSupported: Boolean read assigned(UbiquitousURL);

    property isAuthentciated: Boolean read fIsAuthentciated;
    property username: String read fUsername;

    property hasFavorites: Boolean read fHasFavorites;

    method getFavorites: NSArray;
    method triggerFavoritesChanged;

    const NOTIFICATION_SHOW_NSFW_CHANGED = 'com.dwarfland.Browse500.ShowNSFWChanged';
    const NOTIFICATION_FAVORITES_CHANGED = 'com.dwarfland.Browse500.FavoritesChanged';

    method authenticateWithCompletion(aCompletion: block) currentViewController(aViewController: UIViewController) barButtonItem(aButtonItem: UIBarButtonItem);
    method tryAuthenticateWithUsername(aUsername: String) password(aPassword: String) completion(aCompletion: block (aSuccess: Boolean));

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

                      dispatch_async(dispatch_get_main_queue(), method begin
                          if fShowNSFW ≠ NSUbiquitousKeyValueStore.defaultStore.boolForKey(SETTING_SHOW_NSFW) then begin
                            fShowNSFW := not fShowNSFW;
                            NSLog('after sync changed NSWF %d', fShowNSFW);
                            NSNotificationCenter.defaultCenter.postNotificationName(NOTIFICATION_SHOW_NSFW_CHANGED) object(self);
                          end;
                          if fHasFavorites then
                            NSNotificationCenter.defaultCenter.postNotificationName(NOTIFICATION_FAVORITES_CHANGED) object(self);
                        end);

                      fUsername := NSUserDefaults.standardUserDefaults.objectForKey(SETTING_USERNAME);
                      NSLog('Username: %@', fUsername);
                      if length(fUsername) > 0 then
                        tryAuthenticateWithUsername(fUsername) 
                                           password(NSUserDefaults.standardUserDefaults.objectForKey(SETTING_PASSWORD)) 
                                           completion(nil);
                  
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

method Preferences.tryAuthenticateWithUsername(aUsername: String) password(aPassword: String) completion(aCompletion: block(aSuccess: Boolean));
begin
  if (length(aUsername) > 0) and (length(aPassword) > 0) then begin
    PXRequest.authenticateWithUserName(aUsername) password(aPassword) completion(method (aSuccess: Boolean) begin
        NSLog('result: %d', aSuccess);

        fIsAuthentciated := aSuccess;
        if aSuccess then begin
          NSUserDefaults.standardUserDefaults.setObject(aUsername) forKey(SETTING_USERNAME);
          NSUserDefaults.standardUserDefaults.setObject(aPassword) forKey(SETTING_PASSWORD);
          NSUserDefaults.standardUserDefaults.synchronize;
        end;
        if assigned(aCompletion) then aCompletion(aSuccess);
      end);
  end
  else begin
    if assigned(aCompletion) then aCompletion(false);
  end;
end;

method Preferences.authenticateWithCompletion(aCompletion: block) currentViewController(aViewController: UIViewController) barButtonItem(aButtonItem: UIBarButtonItem);
begin
  if assigned(fLoginPopup) then begin
    fLoginPopup.dismissPopoverAnimated(true);
    fLoginPopup := nil;
    exit;
  end;

  if not isAuthentciated then begin
    var lLogin := new LoginViewController();
    lLogin.loginSuccessfulCallback := aCompletion;
    lLogin.dismissCallback := method (aDismissCompletion: block) begin
        if assigned(fLoginPopup) then begin
          fLoginPopup.dismissPopoverAnimated(true);
          fLoginPopup := nil;
          if assigned(aDismissCompletion) then aDismissCompletion();
        end
        else begin
          // 61372: Nougat: Weird block crash in Browse500
          //lLogin.dismissViewControllerAnimated(true) completion(aDismissCompletion);
        end;
      end;

    if UIDevice.currentDevice.userInterfaceIdiom = UIUserInterfaceIdiom.UIUserInterfaceIdiomPad then begin
      fLoginPopup := new UIPopoverController withContentViewController(lLogin);
      //61361: Nougat: anonymous interfaces dont support inline methods yet
      fLoginPopup.delegate := self;{new interface IUIPopoverControllerDelegate(popoverControllerDidDismissPopover := method begin 
          fLoginPopup := nil;
        end);}
      fLoginPopup.presentPopoverFromBarButtonItem(aButtonItem) 
             permittedArrowDirections(UIPopoverArrowDirection.UIPopoverArrowDirectionAny) 
             animated(true); 
    end
    else begin
      aViewController.presentViewController(lLogin) animated(true) completion(nil); 
    end;

  end
  else begin
    if assigned(aCompletion) then aCompletion();
  end;

end;

method Preferences.popoverControllerDidDismissPopover(popoverController: UIKit.UIPopoverController);
begin
  fLoginPopup := nil;
end;

end.
