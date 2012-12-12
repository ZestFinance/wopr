module XMLMatchers
  extend RSpec::Matchers::DSL

  matcher :have_tag do |tag_name|
    chain :with_attributes do |attributes|
      @attributes = attributes
    end

    chain :with_content do |content|
      @content = content
    end

    match do |response|
      document = Nokogiri::XML::Document.parse(response.body)
      @nodes = document.xpath("//#{tag_name}").to_a
      if @attributes
        @nodes = @nodes.select do |node|
          @attributes.keys.all? do |attribute|
            node.attr(attribute) == @attributes[attribute].to_s
          end
        end
      end

      if @content
        @nodes = @nodes.select do |node|
          node.content == @content
        end
      end

      @nodes.count > 0
    end

    failure_message_for_should do |response|
      "expected that the response body:\n\n#{actual.body}\n\nwould have an element #{tag_name}".tap do |message|
        if @attributes
          message << " and attributes #{@attributes}"
        end

        if @content
          message << " and content \"#{@content}\""
        end
      end
    end
  end
end
