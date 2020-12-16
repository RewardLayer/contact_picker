// Copyright 2017 Michael Goderbauer. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ContactPickerPlugin.h"
@import ContactsUI;

@interface ContactPickerPlugin ()<CNContactPickerDelegate>
@end

@implementation ContactPickerPlugin {
  FlutterResult _result;
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

    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    contactPicker.delegate = self;
    contactPicker.displayedPropertyKeys = @[ CNContactEmailAddressesKey ];

    UIViewController *viewController =
        [UIApplication sharedApplication].delegate.window.rootViewController;
    [viewController presentViewController:contactPicker animated:YES completion:nil];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)contactPicker:(CNContactPickerViewController *)picker
    didSelectContactProperty:(CNContactProperty *)contactProperty {

  NSDictionary *emailAddress = [NSDictionary
      dictionaryWithObjectsAndKeys:contactProperty.value, @"email",
                                   [CNLabeledValue localizedStringForLabel:contactProperty.label],
                                   @"label", nil];
    NSLog(@"%@", emailAddress);
  _result([NSDictionary
      dictionaryWithObjectsAndKeys:contactProperty.contact.givenName, @"givenName", contactProperty.contact.familyName, "familyName", emailAddress, @"emailAddress", nil]);
  _result = nil;
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
  _result(nil);
  _result = nil;
    [picker dismissViewControllerAnimated:true completion:nil];
}

@end
