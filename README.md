# freqy

Freqy (freaky) is a word or phrase frequency analyzer.  It reads an input text file and identifies the top N words or 
multi-word sequences.  It is designed to be efficient on large files and can potentially be parallelized to further
improve performance.

## Quickstart
Assuming you have a modern ruby interpreter and bundler installed... (see [Technologies](#technologies) below for details).

### Clone the repo
```
git clone https://github.com/jguice/freqy.git
```
(or use your favorite git client)

### Install dependencies
```
bundle install
```

### Run the app
Pass files to scan as arguments, or text via STDIN.

#### file arguments
```
./freqy.rb file1.txt file2.txt ...
```

#### STDIN
```
cat file1.txt | ./freqy.rb
```

**NOTE:** Beware of possible undesirable behavior using this method with large files.

## Configuration


## Technologies

### ruby
freqy is built and tested using ruby 2.5.1 but should run on most modern rubies.  The runtime environment is setup with 
[chruby](https://github.com/postmodern/chruby) which will [auto-switch](https://github.com/postmodern/chruby#auto-switching)
to the appropriate ruby version if configured (and installed).

### Bundler
[Bundler](https://bundler.io) manages dependencies for freqy.

### RSpec
[RSpec](http://rspec.info) is the test framework used to validate freqy behavior/requirements.

## Development / Testing

### dev environment setup
Initial steps for setup of development environment (macOS):

#### Install...

- [Homebrew](https://brew.sh)
- chruby: `brew install chruby`
- ruby-install: `brew install ruby-install`
- ruby-2.5.1: `ruby-install ruby-2.5.1`

**NOTE:** At this point you'll likely need to open a new terminal window for chruby auto-versioning to work.

- bundler:`gem install bundler`
- dependencies: `bundle install`

#### Running Tests