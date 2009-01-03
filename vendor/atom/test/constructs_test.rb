require File.dirname(__FILE__) + '/test_helper'

class TestAtom < Test::Unit::TestCase
  def test_link
    str = <<-XML
      <link rel="self" href="http://blog.ning.com/atom.xml" xmlns="#{Atom::NAMESPACE}"/>
    XML

    link = Atom::Link.new(str)

    assert_respond_to link, :rel
    assert_equal 'self', link.rel

    assert_respond_to link, :href
    assert_equal 'http://blog.ning.com/atom.xml', link.href
  end


  def test_person
    str = <<-XML
      <author xmlns="#{Atom::NAMESPACE}">
        <name>Martin</name>
        <uri>http://www.test.com</uri>
        <email>martin@test.com</email>
      </author>
    XML

    person = Atom::Person.new(str)

    assert_respond_to person, :name
    assert_equal 'Martin', person.name

    assert_respond_to person, :uri
    assert_equal 'http://www.test.com', person.uri

    assert_respond_to person, :email
    assert_equal 'martin@test.com', person.email
  end

  def test_content_type_text
    str = <<-XML
      <content type='text' xmlns="#{Atom::NAMESPACE}">some text</content>
    XML

    element = REXML::Document.new(str).root
    content = Atom::Content.new(element)

    assert_respond_to content, :mime_type
    assert_equal 'text/plain', content.mime_type

    assert_respond_to content, :value
    assert_equal 'some text', content.value
  end

  def test_content_type_text_escaped
    str = <<-XML
      <content type='text' xmlns="#{Atom::NAMESPACE}">some &amp; text</content>
    XML

    element = REXML::Document.new(str).root
    content = Atom::Content.new(element)

    assert_respond_to content, :mime_type
    assert_equal 'text/plain', content.mime_type

    assert_respond_to content, :value
    assert_equal 'some & text', content.value
  end

  def test_text_type_xhtml
    str = <<-XML
      <title type='xhtml'><div xmlns="http://www.w3.org/1999/xhtml">itchy &amp; <b>scratchy</b></div></title>
    XML

    element = REXML::Document.new(str).root
    content = Atom::Text.new(element)

    assert_respond_to content, :mime_type
    assert_equal 'text/xhtml', content.mime_type

    assert_equal 'itchy &amp; <b>scratchy</b>', content
  end
end

