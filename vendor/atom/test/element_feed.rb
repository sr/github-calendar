require File.dirname(__FILE__) + '/test_helper'

class TestAtom < Test::Unit::TestCase
  def test_category
    str = <<-XML
      <category term='blue' scheme='the scheme' label='Blue entries'
       xmlns="#{Atom::NAMESPACE}"/>
    XML

    category = Atom::Category.new(str)

    assert_respond_to category, :term
    assert_equal 'blue', category.term

    assert_respond_to category, :scheme
    assert_equal 'the scheme', category.scheme

    assert_respond_to category, :label
    assert_equal 'Blue entries', category.label
  end
end
