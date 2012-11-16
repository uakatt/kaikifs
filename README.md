KaikiFS
=======

Introduction
------------

KaikiFS contains cucumber scenarios and steps that use the `KaikiFS::WebDriver` (a thick wrapper
for `Selenium::WebDriver`) to test KFS with Selenium.

(In the capybara branch, we are moving towards using Capybara. Thus `KaikiFS::CapybaraDriver` is a wrapper around `Capybara`.)

Compatibility
-------------

KaikiFS is tested on the following platforms:

* **ruby-1.9.3** on **Linux**

That is all.

Current Capabilities
--------------------

* dot
* dot
* dot

Roadmap
-------

* Capybara
* dot
* dot

Installation
------------

This is not a gem yet. So... just clone this repository for now.

Contributing
------------

Please do! Contributing is easy in KaikiFS. Please read the CONTRIBUTING.md document for more info. ... When that file exists.

Usage
-----

For now, this is incredibly specific to (a) UA, and (b) my laptop and our Jenkins box. Here are some files that you will need to create:

### `shared_passwords.yaml`

At UA, we have a lot of test users with a shared password, and the user names have a shared prefix. So let's say your institution works the same way, and your test users are test-user1, test-user2, test-user3, etc. And let's say they all share the password "some-password". Then you can take advantage of shared passwords by writing the following `shared_passwords.yaml`:

```yaml
---
test-user: some-password
```

Then you can `export KAIKI_NETID=test-user1` and that user will be used as the original log in. (See ff-13.0.1_env)

### `config/accounts.yaml`

There are a few steps in `features/step_definitions/login_steps.rb` that take advantage of configure files, where you can specify various roles. As an example, if you fill out `config/accounts.yaml` to look like:

```yaml
---
1089999:
  account_number: 1089999
  account_name: SIERRA CAMPUS
  fiscal_officer: jdoe
```

Then you can use a step in a scenario like so:

```gherkin
When I backdoor as the fiscal officer
```

You can also specify global roles in `config/arizona_teams.yaml` (or rename, and rename in the code):

```yaml
---
ua_fso_fm_team_451:
  name: ua_fso_fm_team_451
  user: test-user2
```

And use:

```gherkin
When I backdoor as the UA FSO FM Team 451
```

### Other Requirements

* `bundle install` should install all requirements.
* I think it's pretty hardcoded that we use CAS.
* Look at `features/support/env.rb` for various environment variables that can be used.
* `envs.json` is a way to store environment names and use them in tests. I think a lot of this is hardcoded Arizona stuff...
* On linux (or mac?), the xvfb package allows the Headless gem to do its thing.
* Look at `ff-13.0.1_env` for examples of how I set up my environment to be headless.

Big section. Lots more to write.

Versioning
----------

KaikiFS follows [Semantic Versioning](http://semver.org/) (at least approximately) version 2.0.0-rc1.

License
-------

Please see [LICENSE.md](LICENSE.md)

