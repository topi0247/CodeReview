# frozen_string_literal: true

require 'rouge/plugins/redcarpet'

class CustomRenderHTML < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet

  def block_code(code, language)
    filename = ''
    if language.present?
      filename = language.split(':')[1]
      language = language.split(':')[0]
    end

    lexer = Rouge::Lexer.find_fancy(language, code) || Rouge::Lexers::PlainText
    code.gsub!(/^/, "\t") if lexer.tag == 'make'
    formatter = rouge_formatter(lexer)
    result = formatter.format(lexer.lex(code))
    return "<div class=#{wrap_class}>#{result}</div" if filename.blank? && language.blank?

    %(<div class="highlight-wrap">
        #{result}
      </div>
    )
  end

  def rouge_formatter(_options = {})
    options = {
      css_class: 'hightlight',
      line_numbers: true,
      line_format: '<span>%i</span>'
    }
    Rouge::Formatters::HTMLLegacy.new(options)
  end

  private

  def wrap_class
    'highlight-wrap'
  end
end

module MarkdownHelper
  def markdown(text)
    options = {
      with_toc_data: true,
      hard_wrap: true
    }
    extensions = {
      no_intra_emphasis: true,
      tables: true,
      fenced_code_blocks: true,
      autolink: true,
      lax_spacing: true,
      lax_html_blocks: true,
      footnotes: true,
      space_after_headers: true,
      strikethrough: true,
      underline: true,
      highlight: true,
      quote: true
    }

    renderer = CustomRenderHTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text)
  end

  def toc(text)
    renderer = Redcarpet::Render::HTML_TOC.new(nesting_level: 6)
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(text)
  end
end
