//
//  ViewController.m
//  QuickstartApp
//
//  Created by Chris Lamb on 3/17/16.
//  Copyright © 2016 com.SantaCruzNewspaperTaxi. All rights reserved.
//
#import "ViewController.h"


/* Constants used for OAuth 2.0 authorization EXAMPLE from DrEditFiles code
static NSString *const kKeychainItemName = @"iOSDriveSample: Google Drive";
static NSString *const kClientId = @"853135828925-8t9bfsueorssgrv9jtqka6gq0o8vb4vr.apps.googleusercontent.com";
static NSString *const kClientSecret = @"F2CVzLCS5PQj2T4JazioSL8-";
*/

static NSString *const kKeychainItemName = @"Google Apps Script Execution API";
static NSString *const kClientID = @"756894447473-0ho4dumd7rgi646hstkvc8p3octk0pqo.apps.googleusercontent.com";  //YOUR_CLIENT_ID_HERE
static NSString *const kScriptID = @"Mir2lNxwUvDuYxMtwHhqWu00vNRSAENjV"; //ENTER_YOUR_SCRIPT_ID_HERE
@implementation ViewController

@synthesize service = _service;
@synthesize output = _output;

// When the view loads, create necessary subviews, and initialize the Google Apps Script Execution API service.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a UITextView to display output.
    self.output = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.output.editable = false;
    self.output.contentInset = UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0);
    self.output.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.output];
    
    // Initialize the Google Apps Script Execution API service & load existing credentials from the keychain if available.
    self.service = [[GTLService alloc] init];
    self.service.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:nil];
}

// When the view appears, ensure that the Google Apps Script Execution API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    
    GTMOAuth2Authentication *auth =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:kScriptID];
//    if (!self.service.authorizer.canAuthorize) {  //ORIGINAL if statement

    if (![auth canAuthorize]) {     //from DrEditFilesList auth
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
        
    } else {
        [self callAppsScript];
    }
}

// Calls an Apps Script function to list the folders in the user's
// root Drive folder.
- (void)callAppsScript {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://script.googleapis.com/v1/scripts/%@:run",
                                       kScriptID]];
    // Create an execution request object.
    GTLObject *request = [[GTLObject alloc] init];
    [request setJSONValue:@"getFoldersUnderRoot" forKey:@"function"];
    
    // Make the API request.
    [self.service fetchObjectByInsertingObject:request
                                        forURL:url
                                      delegate:self
                             didFinishSelector:@selector(displayFoldersWithServiceTicket:finishedWithObject:error:)];
}

// Displays the retrieved folders returned by the Apps Script function.
- (void)displayFoldersWithServiceTicket:(GTLServiceTicket *)ticket
                     finishedWithObject:(GTLObject *)object
                                  error:(NSError *)error {
    if (error == nil) {
        NSMutableString *output = [[NSMutableString alloc] init];
        if ([object.JSON objectForKey:@"error"] != nil) {
            // The API executed, but the script returned an error.
            
            // Extract the first (and only) set of error details and cast as a
            // NSDictionary. The values of this dictionary are the script's
            // 'errorMessage' and 'errorType', and an array of stack trace
            // elements (which also need to be cast as NSDictionaries).
            NSDictionary *err =
            [[object.JSON objectForKey:@"error"] objectForKey:@"details"][0];
            [output appendFormat:@"Script error message: %@\n",
             [err objectForKey:@"errorMessage"]];
            
            if ([err objectForKey:@"scriptStackTraceElements"]) {
                // There may not be a stacktrace if the script didn't start
                // executing.
                [output appendString:@"Script error stacktrace:\n"];
                for (NSDictionary *trace in [err objectForKey:@"scriptStackTraceElements"]) {
                    [output appendFormat:@"\t%@: %@\n",
                     [trace objectForKey:@"function"],
                     [trace objectForKey:@"lineNumber"]];
                }
            }
            
        } else {
            // The result provided by the API needs to be cast into the correct
            // type, based upon what types the Apps Script function returns.
            // Here, the function returns an Apps Script Object with String keys
            // and values, so must be cast into a NSDictionary (folderSet).
            NSDictionary *folderSet =
            [[object.JSON objectForKey:@"response"] objectForKey:@"result"];
            if (folderSet == nil) {
                [output appendString:@"No folders returned!\n"];
            } else {
                [output appendString:@"Folders under your root folder:\n"];
                for (id folderId in folderSet) {
                    [output appendFormat:@"\t%@ (%@)\n",
                     [folderSet objectForKey:folderId],
                     folderId];
                }
            }
        }
        self.output.text = output;
    } else {
        // The API encountered a problem before the script started executing.
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendFormat:@"The API returned an error: %@\n",
         error.localizedDescription];
        [self showAlert:@"Error" message:message];
    }
}

// Creates the auth controller for authorizing access to Google Apps Script Execution API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    NSArray *scopes = [NSArray arrayWithObjects:@"https://www.googleapis.com/auth/drive", nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kClientID
                      clientSecret:nil
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and update the Google Apps Script Execution API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:message
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];
}

@end