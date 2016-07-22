xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  site_url = "https://team1432.github.io"
  xml.title "Team 1432"
  xml.id URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, current_page.path), "rel" => "self"
  xml.updated(blog.articles.first.date.to_time.iso8601) unless blog.articles.empty?

  blog.articles.each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => URI.join(site_url, article.url)
      xml.id URI.join(site_url, article.url)
      xml.published article.date.to_time.iso8601
      xml.updated File.mtime(article.source_file).iso8601
      xml.author {
        authors_of(article).each do |author|
          xml.name data.authors[author].name
        end
      }
      #xml.summary article.data.summary, "type" => "html"
      xml.content article.body, "type" => "html"
    end
  end
end
