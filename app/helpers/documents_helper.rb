module DocumentsHelper

  # Link to a defined type of document
  # call it like : link_to_typedocument t 
  def link_to_typedocument(typedocument)
    return '-' unless typedocument
    size = typedocument.documents.size
    return nil if typedocument.documents.size == 0
    link_to "#{typedocument.name} (#{size})",  
      list_document_url(:id => typedocument.id) 
  end

end
