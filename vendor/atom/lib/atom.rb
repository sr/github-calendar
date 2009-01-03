require 'time'
require 'uri'

require File.dirname(__FILE__) + '/xmlmapping'

module Atom
  NAMESPACE = 'http://www.w3.org/2005/Atom'
  XHTML_NAMESPACE = 'http://www.w3.org/1999/xhtml'

  class Text < String
    attr_reader :mime_type

    def initialize(element)
      type = element.attribute('type', NAMESPACE)

      @mime_type =
        case type ? type.value : nil
        when 'text'   then 'text/plain'
        when 'html'   then 'text/html'
        when 'xhtml'  then 'text/xhtml'
        when nil      then 'text/plain'
        else
          raise ArgumentError, "Unknown type: #{type.value}"
        end

      value =
        case @mime_type
        when 'text/plain', 'text/html'
          element.texts.map(&:value).join
        when 'text/xhtml'
          base = element.attribute('base') || element.parent.attribute('base')
          content = REXML::XPath.first(element, 'xhtml:div', 'xhtml' => XHTML_NAMESPACE).children
          content.map! { |element| resolve_uri(element, base) }
          content.to_s
        end

      super value
    end

    private
      def resolve_uri(element, base)
        return element unless element.is_a?(REXML::Element) && element.attribute('href')
        uri = URI.join(base.to_s, element.attribute('href').value).to_s
        element.add_attribute('href', uri)
        element
      end
  end

  class Content
    attr_reader :mime_type, :src, :value

    def initialize(element)
      type = element.attribute('type', NAMESPACE)
      src = element.attribute('src', NAMESPACE)

      unless src
        @mime_type =
          case type ? type.value : nil
          when 'text', nil  then 'text/plain'
          when 'html'       then 'text/html'
          when 'xhtml'      then 'text/xhtml'
          else
            type.value
          end

        @value =
          case @mime_type
          when 'text/plain', 'text/html'
            element.texts.map { |t| t.value }.join
          when 'text/xhtml':
            REXML::XPath.first(element, 'xhtml:div', 'xhtml' => XHTML_NAMESPACE).children.to_s
          when /\+xml$|\/xml$/:
            REXML::XPath.first(element).children.to_s
          else
            element.texts.join.strip.unpack("m")[0]
          end
      else
        @src = src.value
        @mime_type = type.value if type
        @value = nil
      end
    end
  end

  class Person
    include XMLMapping

    namespace NAMESPACE

    has_one :name
    has_one :email
    has_one :uri

    def to_s
      email ? "#{name} (#{email})" : name
    end
  end

  class Generator
    include XMLMapping

    namespace NAMESPACE

    has_attribute :uri
    has_attribute :version
    text :name

    def to_s
      name
    end
  end

  class Link
    include XMLMapping

    namespace NAMESPACE

    has_attribute :href
    has_attribute :rel, :default => 'alternate'
    has_attribute :type
    has_attribute :hreflang
    has_attribute :title
    has_attribute :length

    def to_s
      href
    end
  end

  class Category
    include XMLMapping

    namespace NAMESPACE

    has_attribute :term
    has_attribute :scheme
    has_attribute :label

    def to_s
      term
    end
  end

  class Source
    include XMLMapping

    namespace NAMESPACE

    has_one :id
    has_one :icon
    has_one :logo
    has_one :generator, :type => Generator
    has_one :rights,    :type => Text
    has_one :subtitle,  :type => Text
    has_one :title,     :type => Text
    has_one :updated,   :transform => lambda { |value| Time.iso8601(value) }

    has_many :authors,      :name => 'author',      :type => Person
    has_many :contributors, :name => 'contributor', :type => Person
    has_many :links,        :name => 'link',        :type => Link
    has_many :categories,   :name => 'category',    :type => Category
  end

  class Entry
    include XMLMapping

    namespace NAMESPACE

    has_one :id
    has_one :published, :transform => lambda { |value| Time.iso8601(value) }
    has_one :updated,   :transform => lambda { |value| Time.iso8601(value) }
    has_one :title,     :type => Text
    has_one :summary,   :type => Text
    has_one :rights,    :type => Text
    has_one :source,    :type => Source
    has_one :content,   :type => Content

    has_many :authors,      :name => 'author',      :type => Person
    has_many :contributors, :name => 'contributor', :type => Person
    has_many :links,        :name => 'link',        :type => Link
    has_many :categories,   :name => 'category',    :type => Category

    has_many :extended_elements, :name => :any, :namespace => :any, :type => :raw
  end

  class Feed
    include XMLMapping

    namespace NAMESPACE

    has_one :id
    has_one :updated, :transform => lambda { |value| Time.iso8601(value) }
    has_one :title,     :type => Text
    has_one :subtitle,  :type => Text
    has_one :rights,    :type => Text
    has_one :generator, :type => Generator
    has_one :icon
    has_one :logo

    has_many :authors,      :name => 'author',      :type => Person
    has_many :contributors, :name => 'contributor', :type => Person
    has_many :links,        :name => 'link',        :type => Link
    has_many :categories,   :name => 'category',    :type => Category
    has_many :entries,      :name => 'entry',       :type => Entry
  end
end


if $0 == __FILE__
  require 'net/http'
  require 'uri'

  str = Net::HTTP::get(URI::parse('http://blog.ning.com/atom.xml'))
  feed = Atom::Feed.new(str)

  feed.entries.each { |entry|
    puts "'#{entry.title}' by #{entry.authors[0].name} on #{entry.published.strftime('%m/%d/%Y')}"
  }
end
