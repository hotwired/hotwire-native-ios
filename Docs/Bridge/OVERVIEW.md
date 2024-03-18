# Overview
Strada iOS is a native adapter for your [Strada](https://strada.hotwired.dev)-enabled web app. It allows you to build native components driven by web-based components that exist in `WKWebView`. It's built entirely using standard iOS tools and conventions.

This library has been in use and tested in the wild since June 2020 in the [HEY iOS](https://apps.apple.com/lt/app/hey-email/id1506603805) app.

To understand how Strada works at a high level and see examples of web components working together with native components, see the [online handbook](https://strada.hotwired.dev/handbook/introduction).

## Structure of Your App
Strada iOS will work with any `WKWebView`-based iOS app, but we only provide instructions for integrating with [turbo-ios](https://github.com/hotwired/turbo-ios) apps. As part of the [Hotwire](https://hotwired.dev/) family, `strada-ios` works seamlessly with your Turbo-powered hybrid apps.

We'll walk you through integrating `strada-ios` into your app in the [Quick Start Guide](QUICK-START.md) instructions.
