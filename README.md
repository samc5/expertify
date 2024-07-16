
# Expertify (to be changed)
Expertify is an RSS Reader that I have been building from scratch starting in January 2024, with a Flutter frontend and a Flask backend, with a GraphQL API doing most of the connecting between them. It uses the `feedparser` Python library to scrape and parse RSS Feeds, and the `flutter_widget_from_html` Flutter package to render the HTML of the feeds in Flutter. It is ultimately meant to be a free alternative to the freemium feed readers that populate the current RSS market.

As an RSS reader, Expertify allows users to combine feeds from various news sources and blogs into one inbox (or multiple)

Currently a demo of the app is in hosted at https://expertify.samcowan.net/


## Features

- Curate an inbox by building categories of feeds you like
- Add feeds to the crowdsourced database of feeds
- Save articles/posts you like and read them any time
- Search for feeds you're interested in and discover what others are reading



## Built With

**Frontend**: Flutter  
**API**: GraphQL  
**Backend**: Flask  
**Database**: MongoDB Atlas  
**Core Python Libraries**: Feedparser  
**Core Flutter Packages**: flutter_widget_from_html, graphql_flutter, flutter_secure_storage  
**Hosted on**: Azure  

## Updating/Cloudflare Notes

Cloudflare and other hosts and websites are particularly strict about bot policies, and by default block any traffic coming from Azure VMs like the one this app is hosted on. Due to this, I am currently updating the feeds locally using a systemd daemon as follows.

```
Description=RSS Feed Updater
After=network.target

[Service]
ExecStart=/bin/bash -c 'source /PATH/TO/VENV/bin/activate && exec python3 /PATH/TO/PROJECT_ROOT/api/rss/server.py'
Restart=always
User=<MyUSER>
WorkingDirectory=/PATH/TO/PROJECT_ROOT/api/rss/
Environment="PATH=/PATH/TO/VENV/bin"

[Install]
WantedBy=multi-user.target
```

However, this solution is not ideal. The process only runs when my personal laptop is turned on, and even then is not consistent (for reasons I'm not quite sure). So as of now the feeds update only sporadically, often at my manual restart of the daemon.

Eventually, I plan to try to register Expertify on Cloudflare's list of verified bots, which should fix the problem for a number of sites. Building my own scraper as part of this process will also help.


## RSS Explainer

If you aren't a complete nerd and/or were born after 1980, you may need an explanation of what RSS is and why it's so useful.

[This link](https://zapier.com/blog/how-to-use-rss-feeds/) helped me when I first stumbled upon RSS