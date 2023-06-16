# fetch_tray_hooks

Extends [fetch_tray](https://github.com/marqably/fetch_tray) with support for [flutter_hooks](https://pub.dev/packages/flutter_hooks).

## ⚠ Warning: Still a work in progress

Although we use fetch tray in production already, the docs and some of the features are still in development!
We appreciate any support and PRs.

## Getting started

Start by adding the package to your `pubspec.yaml`:

```yaml
dependencies:
  fetch_tray_hooks:
```

Run pub get to install dependencies:

```bash
flutter pub get
```

## How it works

### Overview

Checkout [fetch_tray](https://github.com/marqably/fetch_tray) to get an overview of how the package works in general.
This package just adds an additional layer in between your widgets and `fetch_tray` to use hooks.

### Real life example

Let's assume we have a user overview (list of users) and a user detail page.
Each `user` has the following attributes:

* id
* email
* name

### Creating the model

The first thing we need to do, to have nice output types is define the output type (we call it  `Model`):

Let's create a `user.dart` file with the following class.

```dart
/// user.dart
class User {
  final int id;
  final String email;
  final String? name;
  final DateTime? signupDate;

  // we need to define a constructor, that let's fetch_tray create the model easily
  const User({
    required this.id,
    required this.email,
    this.name,
    this.signupDate,
  });

  // and every model needs the `fromJson` method, to make sure we can parse the API json output
  // and create an instance of this model class out of it
  // this is also the place, where you could make transformations between your API and flutter
  // (think like datetime conversions, ...)
  factory User.fromJson(Map<String, dynamic> json) {
    return MockUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      signupDate: DateTime.parse(json['signupDate']),
    );
  }
}
```

## Creating the base requests

Check out the docs under [fetch_tray](https://github.com/marqably/fetch_tray) on how to prepare the basic requests.
If that is done, you can use these requests to create the following hooks below.

### Add hooks to your requests

### `useMakeTrayRequest` hook

Use the `useMakeTrayRequest` hook, is very similar to `makeTrayRequest`, but a hook version:

```dart
// user_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:fetch_tray/fetch_tray.dart';

// import the request and model
import './fetch_user_request.dart';
import './user.dart';


class UserDetailScreen extends HookWidget {
  const UserDetailScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  static int userId;

  @override
  Widget build(BuildContext context) {
    // initialize the `FetchUserRequest` with the specific configuration you need in this case
    // the content of params or userId could also be a variable passed in this place.
    final fetchUserRequest = FetchUserRequest(
      userId: userId, // here we use the userid passed to the widget
      params: {
        'active': 'true',
      },
    );

    // now make the request (also pass the `User` model to the method, to make sure we have strict type safety)
    final userResponse = await useMakeTrayRequest<User>(fetchUserRequest);

    // if in loading state
    if (userResponse.loading) {
      return ActivityIndicator();
    }

    // if all the data is here -> use it
    return Text(userResponse.user?.name);
  }
}
```

### Creating a custom hook

If you have created a request, it is very easy to trigger it using the `useMakeTrayRequest` hook.
But we like clean and abstracted, so let's go one step further and create a custom hook for our requests.
This makes it even easier to use our requests and abstracts some of the typings and potential changes away.

It also allows us to create a unique and very developer friendly signature, of what input params are needed, required, ... .

Our hook will be very small, because it only calls the `useMakeTrayRequest` hook with the correct types under the hood.

```dart
// hooks/use_fetch_user_request.dart

import 'package:fetch_tray/fetch_tray.dart';
import '../requests/fetch_user_request.dart';

/// the request hook to fetch a single cause detail page
TrayRequestHookResponse<User> useFetchUserRequest<User>(
  int userId, {
  TrayRequestMock? mock,
}) {
  final fetchResult = useMakeTrayRequest<User>(
    FetchUserRequest(
      userId: userId,
    ),
    mock: mock,
  );

  return fetchResult;
}
```

## TrayEnvironments

The approach we used above pretty well, but the reason we use this library for is to reduce implementing logic over and over again.

Defining the full `api` url, headers, ... in every request works ok, if we only have a few requests and don't mind changing the baseUrl to often.

In most cases this is not viable though and we want to define these "almost static" parts of every request in one central location.

This is where `TrayEnvironments` come in.

They are basically nothing more than the basic configuration of every request.
In fact, by creating your `FetchUserRequest` above you extended the `TrayRequest` class, which creates a default `TrayEnvironment`.

## Advanced topics

### Hooks

// TODO: add details about hooks like the `afterSuccess` hook

### Fetch more and pagination

See more in the [pagination section](./doc/advanced/pagination.md)

## Breaking changes not in README

// TODO: Change requests to include RequestType instead of only ResponseType definition

### Testing your models, requests, hooks

FetchTray is fully testable and makes it very easy to set everything up.
[How to test](./doc/advanced/testing.md)

## Contributing

We are looking forward to contributions, bugfixes, documentation improvements, ... for this package.
Please provide descriptive information in your pull requests and make sure to write tests and respect and address linting problem before you do so.

We will review and merge PRs.

## TODO

* [] add docs for `lazyRun` parameter and post hooks
* [] prepare example folder with full example
