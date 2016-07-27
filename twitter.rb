require "mechanize"
require "sentimentalizer"
require "awesome_print"



class Analyzer
	def initialize
		Sentimentalizer.setup
	end
	def probability phrase
		process(phrase).overall_probability
	end

private
	
	def process(phrase)
		Sentimentalizer.analyze phrase
	end

end


class TwitterBot
	attr_reader :page
	def initialize 
		@agent = Mechanize.new
		@agent.user_agent_alias = "Mac Safari"
		@page = @agent.get("http://www.twitter.com/")
	end


	def tweets
		@page.css(".js-tweet-text-container").map do |tweet|
			tweet.text.strip
		end
	end



	def fetch_results q
		search q
		live
		tweets
	end

	def search	q
		@page = @page.form_with(action: "/search") do |f|
			f["q"] = q
		end.click_button
	end

	def live
		@page = @page.link_with(text: /Live/).click
	end
end


class AnalyzerBot 
	def initialize	bot, analyzer
		@bot = bot
		@analyzer = analyzer
	end

	def score search
		average_scores scores_from_tweets(tweet_array(search))
	end

private

	def scores_from_tweets tweets
		tweets.map do |tweet|
			@analyzer.probability(tweet)
		end
	end

	def average_scores scores
		scores.inject(0.0) {|sum , el| sum + el}.to_f / scores.size
	end
	
	def tweet_array search
		@bot.fetch_results(search)
	end

end

bot = AnalyzerBot.new(TwitterBot.new, Analyzer.new)
ap bot.score("Obama")

