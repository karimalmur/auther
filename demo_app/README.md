# README

# Auther

[![Gem Version](https://badge.fury.io/rb/devise_token_auth.svg)](http://badge.fury.io/rb/devise_token_auth)
[![Build Status](https://travis-ci.org/lynndylanhurley/devise_token_auth.svg?branch=master)](https://travis-ci.org/lynndylanhurley/devise_token_auth)
[![Code Climate](https://codeclimate.com/github/lynndylanhurley/devise_token_auth/badges/gpa.svg)](https://codeclimate.com/github/lynndylanhurley/devise_token_auth)
[![Test Coverage](https://codeclimate.com/github/lynndylanhurley/devise_token_auth/badges/coverage.svg)](https://codeclimate.com/github/lynndylanhurley/devise_token_auth/coverage)

Simple, multi-client and secure token-based authentication for Rails.

If you're building SPA or a mobile app, and you want authentication, you need tokens, not cookies.
This gem refreshes the tokens on each request, and expires them in a short time, so the app is secure.
Also, it maintains a session for each client/device, so you can have as many sessions as you want.

## Main features

* Seamless integration with:
  * [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) for [AngularJS](https://github.com/angular/angular.js)
  * [Angular-Token](https://github.com/neroniaky/angular-token) for [Angular](https://github.com/angular/angular)
  * [redux-token-auth](https://github.com/kylecorbelli/redux-token-auth) for [React with Redux](https://github.com/reactjs/react-redux)
  * [jToker](https://github.com/lynndylanhurley/j-toker) for [jQuery](https://jquery.com/)
* Oauth2 authentication using [OmniAuth](https://github.com/intridea/omniauth).
* Email authentication using [Devise](https://github.com/plataformatec/devise), including:
  * User registration, update and deletion
  * Login and logout
  * Password reset, account confirmation
* Support for [multiple user models](./docs/usage/multiple_models.md).
* It is [secure](docs/security.md).

This project leverages the following gems:

* [Devise](https://github.com/plataformatec/devise)
* [OmniAuth](https://github.com/intridea/omniauth)

## Installation

Add the following to your `Gemfile`:

~~~ruby
gem 'devise_token_auth'
~~~

Then install the gem using bundle:

~~~bash
bundle install
~~~

## [Docs](https://devise-token-auth.gitbook.io/devise-token-auth)

## Need help?

Please use [StackOverflow](https://stackoverflow.com/questions/tagged/devise-token-auth) for help requests and how-to questions.

Please open GitHub issues for bugs and enhancements only, not general help requests. Please search previous issues (and Google and StackOverflow) before creating a new issue.

Please read the [issue template](https://github.com/lynndylanhurley/devise_token_auth/blob/master/.github/ISSUE_TEMPLATE.md) before posting issues.

## [FAQ](docs/faq.md)

## Contributors wanted!

See our [Contribution Guidelines](https://github.com/lynndylanhurley/devise_token_auth/blob/master/.github/CONTRIBUTING.md). Feel free to submit pull requests, review pull requests, or review open issues. If you'd like to get in contact, [Zach Feldman](https://github.com/zachfeldman) has been wrangling this effort, you can reach him with his name @gmail. Further discussion of this in [this issue](https://github.com/lynndylanhurley/devise_token_auth/issues/969).

## Live Demos

[Here is a demo](http://ng-token-auth-demo.herokuapp.com/) of this app running with the [ng-token-auth](https://github.com/lynndylanhurley/ng-token-auth) module and [AngularJS](https://github.com/angular/angular.js).

[Here is a demo](https://stackblitz.com/github/neroniaky/angular-token) of this app running with the [Angular-Token](https://github.com/neroniaky/angular-token) service and [Angular](https://github.com/angular/angular).

[Here is a demo](https://j-toker-demo.herokuapp.com/) of this app using the [jToker](https://github.com/lynndylanhurley/j-toker) plugin and [React](http://facebook.github.io/react/).

The fully configured api used in these demos can be found [here](https://github.com/lynndylanhurley/devise_token_auth_demo).

## License
MIT
