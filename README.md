# Asciidoctor External Callout

## Description

An [Asciidoctor](https://asciidoctor.org/) extension which adds support for callout tags added outside the listing block.

## Motivation

Aside from getting little practice around  Ruby and JavaScript, I decided to have a crack at this to help with a problem that comes up at work every so often.

The [callout mechanism](https://docs.asciidoctor.org/asciidoc/latest/verbatim/callouts/) for Asciidoc works extremely well in 99% of the cases I run into:

```asciidoc
[source,ruby]
----
require 'sinatra' #<1>

get '/hi' do #<2> #<3>
"Hello World!"
end
----
<1> Library import
<2> URL mapping
<3> Response block
```


Great, but it does mean you have to add commented to the tags to the source code to register the callout in the following block. As I've said, this is fine, 99% of the time, but I've run across a few occasions when adding tags to the source code (either in-line or an included file) can be a little problematic:

1. Restricted access to the source code: as a humble tech-writer, you might not have access to the included source code to add your own tags.
1. The source code has to remain runnable, but doesn't have a commenting mechanism that works well with Asciidoc (shell scripts amd json files spring to mind.)

## A possible Solution

And that's where this extension comes in: it adds support adding tags outside the source listing block, like this:

```asciidoc
[source,ruby]
----
require 'sinatra'

get '/hi' do
  "Hello World!"
end
----
. Library import @3
. URL mapping @5
. Response block @5
-----
```

Rather than tagging the code, you add a location token at the end of a list item, which will then add the tag at the specified line number. Run the source text through Asciidoctor+extension, and it'll spit the same source block complete with callouts.

Two types of location token are supported:

@_number_
: This format takes a numeric value indicating the line in the source block where the callout should appear. The callouts will appear at the end of the line. Multiple callouts on the same line will have a single space between them.


@/_text_/
: The text between the two slashes will be used in a regex search. A callout will be placed at the end of the first matching line.
If you have a large listing then it may be preferable to use the text search rather than counting all the lines. It may also be preferable to use a smaller listing, as a long listing might mean that your description is a bit too general. +
Using the text search method means that the location of the callout will move with the line; handy if you're referencing a source file that might get the occasional tweak outside your control.

@/_text_/g
: Works the same as the standard text search; the `g` flag means that callouts willl be added to _all_ the lines that match the search string, instead of just the first one.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'asciidoctor-external-callout'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install asciidoctor-external-callout

## Usage

To use the extension, you need to register it before calling one of the Asciidoc `convert` functions to render the output.

```ruby
require 'asciidoctor-external-callout'
require 'asciidoctor'

Asciidoctor.convert_file File.join(File.dirname(__FILE__), 'sample.adoc'), safe: :unsafe, backend: :html5
```

## Use with the [IntelliJ Asciidoc Plugin](https://plugins.jetbrains.com/plugin/7391-asciidoc)

If you're not using the excellent Asciidoc plugin then you're really missing out. 
One if it's lesser known features is that it supports Asciidoc extensions written in Ruby:

1. Create a new folder structure in the root of your IntelliJ project called `.asciidoctor/lib`.
2. Copy the file `asciidoctor-external-calllout.rb` from this distribution to `.asciidoctor/lib`.

Now, when you preview an Asciidoc file with the plugin enabled, external callouts will now show up in the preview.

## Formatting

By default, the callout extension will put a single space between callouts that occur on the same line. If you want to adjust this, then you need to create a style that puts a horizontal margin between the callouts:

```css
div.external-callout-block i.conum {
    margin-left: 10px;
    margin-right: 10px;
}
```
The callout attaches a class called `external-callout-block` to each source listing it processes. You can use this to differentiate between standard callouts, and callouts written by the extension.

The extension also adds a class called `external-callout-list` to the list of definitions at the bottom of the source block. (There's probably no need to adjust the styling for this.)

Then to convert a document with a stylesheet, use something like this:

```ruby
Asciidoctor.convert_file File.join(File.dirname(__FILE__), 'sample.adoc'), 
                         safe: :unsafe, backend: :html5,
                         attributes: {'stylesheet' => './callout.css'}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Asciidoctor::External::Callout project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/asciidoctor-external-callout/blob/master/CODE_OF_CONDUCT.md).
