
Thes are some swift command line apps I use to hack on my roto baseball league.

No warranty or claim of usability what-so-ever. This represents work I did in my free time for my own enjoyment. It is not intended to represent production quality work. That said, here are the apps:


### ESPNScrape

Aborted attempt to log in to my ESPN site and scrape data. Not much interesting here.

### LeagueRostersScrape

* Scrape league roster data from a copied-and-saved text file from a **Rosters** page from an ESPN league.
* Imports projected auction values for hitters and pitchers from a csv
* Correlates the roster players with their auction and prints out a primitive power ranking.

See sample directory for expected formats. Downloadable and especially ESPN formats are likely to change in the future. They were last known to work March, 2019.

### PlayerRelativeValues
Scrapes a csv of team rosters and compares them to csv's of project Fangraphs auction values

### TeamRelativeValues

An attempt to calculate rotisserie auction values from a csv of projections.



You need to have Swift installed on your machine to run this. Most people do this by downloading Xcode and installing the command line tools. Consult google for more directions.

#### How do I compile the apps?
_swift build_

#### How do I run one of the apps?
* Change the filename variables in the swift app to point to something on your local machine
* _.build/debug/TeamRelativeValues_ to run a file from your working directory

To build and run an app in one command

_swift build && .build/debug/PlayerRelativeValues_

Run unit tests (not there are many... shame on me)

_swift test_


### How can I hack on this?

Go ahead. You can edit the files in your text editor of choice. If you use Xcode and add new files, you'll need to have swift update the xcodeproj 

_swift package generate-xcodeproj_

Note: this isn't needed for other editors than don't use the xcodeproj.


### What is aiai?

Something that should be cleaned up. If something like that was committed to a production repository I'd feel ashamed, but this is not one of those...




