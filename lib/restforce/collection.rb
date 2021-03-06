module Restforce
  class Collection
    include Enumerable

    # Given a hash and client, will create an Enumerator that will lazily
    # request Salesforce for the next page of results.
    def initialize(hash, client)
      @client = client
      @raw_page = hash
    end

    # Yield each value on each page.
    def each
      cur_collection = self
      while !cur_collection.nil?
        cur_collection.raw_records.each { |record| yield Restforce::Mash.build(record, @client) }
        cur_collection = cur_collection.next_page
      end
    end

    # Return the size of the Collection without making any additional requests.
    def size
      @raw_page['totalSize']
    end
    alias_method :length, :size

    # Return array of the elements on the current page
    def current_page
      first(@raw_page['records'].size)
    end

    # Return the current and all of the following pages.
    def pages
      [self] + (has_next_page? ? next_page.pages : [])
    end

    # Returns true if there is a pointer to the next page.
    def has_next_page?
      !@raw_page['nextRecordsUrl'].nil?
    end

    # Returns the next page as a Restforce::Collection if it's available, nil otherwise.
    def next_page
      @next_page ||= @client.get(@raw_page['nextRecordsUrl']).body if has_next_page?
    end

    def raw_records
        @raw_page['records']
    end
  end
end
