class Terminal
  class << self
    def puts_header(title)
      puts <<~EO_HEADER

        #{title}
        #{"=" * title.length}

      EO_HEADER
    end
  end
end
