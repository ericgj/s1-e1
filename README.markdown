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
    



