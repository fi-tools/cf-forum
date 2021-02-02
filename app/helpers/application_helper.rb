module ApplicationHelper
    class CodeRayify < Redcarpet::Render::HTML
        def block_code(code, language)
            CodeRay.scan(code, language || :text).div
        end
    end

    def markdown(content)
        coderayified = CodeRayify.new(filter_html: true)
        markdown = Redcarpet::Markdown.new(coderayified, extensions = { 
                                                                    tables: true,
                                                                    fenced_code_blocks: true, 
                                                                    underline: true, 
                                                                    strikethrough: true, 
                                                                    quote: true, 
                                                                    highlight: true, 
                                                                    superscript: true,
                                                                    footnotes: true
                                                                  })
        markdown.render(content).html_safe
    end
end
