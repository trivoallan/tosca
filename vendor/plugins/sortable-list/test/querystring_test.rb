$:.unshift(File.join(File.dirname(__FILE__), '../lib'))

require 'test/unit'
require 'hash_ext'

class QueryStringTest < Test::Unit::TestCase

  # Test normal foo=bar&amp;baz=boo type querystring
  def test_basic
    assert_equal 'baz=boo&amp;foo=bar&amp;pdi=sloe', {
      :foo => 'bar',
      :baz => 'boo',
      :pdi => 'sloe'
    }.to_qs
  end

  # Test querystring with array
  def test_array
    assert_equal 'baz[]=a&amp;baz[]=b&amp;baz[]=c&amp;foo=bar', {
      :foo => 'bar',
      :baz => %w(a b c)
    }.to_qs
  end

  # Can we handle a nested hash
  def test_nested_hash
    assert_equal 'a[b]=c&amp;a[d]=e&amp;a[f]=g&amp;h[i]=j&amp;h[k]=l&amp;h[m]=n', {
      :a => {:b => 'c', :d => 'e', :f => 'g'},
      :h => {:i => 'j', :k => 'l', :m => 'n'}
    }.to_qs
  end

  # Test more than one level of nesting
  def test_really_nested_hash
    assert_equal 'a[b][c][d]=e&amp;a[b][f]=g&amp;a[h]=i&amp;j[k]=l&amp;m=n&amp;o[p][q]=r&amp;o[p][s]=t', {
      :a => {:b => {:c => {:d => 'e'}, :f => 'g'}, :h => 'i'},
      :j => {:k => 'l'}, :m => 'n', :o => {:p => {:q => 'r', :s => 't'}}
    }.to_qs
  end

  # Let's try to confuse it!
  def test_nested_mixed
    assert_equal 'a[b][c]=d&amp;a[b][e]=f&amp;a[g]=i&amp;a[j][]=k&amp;a[j][]=l&amp;a[j][]=m&amp;q=r&amp;s[]=t&amp;s[]=u&amp;s[]=v&amp;w[x]=y&amp;w[z][]=1&amp;w[z][]=2&amp;w[z][]=3&amp;w[z][]=4', {
      :a => {:b => {:c => 'd', :e => 'f'}, :g => 'i', :j => %w(k l m)},
      :q => 'r',
      :s => %w(t u v),
      :w => {:x => 'y', :z => [1, 2, 3, 4]}
    }.to_qs
  end
end
