import feedparser
import mongo

ACX = "https://www.astralcodexten.com/feed/"
FT = "https://www.ft.com/myft/following/15b4e217-cc5c-47a8-8234-8f5cf596769c.rss"
MLBTR = "http://feeds.feedburner.com/MlbTradeRumors"
NYT = "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"

Substacks = ["https://www.awritersnotebook.org/feed", "https://yearofwritingdangerously.substack.com/feed", "https://news.manifold.markets/feed", "https://theadvancescout.substack.com/feed", "https://www.aisnakeoil.com/feed", "https://ryanjakubowski.substack.com/feed", "https://aquaimperium.substack.com/feed", "https://www.astralcodexten.com/feed", "https://www.briefingbook.info/feed", "https://poulos.substack.com/feed", "https://channelsofinfluence.substack.com/feed", "https://www.counteroffensive.news/feed", "https://cupofcoffee.substack.com/feed", "https://dhaaruni.substack.com/feed", "https://www.distilled.earth/feed", "https://danieldrezner.substack.com/feed", "https://theeggandtherock.com/feed", "https://gelliottmorris.substack.com/feed", "https://www.experimental-history.com/feed", "https://mileskellerman.substack.com/feed", "https://forklightning.substack.com/feed", "https://www.forkingpaths.co/feed", "https://herdingcatsnj.substack.com/feed", "https://hypertextjournal.substack.com/feed", "https://insidemedicine.substack.com/feed", "https://www.theinternationalcorrespondent.com/feed", "https://joeblogs.joeposnanski.com/feed", "https://www.jonstokes.com/feed", "https://www.liberalpatriot.com/feed", "https://mollyknight.substack.com/feed", "https://pmarca.substack.com/feed", "https://garymarcus.substack.com/feed", "https://jonathanstea.substack.com/feed", "https://www.mod171.com/feed", "https://www.noahpinion.blog/feed", "https://www.numlock.com/feed", "https://ryanmcbeth.substack.com/feed", "https://www.nycsouthpaw.com/feed", "https://www.persuasion.community/feed", "https://politickingetc.substack.com/feed", "https://popular.info/feed", "https://populism.substack.com/feed", "https://www.programmablemutter.com/feed", "https://www.readoptional.com/feed", "https://www.natesilver.net/feed", "https://www.slowboring.com/feed", "https://stevelichtenstein.substack.com/feed", "https://superbowl.substack.com/feed", "https://www.sustainabilitybynumbers.com/feed", "https://snyder.substack.com/feed", "https://daniellekurtzleben.substack.com/feed", "https://transmissionsfromtheredplanet.substack.com/feed", "https://smotus.substack.com/feed", "https://radleybalko.substack.com/feed", "https://williamfleitch.substack.com/feed", "https://wordswithyenhan.substack.com/feed"]
non_substacks = ["https://acoup.blog/feed", "https://crookedtimber.org/feed/", "http://feeds.feedburner.com/MLBTRTransactions", "https://statmodeling.stat.columbia.edu/feed/", "https://kill-the-newsletter.com/feeds/lt36fwdlv0f0bnbj.xml", "https://stratechery.passport.online/feed/rss/AXqhHmNvk3poy5AdFVdD19", "https://www.science.org/digital-feed/pipeline"]
stacks = Substacks + non_substacks
# print(type(feed['entries']))
# print(feed.keys())
# for i in feed.keys():
#     print("\n")
#     print(i)
#     if isinstance(feed[i], dict):
#         for j in feed[i].keys():
#             print(j)
#             if isinstance(feed[i][j], dict):
#                 #print(j)
#                 print(feed[i][j].keys())
#         #print(feed[i].keys())

# print(feed['entries'][0].keys())




def construct_feed_dict(url):
    feed = feedparser.parse(url)
    res = {}
    feed_info = feed['feed']
    feed_name = feed_info.get('title', 'Unknown')
    res['title'] = feed_name
    res['url'] = url
    entries = feed['entries']
    res['titles'] = [entry.get('title', 'No Title') for entry in entries]
    res['values'] = [entry.get('content', [{'value': entry.get('summary', '')}])[0]['value'] for entry in entries]
    res['is_contents'] = ['content' in entry for entry in entries]
    res['dates'] = [mongo.convert_to_date(entry.get('published', '')) for entry in entries] 
    res['links'] = [entry.get('link', '') for entry in entries]
    res['authors'] = [entry.get('author', 'Unknown') for entry in entries]
    
    return res




# def construct_feed_dict(url):
#     feed = feedparser.parse(url)
#     res = {}
#     if 'title' not in feed['feed']:
#         feed_name = "Unknown"
#     else:
#         feed_name = feed['feed']['title']
#     titles = []
#     values = []
#     dates = []
#     links = []
#     authors = []
#     entries = feed['entries']
#     for i in entries:
#         if 'title' in i and 'content' in i and 'published' in i and 'link' in i:
#             titles.append(i['title'])
#             values.append(i['content'][0]['value'])
#             dates.append(mongo.convert_to_date(i['published']))
#             links.append(i['link'])
#         elif 'title' in i and 'summary' in i and 'published' in i and 'link' in i:
#             titles.append(i['title'])
#             values.append(i['summary'])
#             dates.append(mongo.convert_to_date(i['published']))
#             links.append(i['link'])
#         if 'author' in i:
#             authors.append(i['author'])
#         else:
#             authors.append("0")
#     res['title'] = feed_name
#     res['url'] = url
#     res['titles'] = titles
#     res['values'] = values
#     res['dates'] = dates
#     res['links'] = links
#     res['authors'] = authors
#     return res


# print(construct_feed_dict("https://kill-the-newsletter.com/feeds/lt36fwdlv0f0bnbj.xml"))
# print("beginning to construct feed dicts")
# feed_dicts = [construct_feed_dict(i) for i in stacks]
# print("done with feed dicts")
# mongo.add_feeds(feed_dicts)





# for i in feed["entries"]:
#     # print(i.keys())
#     # print(i["title"])
#     # print(i["link"])
#     # print(f'summary: {i["summary"]}')
#     # print(f'summary-detail: {i["summary_detail"]}')
#     # if "author" in i:
#     #     print(i["author"])
#     if "content" in i:
#         print("-----------------------------")
#         print(i["content"][0]['value'])
#     #print(i["content"][0]['value'])
#     print("---------------")