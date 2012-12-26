namespace Browse500;

interface

uses
  Foundation;

type
  Preferences = public static class
  private
    const SETTING_SHOW_NSFW = 'ShowNudeCategory';
    class fShowNSFW : Boolean;
    class fHasFavorites : Boolean;
    class method set_ShowNSFW(aValue: Boolean);
    constructor;

  protected
  public
    property ShowNSFW: Boolean read fShowNSFW write set_ShowNSFW;

    property DocumentsURL: NSURL := NSFileManager.defaultManager.URLForDirectory(NSSearchPathDirectory.NSDocumentDirectory) 
                               inDomain(NSSearchPathDomainMask.NSUserDomainMask) 
                               appropriateForURL(nil) create(true) error(nil);
    property UbiquitousURL: NSURL := NSFileManager.defaultManager.URLForUbiquityContainerIdentifier(nil);
    property UbiquitousStorageSupported: Boolean read assigned(UbiquitousURL);

    property HasFavorites: Boolean read fHasFavorites;

    method getFavorites: NSArray;
  end;

implementation

constructor Preferences;
begin
  fShowNSFW := NSUserDefaults.standardUserDefaults.boolForKey(SETTING_SHOW_NSFW);

  var lError: NSError;
  NSFileManager.defaultManager.URLForDirectory(NSSearchPathDirectory.NSDocumentDirectory) 
                               inDomain(NSSearchPathDomainMask.NSUserDomainMask) 
                               appropriateForURL(nil) create(true) error(@lError);
  NSLog('iCloud storage error: %@', lError);

  fHasFavorites := getFavorites.count > 0;
end;

class method Preferences.set_ShowNSFW(aValue: Boolean);
begin
  fShowNSFW := aValue;
  NSUserDefaults.standardUserDefaults.setBool(aValue) forKey(SETTING_SHOW_NSFW);
  NSUserDefaults.standardUserDefaults.synchronize;
end;

class method Preferences.getFavorites: NSArray;
begin
  result := NSFileManager.defaultManager.contentsOfDirectoryAtURL(Preferences.DocumentsURL)
                                                includingPropertiesForKeys(nil) 
                                                options(NSDirectoryEnumerationOptions(0))  // needing this cast sucks!
                                                error(nil);
  result := result:filteredArrayUsingPredicate(NSPredicate.predicateWithFormat("absoluteString ENDSWITH '.info'"));

  if Preferences.UbiquitousStorageSupported then begin

    var lCloudFileNames := NSFileManager.defaultManager.contentsOfDirectoryAtURL(Preferences.UbiquitousURL)
                                                includingPropertiesForKeys(nil) 
                                                options(NSDirectoryEnumerationOptions(0))  // needing this cast sucks!
                                                error(nil);
    lCloudFileNames := lCloudFileNames:filteredArrayUsingPredicate(NSPredicate.predicateWithFormat("absoluteString ENDSWITH '.info'"));
    //result := result.arrayByAddingObjectsFromArray(lCloudFileNames);
    result := lCloudFileNames;
  end;
  NSLog('Favorites: %@', result);

end;

end.
