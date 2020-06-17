class IndexerCommon
  add_indexer_initialize_hook do |indexer|
    indexer.add_document_prepare_hook do |doc, record|
      if record['record']['onsite_status']
        doc['onsite_status_u_sstr'] = record['record']['onsite_status']
      end
    end
  end
end