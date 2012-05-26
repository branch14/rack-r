module RackR
  class TemplateHandler
    def call(template)
      [ "'<script type=\\'text/r\\'>",
        escape_text(template.source),
        "</script>'.html_safe" ].join
    end

    private

    # stolen from erubis
    def escape_text(text)
      text.gsub(/['\\]/, '\\\\\&')   # "'" => "\\'",  '\\' => '\\\\'
    end

  end
end

ActionView::Template.register_template_handler :rackr, RackR::TemplateHandler.new
