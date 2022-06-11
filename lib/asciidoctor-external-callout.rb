require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

include Asciidoctor

# Treeprocessor that adds external callout marks to source code
#
# [source, ruby]
# ----
# puts 'Hello World'
# puts 'Hello again'
# ---
# 1. Saying hello @1
# 2. And again @2
# 3. Text search @/again/

Asciidoctor::Extensions::register do

  LOCATION_TOKEN_RX = /@(\d+)|@\/([^\/]+?)\//
  LOCATION_TOKEN_ARRAY_RX = /^(@\d+|@\/[^\/]+?\/)((\s+@\d+)|(\s+@\/[^\/]+?\/))*$/

  tree_processor do

    process do |document|

      begin
        # set the traverse_documents option to look for ordered lists
        # The makes sure it's the right kind of list.
        document.find_by context: :olist do |list|

          if external_callout_list? list

            owner_block = owning_block list

            owner_block.subs.replace(owner_block.subs + [:callouts]).uniq

            process_callouts(list, owner_block)

            list.context = :colist

          end

        end

      rescue => e
        warn e.message
      ensure

        document

      end

    end

    # Checks the format of the list
    # to make sure it's a callout list we should be
    # dealing with.
    # We also won't want any nested lists.
    def external_callout_list?(list)

      list.blocks.all? do |x|

        item_under_test = x.instance_variable_get(:@text)
        location_token_index = item_under_test.index(LOCATION_TOKEN_RX)

        # if we don't find the start of the list of location tokens, or the token is the first item
        # then we don't need to carry on any further; this is not the list we are looking for.
        return false if location_token_index == nil or location_token_index == 0

        # just look at the string of location tokens.
        location_tokens = item_under_test[location_token_index..-1].strip
        location_tokens.match(LOCATION_TOKEN_ARRAY_RX) && x.blocks.empty?

      end

    end

    # Have a look at the next level up
    # to find the block that our CO list belongs to
    def owning_block(list)

      list_parent = list.parent

      raise "There is no block above the callout list" if list_parent == nil

      index_back = list_parent.blocks.index { |x| x == list }

      # We should be able to find our own block, but in case we can't …
      raise "Error – could not locate our ordered list" if index_back == nil

      while index_back > 0

        index_back = index_back - 1

        # We have found our matching block
        return list_parent.blocks[index_back] if list_parent.blocks[index_back].context == :listing

        # We have hit another callout list, but there was no list block first.
        # Assume we have an error
        raise "Callout list found while seeking listing block" if list_parent.blocks[index_back].context == :colist

      end

      # If we didn't find a listing then this document has probably got
       # bits missing.
      raise "No listing found"

    end

    def find_list_index_for_item (list_item)

      list = list_item.parent

      list_numeral = 1
      index_of_this_item = list.blocks.index { |x| x == list_item }
      index_of_this_item.times { list_numeral = list_numeral.next }
      list_numeral

    end

    def process_callouts(list, owner_block)
      list.blocks.each do |list_item|

        # Don't call `list_item.text` because this returns
        # the string in a formatted form. We want the
        # raw string, so go straight to the instance variable.
        item = list_item.instance_variable_get(:@text)

        # No need to test the matcher; we tested
        # the whole block of items when we started

        location_token_index = item.index(LOCATION_TOKEN_RX)
        location_tokens = item[location_token_index..-1].strip
        phrase = item[0..location_token_index - 1].strip

        locations = location_tokens.scan(LOCATION_TOKEN_RX).flatten.compact

        line_numbers = Set.new

        locations.each do |location|

          if location.is_numeric?

            number = location.to_i

            if number <= owner_block.lines.length
              line_numbers << (number - 1)
            else
              warn "Out of range ==> #{number}"
            end

          else

            # Must be a string matcher then

            number = find_matching_lines(location, owner_block)

            if number != nil

              line_numbers << number

            else
              warn "Search term not found ==> #{location}"
            end

          end

        end

        line_numbers.each do |line_number|

          callout = find_list_index_for_item(list_item)
          owner_block.lines[line_number] += " <#{callout}>"

        end

        list_item.text = phrase

      end

    end

    def find_matching_lines(search_string, owner_block)

      owner_block.lines.index { |x| x.match(%r[#{search_string}]) }

    end

    class String
      def is_numeric?
        self.match(/^\d+$/)
      end
    end

  end

end





