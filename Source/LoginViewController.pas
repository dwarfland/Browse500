namespace Browse500;

interface

uses
  PXAPI,
  UIKit;

type
  [IBObject]
  LoginViewController = public class(UIViewController)
  private
  public
    method init: id; override;

    method viewDidLoad; override;
    method didReceiveMemoryWarning; override;

    [IBOutlet] property username: UITextField;
    [IBOutlet] property password: UITextField;
    [IBOutlet] property activity: UIActivityIndicatorView;
    [IBOutlet] property loginFailed: UILabel;
    [IBAction] method login(aSender: id);
    [IBAction] method cancel(aSender: id);

    property loginSuccessfulCallback: weak block;
    property dismissCallback: weak block(aCompletion: block);
  end;

implementation

method LoginViewController.init: id;
begin
  self := inherited initWithNibName('LoginViewController') bundle(nil);
  if assigned(self) then begin

    contentSizeForViewInPopover := CGSizeMake(320.0, 200.0);
    // Custom initialization

  end;
  result := self;
end;

method LoginViewController.viewDidLoad;
begin
  inherited viewDidLoad;
  if length(Preferences.sharedInstance.username) > 0 then
    username.text := Preferences.sharedInstance.username;

  // Do any additional setup after loading the view.
end;

method LoginViewController.didReceiveMemoryWarning;
begin
  inherited didReceiveMemoryWarning;

  // Dispose of any resources that can be recreated.
end;

method LoginViewController.login(aSender: id);
begin
  if (length(username.text) > 0) and (length(password.text) > 0) then begin

    aSender.enabled := false;
    loginFailed.hidden := true;
    activity.startAnimating();

    Preferences.sharedInstance.tryAuthenticateWithUsername(username.text) password(password.text) completion(method (aSuccess: Boolean) begin
        activity.stopAnimating();
        aSender.enabled := true;

        if aSuccess then begin
          NSLog('logged in as %@', username.text);

          // 61372: Nougat: Weird block crash in Browse500
          // workaround for block issue in Preferences
          if UIDevice.currentDevice.userInterfaceIdiom = UIUserInterfaceIdiom.UIUserInterfaceIdiomPhone then begin
            dismissViewControllerAnimated(true) completion(nil);
            if assigned(loginSuccessfulCallback) then loginSuccessfulCallback();
            exit;
          end;
          // end workaround

          if assigned(dismissCallback) then dismissCallback(method begin 
              //var b: strong block := loginSuccessfulCallback;
              //if assigned(b) then b();
              if assigned(loginSuccessfulCallback) then loginSuccessfulCallback();
            end);
        end
        else begin
          loginFailed.hidden := false;
        end;
      end);

  end;
end;

method LoginViewController.cancel(aSender: id);
begin
  // 61372: Nougat: Weird block crash in Browse500
  // workaround for block issue in Preferences
  if UIDevice.currentDevice.userInterfaceIdiom = UIUserInterfaceIdiom.UIUserInterfaceIdiomPhone then begin
    dismissViewControllerAnimated(true) completion(nil);
    exit;
  end;
  // end workaround

  if assigned(dismissCallback) then dismissCallback(nil); 
end;

end.
