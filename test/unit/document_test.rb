require File.dirname(__FILE__) + '/../test_helper'

class DocumentTest < Test::Unit::TestCase
  fixtures :documents, :document_versions

  def test_to_strings
    check_strings Document, :date_delivery_on_formatted, :title
  end

  def test_versions
    d = documents(:document_00001)
    orig_title = d.title
    d.update_attribute :title, "this is a new title"

    newd = Document.find(1)
    assert_equal newd.title, "this is a new title"
    assert_equal newd.versions.first.title, orig_title
  end

  # This test is really important.
  # It upload the file into the good directory,
  def test_uploads
    d = documents(:document_00001)
    doc_file = fixture_file_upload('/files/has_many_and_belongs_to_many.pdf', 'application/pdf')
    d.update_attribute(:file, doc_file)
    assert d.file, 'has_many_and_belongs_to_many.pdf'

    d = documents(:document_00002)
    doc_file = fixture_file_upload('/files/rails_files_cheatsheet.pdf', 'application/pdf')
    d.update_attribute(:file, doc_file)
    assert d.file, 'rails_files_cheatsheet.pdf'
  end

  def test_attributes
    d = documents(:document_00001)
    assert_kind_of Time, d.created_on
    assert_kind_of Time, d.updated_on
    assert_kind_of Time, d.date_delivery
  end

end
