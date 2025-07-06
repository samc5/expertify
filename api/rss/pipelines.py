pipeline2 = [
    {
        "$project": {
            "_id": 1,
            "title": 1,
            "url": 1,
            "description": 1,
            "article": {
                "$zip": {
                    "inputs": ["$titles", "$values", "$dates", "$links", "$authors"],
                }
            }
        }
    },
    {"$unwind": "$article"},

    {
        "$project": {
            "_id": 1,
            "publication_name": "$title",
            "description": 1,
            "url": 1,
            "title": {
                "$arrayElemAt": ["$article", 0]
            },
            "value": {
                "$arrayElemAt": ["$article", 1]
            },
            "date": {
                "$arrayElemAt": ["$article", 2]
            },
            "link": {
                "$arrayElemAt": ["$article", 3]
            },
            "author": {
                "$arrayElemAt": ["$article", 4]
            }
        }
    },
    {"$sort": {"date": -1}},
    {"$limit": 100}
]

url_pipeline = [
    {
        "$project": {
            "url": 1
        }
    }
]

def pub_pipeline(url):
    return [
    {
        "$match": {
            "url": url 
        }
    },
    {
        "$project": {
            "_id": 1,
            "title": 1,
            "url": 1,
            "description": 1,
            "article": {
                "$zip": {
                    "inputs": ["$titles", "$values", "$dates", "$links", "$authors"],
                }
            }
        }
    },
    {"$unwind": "$article"},
    {
        "$project": {
            "_id": 1,
            "publication_name": "$title",
            "description": 1,
            "url": 1,
            "title": {
                "$arrayElemAt": ["$article", 0]
            },
            "value": {
                "$arrayElemAt": ["$article", 1]
            },
            "date": {
                "$arrayElemAt": ["$article", 2]
            },
            "link": {
                "$arrayElemAt": ["$article", 3]
            },
            "author": {
                "$arrayElemAt": ["$article", 4]
            }
        }
    },
    {"$sort": {"date": -1}},
    {"$limit": 100}
]


def personal_pipeline(url_list):
    return [
    {"$match": {"url": {"$in": url_list}}},
    {
        "$project": {
            "_id": 1,
            "title": 1,
            "url": 1,
            "description": 1,
            "article": {
                "$zip": {
                    "inputs": ["$titles", "$values", "$dates", "$links", "$authors"],
                }
            }
        }
    },
    {"$unwind": "$article"},

    {
        "$project": {
            "_id": 1,
            "publication_name": "$title",
            "description": 1,
            "url": 1,
            "title": {
                "$arrayElemAt": ["$article", 0]
            },
            "value": {
                "$arrayElemAt": ["$article", 1]
            },
            "date": {
                "$arrayElemAt": ["$article", 2]
            },
            "link": {
                "$arrayElemAt": ["$article", 3]
            },
            "author": {
                "$arrayElemAt": ["$article", 4]
            }
        }
    },
    {"$sort": {"date": -1}},
    {"$limit": 100}
]

feed_and_url_pipeline = [
    {
        "$project": {
            "_id": 0,
            "title": 1,
            "url": 1,
            "description": 1
        }
    }
]

def feed_url_pipeline(url_list):
    return [
    {"$match": {"url": {"$in": url_list}}},
    {
        "$project": {
            "_id": 0,
            "title": 1,
            "url": 1,
            "description": 1
        }
    }
]


leaderboard_pipeline = [
    {"$sort": {"subscribers_count": -1}},  # Sort by subscribers_count in descending order
    {"$limit": 5},  # Limit to top 5
    {"$project": {
        "_id": 0,
        "description": 1,
        "title": 1,
        "url": 1
    }
    }
]