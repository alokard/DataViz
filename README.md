# DataViz

[![Swift Version][swift-image]](https://img.shields.io/badge/swift-4.0-orange.svg)
[![Build Status][https://img.shields.io/travis/alokard/DataViz/master.svg?style=flat-square]](https://travis-ci.org/alokard/DataViz)

This is a demo project of measurements data visualization that comes from network stream (EventSource).

## Prerequisites
In order to build Wire for iOS locally, it is necessary to install the following tools on the local machine
- macOS 10.11 or newer
- Xcode 9+ (https://itunes.apple.com/en/app/xcode/id497799835?mt=12)
- Bundler (http://bundler.io)

## How to build locally

1. Checkout this repository
2. From the checkout folder, run `bundle install` to install all required build and dependancy tools
3. Run `bundle exec pod install`
4. Open the workspace `DataViz.xcworkspace` in Xcode
5. Click the "Run" button in Xcode

## How to run tests

Just run `bundle exec fastlane test` from project root folder