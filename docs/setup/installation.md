## Download
You can download the latest release of Codeburner here: <a href="https://github.com/groupon/codeburner/releases" target="_blank">https://github.com/groupon/codeburner/releases</a>

The rest of this guide assumes you're inside the directory created by unpacking a release tarball or cloning the repository:

```bash
git clone https://github.com/groupon/codeburner
```

## Ruby
Codeburner was developed on Ruby 2.2, and is tested with/works fine on 2.3.  If you're using [RVM](http://rvm.io) or [rbenv](http://rbenv.org) we've provided a .ruby-version so you should be all set.  If you aren't using one of those, just make sure your local ruby version is at least 2.0+ before proceeding.


## Bundler
### Gem
First you'll need to install the bundler gem if you don't already have it:

```bash
gem install bundler
```

### Bundle Install
Once you have bundler, you can use it to install the local gems for Codeburner:

```bash
bundle install
```


***
