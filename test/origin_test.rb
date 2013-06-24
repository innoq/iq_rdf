# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$LOAD_PATH << File.dirname(__FILE__)

require 'test_helper'

class CustomStripper < IqRdf::Origin::Filters::GenericFilter
  def call(obj, str)
    str = str.gsub("foobar", "")
    run(obj, str)
  end
end

class OriginTest < Test::Unit::TestCase

  def test_should_replace_umlauts
    assert_equal "AeaeUeueOeoess", IqRdf::Origin.new("ÄäÜüÖöß").to_s
  end

  def test_should_camelize_string
    assert_equal "AWeighting", IqRdf::Origin.new("'A' Weighting").to_s
  end

  def test_should_handle_numbers_at_the_beginning
    assert_equal "_123", IqRdf::Origin.new("123").to_s
  end

  def test_should_handle_whitespaces_at_strange_positions
    assert_equal "test12", IqRdf::Origin.new("test 12 ").to_s
  end

  def test_should_preserve_underlines
    assert_equal "_test", IqRdf::Origin.new("_test").to_s
    assert_equal "a_Test", IqRdf::Origin.new("a_Test").to_s
  end

  def test_should_preserve_case
    assert_equal "test", IqRdf::Origin.new("test").to_s
    assert_equal "Test", IqRdf::Origin.new("Test").to_s
    assert_equal "_5test", IqRdf::Origin.new("5test").to_s
    assert_equal "_5Test", IqRdf::Origin.new("5Test").to_s
  end

  def test_should_replace_brackets
    assert_equal "--Energie-Ressource",
      IqRdf::Origin.new("[Energie/Ressource]").to_s
  end

  def test_should_replace_comma
    assert_equal "-", IqRdf::Origin.new(",").to_s
  end

  def test_should_merge_all_together
    assert_equal "--Energie-Ressource",
      IqRdf::Origin.new("[Energie - Ressource]").to_s
    assert_equal "--Hydrosphaere-WasserUndGewaesser",
      IqRdf::Origin.new("[Hydrosphäre - Wasser und Gewässer]").to_s
  end

  def test_register_custom_filter
    IqRdf::Origin::Filters.register(:strip_foobars, CustomStripper)
    assert_equal "trololo_", IqRdf::Origin.new("trololo_foobar").strip_foobars.to_s
    assert_equal "trololo_", IqRdf::Origin.new("trololo_foobar").to_s
  end

end
