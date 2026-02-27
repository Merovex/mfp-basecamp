# frozen_string_literal: true

module BasecampMcp
  module HtmlUtils
    module_function

    def strip_for_ai(html)
      return '' if html.nil? || html.empty?

      text = html.dup
      text.gsub!(%r{<bc-attachment[^>]*>.*?</bc-attachment>}m, '[attachment]')
      text.gsub!(%r{<br\s*/?>}, "\n")
      text.gsub!(%r{</p>\s*<p>}, "\n\n")
      text.gsub!('<li>', "\n- ")
      text.gsub!(%r{</li>}, '')
      text.gsub!(/<[^>]+>/, '')
      text.gsub!('&amp;', '&')
      text.gsub!('&lt;', '<')
      text.gsub!('&gt;', '>')
      text.gsub!('&quot;', '"')
      text.gsub!('&#39;', "'")
      text.gsub!('&nbsp;', ' ')
      text.squeeze!(' ')
      text.strip
    end
  end
end
