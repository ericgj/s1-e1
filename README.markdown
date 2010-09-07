## Description

This is a 'reply' type twitter bot that answers certain questions about a YourMailingListProvider account.  (YourMailingListProvider.com is a bulk emailer for newsletters etc. similar in concept to Constant Contact, but a little simpler to use.  It has a basic API, auth is not complicated at all).

The first question I want to ask, to start simply, is: _has this email address unsubscribed from my list?_

The syntax of the commands and design of this bot are such that it makes it easy to develop other question types against YMLP, and even against other services.

## Interface mechanism

Commands are sent to the bot as public 'reply' messages.  Results are returned to the sending twitter account as direct messages.  The test bot account is `@ericgj_rmu`.

## Syntax

    @ericgj_rmu ymlp cntc.unsub? peewee@gmail.com
    
That is, a space delimited list of:

1. the Twitter app account
2. the service name (in this case 'ymlp')
3. the 'command' which is a service specific abbreviation (in this case, for the question type I am developing, _has this email address unsubscribed_)
4. any 'parameters' to the command (in this case, the email address)

## Return message format

    peewee@gmail.com : yes
    #ymlp cntc.unsub?
    

## How to use it

Run the app from the command line like:

    ruby lib/em_twitter_bot.rb
    
The first time it runs it will ask you for Twitter and YMLP authorization info, which it saves in ~/.twitter and ~/.ymlp respectively.

For Twitter, the details are:

    username: "ericgj_rmu"
    password: "rmu4evr!"
    token:   "27oxFs7i5wJwMyWqXf2Dw"
    secret:  "VUBR3iB1YAn5Bi5CxSY6gnmEqlerwddMVgviP8HCI"
    atoken:  "186283225-S4e26wfRWggzr9CSZlWGVKHRFZBvZPEKaF63M1HX"
    asecret: "o4Yiz57j6nuaVFTnzKwu3kUHfXLMRRGRDBX35ZQO4hc"

Note I'm giving the access token/secret just to avoid oauth headaches, in reality you shouldn't need them as the config walks you through getting an access token if it's not already saved.  You _do_ need the basic auth username/password right now since I can't get oauth to work with the Streaming API, not sure if it's my error or Twitter's.

For YMLP, the details are:

    username: ericgj_rmu
    key: NNGAEPGKUKG2GNHWWJPK

Note that this dummy YMLP account has exactly one subscriber email (ericgj72@yahoo.com) and one that unsubscribed (ericgj72@gmail.com).

So the following command:

    @ericgj_rmu ymlp cntc.unsub? ericgj72@gmail.com
    
Should return a direct message:

    ericgj72@gmail.com : yes
    #ymlp cntc.unsub?
    
And this command:

    @ericgj_rmu ymlp cntc.unsub? ericgj72@yahoo.com
    
Should return this direct message:

    ericgj72@yahoo.com : no
    #ymlp cntc.unsub?


## What didn't get done

I was unable to test this latest version (as of 2:20 PM EST) due to Twitter being blocked at my job (!)... so likely there are still a few bugs in it I won't get to work on until later.  So, not 100% finished, but a good 95% of the way I think.

Also I regret not developing from tests/specs, but was intimidated by the challenge of testing in an asynchronous environment.  I have some ideas for the way to go with this in the future though, and looking at what other folks did will no doubt be helpful.

