require 'open-uri'
require 'pp'
require 'rexml/document'
require 'rexml/streamlistener' 


class POI
  attr_accessor :name, :lat, :long, :tags
  def initialize
    @name = ""
    @lat, @long = 0.0 
    @tags = [] 
  end
end


class StreamListener
  include REXML::StreamListener

  def initialize
    @relevant = [] 
    @poi = nil
    @added_to_relevant = false
  end

  def tag_start(*args)
    name = args.first
    if name.eql?("node")
      @added_to_relevant = false
      @poi = POI.new 
      @poi.lat, @poi.long = args.last["lat"], args.last["lon"]
    end
    if name.eql?("tag")
      @poi.tags << args.last
      if args.last["k"] == "amenity"
        unless @added_to_relevant
          @relevant << @poi
          @added_to_relevant = true
        end 
      end
    end 
  end  
  
  def transform_relevant
    out = %Q(<?xml version="1.0" encoding="UTF-8"?>)
    out += %Q(<result>)
    @relevant.each do |poi| 
      out += %Q(<poi lat="#{poi.lat}" long="#{poi.long}">)
      poi.tags.each{|tag| out += %Q(<tag k="#{tag["k"]}" v="#{tag["v"]}"/>)}
      out += %Q(</poi>)
    end 
    out += %Q(</result>)
    out
  end
  
end

listener = StreamListener.new
xml = File.new "map.osm"   
REXML::Document.parse_stream(xml, listener)

puts listener.transform_relevant

