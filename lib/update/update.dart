// update.dart

import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter/material.dart';

void update(BuildContext context) async {
  print('Updating');
  try {
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.checkForUpdate().then((updateInfo) {
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Perform immediate update
          InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              // App Update successful
            }
          });
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Perform flexible update
          InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              // App Update successful
              InAppUpdate.completeFlexibleUpdate();
            }
          });
        }
      }
    });
  } on PlatformException catch (error) {
    // Check if the error is related to app ownership
    if (error.code == 'TASK_FAILURE' && error.message?.contains('ERROR_APP_NOT_OWNED') == true) {
      // Handle the specific error related to app ownership
      handleUpdateOwnershipError(context);
    } else {
      // Handle other PlatformExceptions
      handleUpdateError(error, context);
    }
  }
}

void handleUpdateOwnershipError(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Update Failed'),
        content: Text('The app update could not be completed because the current user does not own the app. To update the app, please visit the Play Store.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

void handleUpdateError(PlatformException error, BuildContext context) {
  if (error.code == 'TASK_FAILURE' && error.message?.contains('ERROR_APP_NOT_OWNED') == true) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Failed'),
          content: Text('The app update could not be completed because the current user does not own the app. To update the app, please visit the Play Store.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
