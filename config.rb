###
# Page options, layouts, aliases and proxies
###
require 'rouge/plugins/redcarpet'
# Per-page layout changes:
#
# With no layout
Time.zone = 'Pacific Time (US & Canada)'
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false
activate :directory_indexes
activate :minify_css
activate :autoprefixer
set :site_url, "https://team1432.github.io"
#activate :gzip
# activate :sprockets
activate :syntax, :css_class => 'syntax-highlight', :line_numbers => false
::Rack::Mime::MIME_TYPES[''] = 'text/html'
::Rack::Mime::MIME_TYPES['.svg'] = 'image/svg+xml'


class CustomMarkdown < Redcarpet::Render::HTML
  def initialize(options={
    fenced_code_blocks: true,
    smartypants: true,
    tables: true,
    autolink: true,
    with_toc_data: true,
    no_intra_emphasis: true,
    strikethrough: true,
    lax_spacing: true,
    quote: true,
    footnotes: true,
    underline: true
  })
    super options.merge(
      with_toc_data: true,
    )
  end
  def preprocess(rendered_doc)
    markdowner = Redcarpet::Markdown.new(self, options = {
      markdown: true,
      fenced_code_blocks: true,
      smartypants: true,
      tables: true,
      autolink: true,
      with_toc_data: true,
      no_intra_emphasis: true,
      strikethrough: true,
      lax_spacing: true,
      quote: true,
      footnotes: true,
      underline: true
    })
    rendered_doc = custom_markdown(rendered_doc, markdowner)
  end
  def custom_markdown(document, renderer)
    document.gsub!(/{{site\.baseurl}}\/source/, '')
    # document.gsub!(/^([\s\S]+)READMORE/) do
    #   "<p class='summary'>#{$1.to_s}</p>\nREADMORE\n"
    # end
    document
  end
  include Rouge::Plugins::Redcarpet
end

set :markdown_engine, :redcarpet
set :markdown,
  fenced_code_blocks: true,
  smartypants: true,
  tables: true,
  autolink: true,
  with_toc_data: true,
  no_intra_emphasis: true,
  strikethrough: true,
  lax_spacing: true,
  quote: true,
  footnotes: true,
  underline: true,
  renderer: CustomMarkdown

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

activate :blog do |blog|
  set :trailing_slash, false
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"
  blog.layout = "article_layout"

  blog.permalink = "/blog/{title}/index.html"
  # Matcher for blog source files
  blog.sources = "/posts/{year}-{month}-{day}-{title}"
  # blog.taglink = "tags/{tag}.html"
  # blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

page "/feed.xml", layout: false

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# Methods defined in the helpers block are available in templates
helpers do

  def inline_css(path)
    file = sitemap.find_resource_by_path("/stylesheets/" + path.to_s + ".css")
    if file.nil?
      file = sitemap.find_resource_by_path(path.to_s + ".css")
    end
    "<style>#{file.render}</style>"
  end

  def inline_js(path)
    path = "/javascripts/" + path.to_s + ".js"
    "<script>#{sitemap.find_resource_by_path(path).render}</script>"
  end

  def authors_of(article)
    list = []
    if article.data.author?
      list.push article.data.author.split(' ')[0].downcase.strip
    end
    if article.data.authors?
      article.data.authors.split(',').each do |author|
        list.push author.split(' ')[0].downcase.strip
      end
    end
    return list
  end
  def author_tag(author)
    return\
      "<a href='/authors/#{author}' class='author'>
      #{image_tag '/images/authors/' + data.authors[author].photo}
      #{data.authors[author].name}
      </a>"
  end
  def article_card(article)
    author_tags = ""
    for author in authors_of article
      author_tags += author_tag author
    end
    return\
      "<div class='post'>
        <h2 class='title'>#{article.title}</h2>
      #{author_tags}
        <p class='summary'>#{strip_tags article.data.summary}</p>
      #{link_to "Read more...", article, class: "flat button readmore"}
      </div>"
  end
end

data.authors.each do |author, data|
  proxy "/authors/#{author}/index.html", "author.html", locals: {author: data}, layout: 'layout', ignore: true
end
# Build-specific configuration
configure :build do
  activate :minify_javascript, inline: true
  activate :minify_html
  activate :asset_hash
  activate :automatic_image_sizes
  activate :automatic_alt_tags
end

