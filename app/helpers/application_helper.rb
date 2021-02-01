module ApplicationHelper
    def markdown(content)
        renderer = Redcarpet::Render::HTML.new(filter_html: true, hard_wrap:true)
        markdown = Redcarpet::Markdown.new(renderer, extensions = {tables:true, fenced_code_block: true, underline:true, strikethrough:true, quote:true, highlight: true, superscript:true})
        markdown.render(content).html_safe
    end
end
