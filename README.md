# Two-Factor Authentication with Ruby and Sinatra

This example application demonstrates how to use Authy as the two-factor authentication provider using [Authy](https://www.authy.com/) and [Sinatra](http://www.sinatrarb.com/).

[![Build Status](https://travis-ci.org/TwilioDevEd/authy2fa-sinatra.svg?branch=master)](https://travis-ci.org/TwilioDevEd/authy2fa-sinatra)

## Local Development


1. First clone this repository and `cd` into it

   ```bash
   $ git clone git@github.com:TwilioDevEd/authy2fa-sinatra.git
   $ cd authy2fa-sinatra
   ```

1. Install the dependencies

   ```
   bundle
   ```

1. Export the environment variables

   ```
   export AUTHY_API_KEY=YOUR_AUTHY_API_KEY
   ```

1. Create the database

   ```bash
   $ bundle exec rake db:create
   ```

   _The application uses PostgreSQL as the persistence layer. If you
   don't have it already, you should install it. The easiest way is by
   using [Postgres.app](http://postgresapp.com/)._

1. Make sure the tests succeed

   ```
   $ bundle exec rake
   ```

1. Run the application

   ```bash
   $ bundle exec rackup
   ```

1. To enable Authy OneTouch to use the callback endpoint you exposed, your development server will need to be publicly accessible. [We recommend using ngrok to solve this problem](//www.twilio.com/blog/2015/09/6-awesome-reasons-to-use-ngrok-when-testing-webhooks.html).

   ```bash
   $ ngrok http 9292
   ```

1. Go to your Authy Dashboard and register the callback endpoint under _Settings_. Your endpoint will look like `http://[your-subdomain].ngrok.io/authy/callback`.

1. Check it out at http://[your-subdomain].ngrok.io

That's it!

## Meta

* No warranty expressed or implied. Software is as is. Diggity.
* [MIT License](http://www.opensource.org/licenses/mit-license.html)
* Lovingly crafted by Twilio Developer Education.
