# frozen_string_literal: true

module Screen::Parser
  def parse_json_argument(page, function)
    JSON.parse(page.body.scan(/#{function}\(({.+})\)/).flatten.first)
  end

  def parse_table(page, selector, remove_columns: [])
    page.search("#{selector} > thead > tr, #{selector} > tbody > tr").map_compact do |tr|
      if tr.search('th').empty?
        tr.search('td').select_index(remove_columns).map(&:remove) unless remove_columns.empty?
        tr
      end
    end
  end
end
