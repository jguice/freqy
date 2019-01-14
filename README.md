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
Pass files to scan as arguments, or text via STDIN.  Run without any arguments to see help.

#### file arguments
```
./freqy.rb file1.txt file2.txt ...
```

#### STDIN
```
cat file1.txt | ./freqy.rb
```

**NOTE:** Beware of possible undesirable behavior using this method with very large files.

## Configuration
Configuration is in the code at the moment.  Likely elements to extract a file or environment-based config:
- "word" delimiters
- number of "words" in a phrase
- chunk size
- characters to ignore (remove)

## Documentation
Internal documentation can be generated by running the `yard` command and opening `index.html` in the generated `doc` dir. 

## Technologies
The following tools/technologies are used in this project.

### ruby
freqy is built and tested using ruby 2.5.1 but should run on most modern rubies.  The runtime environment is setup with 
[chruby](https://github.com/postmodern/chruby) which will [auto-switch](https://github.com/postmodern/chruby#auto-switching)
to the appropriate ruby version if configured (and installed).

### Bundler
[Bundler](https://bundler.io) manages dependencies for freqy.  The `Gemfile` describes the current project dependencies.

### RSpec
[RSpec](http://rspec.info) is the test framework used to validate freqy behavior/requirements.  Tests (specs) live in the `spec` dir and the `.rspec` file manages configuration.

### YARD
[YARD](https://yardoc.org) (Yay! A Ruby Documentation Tool) is responsible for generating internal/api docs from inline comments and tags.  It extends rdoc (though rdoc can still be used).  The `.yardopts` file controls its configuration.

### RuboCop
[RuboCop](https://github.com/rubocop-hq/rubocop) is used as a static code analyzer / linter.  In general files pass rubocop default checks with exceptions either captured in the `.rubocop.yml` file or via [inline disables](https://rubocop.readthedocs.io/en/latest/configuration/#disabling-cops-within-source-code).

## Development / Testing

### Dev Environment setup
Initial steps for setup of development environment (macOS).

#### install...

- [Homebrew](https://brew.sh)
- chruby: `brew install chruby`
- ruby-install: `brew install ruby-install`
- ruby-2.5.1: `ruby-install ruby-2.5.1`

**NOTE:** At this point you'll likely need to open a new terminal window for chruby auto-versioning to work.

- bundler:`gem install bundler`
- dependencies: `bundle install --binstubs`

#### running tests

To run project tests:
```
./bin/rspec
```

**NOTE:** Running rspec in this way will automatically use the correct bundler gem environment (it replaces `bundle exec`).

### Performance
The current implementation attempts to maximize performance while keeping the code relatively simple and short.  Ultimately a [benchmark](https://ruby-doc.org/stdlib-2.5.1/libdoc/benchmark/rdoc/Benchmark.html) should be conducted against some known input sets, and various implementations tested.

Current choices related to performance:
- lazy file evaluation (read on-demand instead of up-front)
- "chunking" of reads into batches (vs. character-at-a-time)
- precompiled regex for unwanted character "filtering"
- gsub specific unwanted characters with empty string (vs. a list of accepted chars)
- minimal intermediate storage (only ever storing phrase_size + 1 elements during frequency scan)

Some possible options for further improving the algorithm (individual thread):
- Using multiple `tr` instead of `gsub` to replace (remove) unwanted characters.
- Utilize a [StringScanner](http://ruby-doc.org/stdlib-2.5.3/libdoc/strscan/rdoc/StringScanner.html) on the input stream directly.
- Leverage native (compiled) code

### Extending
The `WordAnalyzer` class could be extended "upwards" by generalizing a parent class that could analyze the frequency of
things besides words (space character boundary in-betweens).

You'll also find a stub in AdaptiveWordAnalyzer for an adaptive chunking implementation (and some notes) illustrating how to 
plug in alternate implementations behind the WordAnalyzer interface.  See `cli.rb` for a commend example of passing a different analyzer class.

### Other Considerations

#### parallelizing
Further performance increasing options involve running multiple threads/processes and parallelizing the workload:
- break input into chunks at whitespace boundary
- could use single db like dynamo w/ n number of processor instances
- could also have separate data stores and recombine results (need to store more than top 100 from each though, in case cumulative amount is top-100 but individually not)

#### ordering
- ordering when multiple phrases tie for count will be in order of accumulation in text (which is scanned beginning to end in stream order)
- in the case of parallel processing, this would be more randomized (by completion time on particular nodes/processes)

#### documentation
- could use github pages and merge docs + doc (generated) but better to use a pipeline to build and publish docs on every commit

#### future enhancements
- extract strings for UI localization
- capture generic version for cli blueprint
  - it's a good template with lint, documentation, class hierarchy, option handling, verbose mode, etc.
- higher-level tests (integration, load, performance)
- JSON results (e.g. for web API integration)