// Copyright 2017 Michael Goderbauer. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ContactPickerPlugin.h"
@import ContactsUI;

@interface ContactPickerPlugin ()<CNContactPickerDelegate>
@end

@implementation ContactPickerPlugin {
    FlutterResult _result;
    CNContactPickerViewController *contactPicker;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"contact_picker"
                                  binaryMessenger:[registrar messenger]];
  ContactPickerPlugin *instance = [[ContactPickerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"selectContact" isEqualToString:call.method]) {
    if (_result) {
      _result([FlutterError errorWithCode:@"multiple_requests"
                                  message:@"Cancelled by a second request."
                                  details:nil]);
      _result = nil;
    }
    _result = result;

      if (@available(iOS 9.0, *)) {
          contactPicker = [[CNContactPickerViewController alloc] init];
      } else {
      }
    contactPicker.delegate = self;
      if (@available(iOS 9.0, *)) {
          contactPicker.displayedPropertyKeys = @[ CNContactEmailAddressesKey ];
      } else {
      }

    UIViewController *viewController =
        [UIApplication sharedApplication].delegate.window.rootViewController;
    [viewController presentViewController:contactPicker animated:YES completion:nil];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)contactPicker:(CNContactPickerViewController *)picker
didSelectContactProperty:(CNContactProperty *)contactProperty  API_AVAILABLE(ios(9.0)){

  NSDictionary *emailAddress = [NSDictionary
      dictionaryWithObjectsAndKeys:contactProperty.value, @"email",
                                   [CNLabeledValue localizedStringForLabel:contactProperty.label],
                                   @"label", nil];
    if(emailAddress != NULL) {
        _result([NSDictionary
            dictionaryWithObjectsAndKeys:contactProperty.contact.givenName, @"givenName", contactProperty.contact.familyName, @"familyName", emailAddress, @"emailAddress", nil]);
        _result = nil;
    } else {
        _result(nil);
        _result = nil;
    }

}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker  API_AVAILABLE(ios(9.0)){
  _result(nil);
  _result = nil;
}

@end
