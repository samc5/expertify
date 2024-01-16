import feedparser
import mongo

ACX = "https://www.astralcodexten.com/feed/"
FT = "https://www.ft.com/myft/following/15b4e217-cc5c-47a8-8234-8f5cf596769c.rss"
MLBTR = "http://feeds.feedburner.com/MlbTradeRumors"
NYT = "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"

"""
https://yearofwritingdangerously.substack.com
https://news.manifold.markets
https://theadvancescout.substack.com
https://www.aisnakeoil.com
https://ryanjakubowski.substack.com
https://aquaimperium.substack.com
https://www.astralcodexten.com
https://www.briefingbook.info
https://poulos.substack.com
https://channelsofinfluence.substack.com
https://www.counteroffensive.news
https://cupofcoffee.substack.com
https://dhaaruni.substack.com
https://www.distilled.earth
https://danieldrezner.substack.com
https://theeggandtherock.com
https://gelliottmorris.substack.com
https://www.experimental-history.com
https://mileskellerman.substack.com
https://forklightning.substack.com
https://www.forkingpaths.co
https://herdingcatsnj.substack.com
https://hypertextjournal.substack.com
https://insidemedicine.substack.com
https://www.theinternationalcorrespondent.com
https://joeblogs.joeposnanski.com
https://www.jonstokes.com
https://www.liberalpatriot.com
https://mollyknight.substack.com
https://pmarca.substack.com
https://garymarcus.substack.com
https://jonathanstea.substack.com
https://www.mod171.com
https://neilpaine.substack.com
https://www.noahpinion.blog
https://www.numlock.com
https://ryanmcbeth.substack.com
https://www.nycsouthpaw.com
https://www.persuasion.community
https://politickingetc.substack.com
https://popular.info
https://populism.substack.com
https://www.programmablemutter.com
https://www.readoptional.com
https://www.natesilver.net
https://www.slowboring.com
https://stevelichtenstein.substack.com
https://superbowl.substack.com
https://www.sustainabilitybynumbers.com
https://snyder.substack.com
https://daniellekurtzleben.substack.com
https://transmissionsfromtheredplanet.substack.com
https://smotus.substack.com
https://radleybalko.substack.com
https://williamfleitch.substack.com
https://wordswithyenhan.substack.com
"""


Substacks = ["https://www.awritersnotebook.org", "https://yearofwritingdangerously.substack.com/feed", "https://news.manifold.markets/feed", "https://theadvancescout.substack.com/feed", "https://www.aisnakeoil.com/feed", "https://ryanjakubowski.substack.com/feed", "https://aquaimperium.substack.com/feed", "https://www.astralcodexten.com/feed", "https://www.briefingbook.info/feed", "https://poulos.substack.com/feed", "https://channelsofinfluence.substack.com/feed", "https://www.counteroffensive.news/feed", "https://cupofcoffee.substack.com/feed", "https://dhaaruni.substack.com/feed", "https://www.distilled.earth/feed", "https://danieldrezner.substack.com/feed", "https://theeggandtherock.com/feed", "https://gelliottmorris.substack.com/feed", "https://www.experimental-history.com/feed", "https://mileskellerman.substack.com/feed", "https://forklightning.substack.com/feed", "https://www.forkingpaths.co/feed", "https://herdingcatsnj.substack.com/feed", "https://hypertextjournal.substack.com/feed", "https://insidemedicine.substack.com/feed", "https://www.theinternationalcorrespondent.com/feed", "https://joeblogs.joeposnanski.com/feed", "https://www.jonstokes.com/feed", "https://www.liberalpatriot.com/feed", "https://mollyknight.substack.com/feed", "https://pmarca.substack.com/feed", "https://garymarcus.substack.com/feed", "https://jonathanstea.substack.com/feed", "https://www.mod171.com/feed", "https://neilpaine.substack.com/feed", "https://www.noahpinion.blog/feed", "https://www.numlock.com/feed", "https://ryanmcbeth.substack.com/feed", "https://www.nycsouthpaw.com/feed", "https://www.persuasion.community/feed", "https://politickingetc.substack.com/feed", "https://popular.info/feed", "https://populism.substack.com/feed", "https://www.programmablemutter.com/feed", "https://www.readoptional.com/feed", "https://www.natesilver.net/feed", "https://www.slowboring.com/feed", "https://stevelichtenstein.substack.com/feed", "https://superbowl.substack.com/feed", "https://www.sustainabilitybynumbers.com/feed", "https://snyder.substack.com/feed", "https://daniellekurtzleben.substack.com/feed", "https://transmissionsfromtheredplanet.substack.com/feed", "https://smotus.substack.com/feed", "https://radleybalko.substack.com/feed", "https://williamfleitch.substack.com/feed", "https://wordswithyenhan.substack.com/feed"]


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
    if 'title' not in feed['feed']:
        feed_name = "Unknown"
    else:
        feed_name = feed['feed']['title']
    titles = []
    values = []
    dates = []
    entries = feed['entries']
    for i in entries:
        if 'title' in i and 'content' in i and 'published' in i:
            titles.append(i['title'])
            values.append(i['content'][0]['value'])
            dates.append(mongo.convert_to_date(i['published']))
        elif 'title' in i and 'summary' in i and 'published' in i:
            titles.append(i['title'])
            values.append(i['summary'])
            dates.append(mongo.convert_to_date(i['published']))
    res['title'] = feed_name
    res['url'] = url
    res['titles'] = titles
    res['values'] = values
    res['dates'] = dates
    return res



#print(construct_feed_dict(MLBTR))
# for i in Substacks:
#     d = construct_feed_dict(i)
#     mongo.add_feed(d)




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