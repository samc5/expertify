import feedparser
import mongo
ACX = "https://www.astralcodexten.com/feed/"
FT = "https://www.ft.com/myft/following/15b4e217-cc5c-47a8-8234-8f5cf596769c.rss"
MLBTR = "http://feeds.feedburner.com/MlbTradeRumors"
NYT = "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"

Substacks = ["https://www.awritersnotebook.org/feed", "https://yearofwritingdangerously.substack.com/feed", "https://news.manifold.markets/feed", "https://theadvancescout.substack.com/feed", "https://www.aisnakeoil.com/feed", "https://ryanjakubowski.substack.com/feed", "https://aquaimperium.substack.com/feed", "https://www.astralcodexten.com/feed", "https://www.briefingbook.info/feed", "https://poulos.substack.com/feed", "https://channelsofinfluence.substack.com/feed", "https://www.counteroffensive.news/feed", "https://cupofcoffee.substack.com/feed", "https://dhaaruni.substack.com/feed", "https://www.distilled.earth/feed", "https://danieldrezner.substack.com/feed", "https://theeggandtherock.com/feed", "https://gelliottmorris.substack.com/feed", "https://www.experimental-history.com/feed", "https://mileskellerman.substack.com/feed", "https://forklightning.substack.com/feed", "https://www.forkingpaths.co/feed", "https://herdingcatsnj.substack.com/feed", "https://hypertextjournal.substack.com/feed", "https://insidemedicine.substack.com/feed", "https://www.theinternationalcorrespondent.com/feed", "https://joeblogs.joeposnanski.com/feed", "https://www.jonstokes.com/feed", "https://www.liberalpatriot.com/feed", "https://mollyknight.substack.com/feed", "https://pmarca.substack.com/feed", "https://garymarcus.substack.com/feed", "https://jonathanstea.substack.com/feed", "https://www.mod171.com/feed", "https://www.noahpinion.blog/feed", "https://www.numlock.com/feed", "https://ryanmcbeth.substack.com/feed", "https://www.nycsouthpaw.com/feed", "https://www.persuasion.community/feed", "https://politickingetc.substack.com/feed", "https://popular.info/feed", "https://populism.substack.com/feed", "https://www.programmablemutter.com/feed", "https://www.readoptional.com/feed", "https://www.natesilver.net/feed", "https://www.slowboring.com/feed", "https://stevelichtenstein.substack.com/feed", "https://superbowl.substack.com/feed", "https://www.sustainabilitybynumbers.com/feed", "https://snyder.substack.com/feed", "https://daniellekurtzleben.substack.com/feed", "https://transmissionsfromtheredplanet.substack.com/feed", "https://smotus.substack.com/feed", "https://radleybalko.substack.com/feed", "https://williamfleitch.substack.com/feed", "https://wordswithyenhan.substack.com/feed"]
non_substacks = ["https://acoup.blog/feed", "https://crookedtimber.org/feed/", "http://feeds.feedburner.com/MLBTRTransactions", "https://statmodeling.stat.columbia.edu/feed/", "https://kill-the-newsletter.com/feeds/lt36fwdlv0f0bnbj.xml", "https://stratechery.passport.online/feed/rss/AXqhHmNvk3poy5AdFVdD19", "https://www.science.org/digital-feed/pipeline"]
stacks = Substacks + non_substacks

def construct_feed_dict(url):
    feed = feedparser.parse(url)
    res = {}
    feed_info = feed['feed']
    feed_name = feed_info.get('title', 'No Title')
    feed_description = feed_info.get('description', 'No Description') #Adding this
    if len(feed_description) == 0:
        feed_description = "No Description"
    res['title'] = feed_name
    res['url'] = url
    res['description'] = feed_description
    entries = feed['entries']
    res['titles'] = [entry.get('title', 'No Title') for entry in entries]
    res['values'] = [entry.get('content', [{'value': entry.get('summary', '')}])[0]['value'] for entry in entries]
    res['is_contents'] = ['content' in entry for entry in entries]
    res['dates'] = [mongo.convert_to_date(entry.get('published', '')) for entry in entries] 
    res['links'] = [entry.get('link', '') for entry in entries]
    res['authors'] = [entry.get('author', 'Unknown') for entry in entries]
    res['bozo'] = feed['bozo'] == 1 or len(entries) < 1
    
    return res