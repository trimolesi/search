## Search

Simple project using nokogiri and mechanize to get results from **Google** and **Bing**.

## Code style

[![js-standard-style](https://img.shields.io/badge/code%20style-standard-brightgreen.svg?style=flat)](https://github.com/feross/standard)

## Gems used on project

Ruby on Rails, Nokogiri, Mechanize, Rspec, Webmock

## Features

- Get results from Google or Bing or both and return results in json.

## Installation

Ruby 3\
Bundler\
Rails 6\
Run `bundle install` to install dependencies.

## Tests

Run specs with:\
**bundle exec rspec**\
It will tests: model, controller and services(Google and Bing)

## How to use?

Run rails server: `rails s` open the
url [http://localhost:3000/search/engine/query](http://localhost:3000/search/engine/query) where engine could be
(**google**, **bing** or **both**)
and query is what you want search

To enable **cache** in development run `rails dev:cache`

Documentation for API is available on [localhost:3000/apiepie](localhost:3000/apiepie)

## License

MIT © [Thiago Imolesi]()