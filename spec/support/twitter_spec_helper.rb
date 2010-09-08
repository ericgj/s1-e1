module TwitterSpecHelper

  def base_tweet_hash
    {
      "coordinates" => nil,
      "favorited" => false,
      "created_at" => "Wed Sep 08 03:57:22 +0000 2010",
      "truncated" => false,
      "entities" => base_entities_hash,
      "contributors" => nil,
      "text" => "test message to @ericgj_rmu",
      "id" => 23882535495,
      "retweet_count" => nil,
      "geo" => nil,
      "retweeted" => false,
      "in_reply_to_user_id" => nil,
      "user" => base_user_hash,
      "source" => "web",
      "in_reply_to_screen_name" => nil,
      "place" => nil,
      "in_reply_to_status_id" => nil
    }  
  end
  
  def base_user_hash
    {
      "name" => "E G",
      "profile_background_tile" => false,
      "profile_sidebar_border_color" => "87bc44",
      "profile_sidebar_fill_color" => "e0ff92",
      "created_at" => "Tue Sep 07 06:17:18 +0000 2010",
      "location" => nil,
      "profile_image_url" => "http =>//s.twimg.com/a/1283564528/images/default_profile
  _1_normal.png",
      "profile_link_color" => "0000ff",
      "follow_request_sent" => nil,
      "contributors_enabled" => false,
      "url" => nil,
      "favourites_count" => 0,
      "utc_offset" => nil,
      "id" => 187814390,
      "profile_use_background_image" => true,
      "listed_count" => 0,
      "followers_count" => 1,
      "profile_text_color" => "000000",
      "lang" => "en",
      "protected" => false,
      "geo_enabled" => false,
      "profile_background_color" => "9ae4e8",
      "notifications" => nil,
      "description" => nil,
      "time_zone" => nil,
      "verified" => false,
      "friends_count" => 1,
      "statuses_count" => 75,
      "profile_background_image_url" => "http =>//s.twimg.com/a/1283564528/images/them
  es/theme1/bg.png",
      "following" => nil,
      "show_all_inline_media" => false,
      "screen_name" => "ericgj72"
    }
  end
  
  def base_entities_hash
    {
      "urls" => [

      ],
      "hashtags" => [

      ],
      "user_mentions" => [
        base_user_mentions_hash
      ]
    }
  end
  
  def base_user_mentions_hash
    {
      "name" => "eg rmu",
      "id" => 186283225,
      "indices" => [
        16,
        27
      ],
      "screen_name" => "ericgj_rmu"
    }  
  end
  
  
  def tweet_hash(opts = {})
    base_tweet_hash.merge(opts)
  end
  
  def user_hash(opts = {})
    base_user_hash.merge(opts)
  end
  
  def entities_hash(opts = {})
    base_entities_hash.merge(opts)
  end
  
  def user_mentions_hash(opts = {})
    base_user_mentions_hash.merge(opts)
  end
  
end
